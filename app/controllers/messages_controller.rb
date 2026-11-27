class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT

    You are a Pro modern Stylist.\n\nI am a person who cannot figure out what to wear.\n\nHelp me break down my problem and choose some clothes and color to style.\n\nAnswer concisely in Markdown.
  PROMPT

  PROMBT_JSON = <<~PROMPT
    Return ONLY a valid JSON, with no extra text, in this format:
    {"name": "...", "season": "...", "details": "..."}
    Replace the "..." values with what best fits each key, based on the conversation.\n\nFor season only return one of these: winter, summer, spring, autumn
  PROMPT

  before_action :authenticate_user!
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @outfit = @chat.outfit
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      @assistant_message = Message.create(role: "assistant", content: "", chat: @chat)

      response = ask_llm

      @assistant_message.update(content: response.content)
      broadcast_replace(@assistant_message)

      update_outfit

      # call anouther ask_llm to create the JSON with different instructions
      # update the outfit instance

      @chat.generate_title_from_first_message

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to chat_path(@chat) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("new_message_container", partial: "messages/form",
                                                                            locals: { chat: @chat, message: @message })
        end
        format.html { render "chats/show", status: :unprocessable_entity }
      end
    end
  end

  private

  def instructions
    [SYSTEM_PROMPT].compact.join("\n\n")
  end

  def instructions_for_json
    [PROMBT_JSON].compact.join("\n\n")
  end

  def update_outfit
    response_json = ask_llm_for_json
    data = JSON.parse(response_json)
    @outfit.update(name: data["name"], season: data["season"], details: data["details"])
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def build_conversation_history
    @chat.messages.order(:created_at).each do |message|
      next if message.content.blank?

      @ruby_llm_chat.add_message(role: message.role, content: message.content)
    end
  end

  def build_conversation_history_json(chat_json)
    @chat.messages.order(:created_at).each do |message|
      next if message.content.blank?

      chat_json.add_message(role: message.role, content: message.content)
    end
  end

  def ask_llm
    @ruby_llm_chat = RubyLLM.chat.with_instructions(instructions)
    build_conversation_history

    @ruby_llm_chat.complete do |chunk|
      next if chunk.content.blank?

      @assistant_message.content += chunk.content
      broadcast_replace(@assistant_message)
    end
  end

  def ask_llm_for_json
    chat_json = RubyLLM.chat.with_instructions(instructions_for_json)
    build_conversation_history_json(chat_json)

    chat_json.ask("Create the outfit based on our conversation.").content
  end

  def broadcast_replace(message)
    Turbo::StreamsChannel.broadcast_replace_to(@chat, target: helpers.dom_id(message), partial: "messages/message",
                                                      locals: { message: message })
  end
end
