class AddOnlyFriendsColumnToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :only_friends, :boolean, default: false, null: false
  end
end
