class ChatsController < ApplicationController
  def create
    @chat = Chat.new
    @chat.user = current_user
    @chat.outfit = Outfit.create!(user: current_user)
    if @chat.save
      redirect_to chat_path(@chat)
      Rails.logger.info "Chat #{@chat.id} was saved!"
    else
      Rails.logger.info "Chat #{@chat.current_user} was saved!"
      Rails.logger.error "Error #{@chat.errors.full_messages}"
    end
  end

  def show
    # @chat    = current_user.chats.find(params[:id])
    @chat = Chat.find(params[:id])
    @message = Message.new
  end
end
