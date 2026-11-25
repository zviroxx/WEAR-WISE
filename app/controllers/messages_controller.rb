class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are a Pro modern Stylist.\n\nI am a person who cannot figure out what to wear.\n\nHelp me break down my problem and choose some clothes and color to style.\n\nAnswer concisely in Markdown."

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @outfit = @chat.outfit
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)

      @assistant_message = @chat.messages.create(role: "assistant", content: response.content)
      @chat.generate_title_from_first_message

      respond_to do |format|
        format.turbo_stream # renders `app/views/messages/create.turbo_stream.erb`
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
    [SYSTEM_PROMPT, outfit_context].compact.join("\n\n")
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
