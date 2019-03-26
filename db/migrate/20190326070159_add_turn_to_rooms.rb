class AddTurnToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :turn_user, :integer
  end
end
