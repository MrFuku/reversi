class RoomsController < ApplicationController
  def show
    @room_id = 1234
    cookies[:room_id] = @room_id
    game = Game.first
    game.init_bord
    @stones = game.get_stones
    @board_size = 8
  end
end
