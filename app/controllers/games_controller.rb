class GamesController < ApplicationController
  def edit
    @game = Game.find(params[:id])
    @room = @game.room
    y = params[:y].to_i
    x = params[:x].to_i
    stone = @room.color?(current_user)
    @game.put_stone(y, x, stone)
    @stones = @game.get_stones
    @message = @game.get_message
    respond_to do |format|
      format.js
    end
  end
end
