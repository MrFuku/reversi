class AddPasswordToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :password_digest, :string
  end
end
