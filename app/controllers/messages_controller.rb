class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are a Professional clothing stylist.\n\nI am a person that is unsure or have no idea on what to wear today on me.\n\nHelp me to pick a cloth based on the station, todays standars.\n\nAnswer concisely in Markdown."

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @outfit = @chat.outfit
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      ruby_llm_chat = RubyLLM.chat
      response = ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)

      @chat.generate_title_from_first_message

      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end
end
