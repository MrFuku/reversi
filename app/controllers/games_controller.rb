class GamesController < ApplicationController
  def edit
    puts "・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・games#edit room_id is #{cookies[:room_id]}"
    @room = Room.find(cookies[:room_id])
    y = params[:y].to_i
    x = params[:x].to_i
    myColor = params[:color]
    @game = @room.game
    @game.put_stone(y,x,myColor)
    @stones = @game.get_stones
    respond_to do |format|
      params[:user_id] = "test"
      puts "・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・・コントローラー user_id is #{params[:user_id]}"
      format.js

    end
  end
end
