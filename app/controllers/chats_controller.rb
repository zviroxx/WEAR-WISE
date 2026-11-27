class ChatsController < ApplicationController
  before_action :authenticate_user!
  def create
    @chat = Chat.new
    @chat.user = current_user
    @chat.outfit = Outfit.create!(user: current_user)
    if @chat.save
      redirect_to chat_path(@chat)
      Rails.logger.info "Chat #{@chat.id} was saved!"
    else
      Rails.logger.error "Chat failed to save: #{@chat.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
  end
end
