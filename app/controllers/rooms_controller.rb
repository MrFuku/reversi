class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :be_not_belong, only: [:create]

  def new
    @room = Room.new
    respond_to do |format|
      format.js
    end
  end

  def show
    @room = Room.find(params[:id])
    unless @room.belongs_to?(current_user)
      allow_room
    end
    @room.turn_user=0
    @room.save
    @game = @room.game
    @game.init_bord
    @stones = @game.get_stones
    @message = @room.get_message
  end

  def create
    @room = current_user.build_own_room
    @game = @room.build_game
    @game.init_bord
    @game.save
    @room.save
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @room = Room.find(params[:id])
    @room.destroy
    redirect_to root_path
  end

  private

  def room_params
    params.require(:room).permit()
  end

  def be_not_belong
    unless current_user.get_room == nil
      redirect_to root_path
    end
  end

  def allow_room
    user = current_user
    if @room.guest == nil && user.get_room == nil
      user.guest_room = @room
      user.save
    else
      redirect_to root_path
    end
  end
end
