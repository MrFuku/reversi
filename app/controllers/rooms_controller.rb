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
    @room = current_user.build_own_room(room_params)
    @game = @room.build_game
    @game.init_bord
    respond_to do |format|
      format.js
    end
  end

  def edit
    @room = Room.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def update
    room = Room.find(params[:id])
    if room.has_password? && !room.authenticate(params[:room][:password])
      redirect_to root_path
    else
      redirect_to room
    end
  end

  def destroy
    @room = Room.find(params[:id])
    @room.destroy
    redirect_to root_path
  end

  private

  def room_params
    if params[:add_password]
      params.require(:room).permit(:password, :password_confirmation)
    else
      params.require(:room).permit()
    end
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
