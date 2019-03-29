class ChatsController < ApplicationController
  before_action :authenticate_user!

  def create
    room = current_user.own_room || current_user.guest_room
    @chat = room.chats.create(chat_params)
    @template = "<div class=#{current_user.id}><p>#{@chat.content}</p></div>"
    respond_to do |format|
      format.js
    end
  end

  private

  def chat_params
    params[:user_id] = current_user.id
    params.permit(:content, :user_id)
  end
end
