class GamesController < ApplicationController
  def edit
    game = Game.find(params[:id])
    room = game.room
    y = params[:y].to_i
    x = params[:x].to_i
    stone = room.color?(current_user)
    respond_to do |format|
      if game.put_stone(y, x, stone)
        format.js
      end
    end
  end
end
