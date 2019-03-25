class StaticPagesController < ApplicationController
  def index
    @rooms = Room.all
    @games = Game.all
  end
end
