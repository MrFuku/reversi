class AddUserToRooms < ActiveRecord::Migration[5.2]
  def change
    add_reference :rooms, :owner, foreign_key: { to_table: :users }
    add_reference :rooms, :guest, foreign_key: { to_table: :users }
  end
end
