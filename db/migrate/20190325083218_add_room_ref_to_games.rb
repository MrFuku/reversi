class AddRoomRefToGames < ActiveRecord::Migration[5.2]
  def change
    add_reference :games, :room, foreign_key: true
  end
end
