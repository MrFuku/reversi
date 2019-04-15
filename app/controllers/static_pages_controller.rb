class StaticPagesController < ApplicationController
  def index
    if user_signed_in?
      Redis.current.sadd('online_users', current_user.id)
    end
    @rooms = Room.where(guest_id: nil)
    list = Redis.current.smembers('online_users')
    @online_users = User.where("id IN (?)", list).paginate(page: params[:page], per_page: 8)
  end

  def about
    respond_to do |format|
      format.js
    end
  end
end
