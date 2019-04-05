class StaticPagesController < ApplicationController
  def index
    @rooms = Room.all
    @games = Game.all
  end

  def test
    flash.now[:notice] = "test"
    respond_to do |format|
      format.js
    end
  end
end
