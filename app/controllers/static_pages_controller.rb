class StaticPagesController < ApplicationController
  def index
    @rooms = Room.where(guest_id: nil)
    @count = ActionCable.server.connections.length
    list = Redis.current.smembers('online_users')
    @online_users = User.where("id IN (?)", list).paginate(page: params[:page], per_page: 8)
  end

  def test
    flash.now[:notice] = "test"
    # binding.pry
    respond_to do |format|
      format.js
    end
  end
end
