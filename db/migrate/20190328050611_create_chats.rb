class CreateChats < ActiveRecord::Migration[5.2]
  def change
    create_table :chats do |t|
      t.references :room, foreign_key: true
      t.integer :user_id
      t.text :content

      t.timestamps
    end
    add_index :chats, [:room_id, :created_at]
  end
end
