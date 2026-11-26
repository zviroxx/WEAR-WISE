class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are a Pro modern Stylist.\n\nI am a person who cannot figure out what to wear.\n\nHelp me break down my problem and choose some clothes and color to style.\n\nAnswer concisely in Markdown."

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

  def message_params
    params.require(:message).permit(:content)
  end

  def build_conversation_history
    @chat.messages.order(:created_at).each do |message|
      next if message.content.blank?

      @ruby_llm_chat.add_message(role: message.role, content: message.content)
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

  def broadcast_replace(message)
    Turbo::StreamsChannel.broadcast_replace_to(@chat, target: helpers.dom_id(message), partial: "messages/message",
                                                      locals: { message: message })
  end
end
