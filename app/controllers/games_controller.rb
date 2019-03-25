class GamesController < ApplicationController
  def edit
    y = params[:y].to_i
    x = params[:x].to_i
    myColor = params[:color]
    game = Game.first
    game.put_stone(y,x,myColor)
    @stones = game.get_stones
    respond_to do |format|
      format.js
    end
  end
end
