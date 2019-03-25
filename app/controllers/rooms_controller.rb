class RoomsController < ApplicationController

  def new
    @room = Room.new
    respond_to do |format|
      format.js
    end
  end

  def show
    cookies[:room_id] = params[:id]
    puts "・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・rooms#show room_id is #{cookies[:room_id]}"
    @room = Room.find(cookies[:room_id])
    @game = @room.game
    @game.init_bord
    @stones = @game.get_stones
  end

  def create
    @room = Room.new
    @game = @room.build_game
    @room.save
    @game.init
    @game.save
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
end
