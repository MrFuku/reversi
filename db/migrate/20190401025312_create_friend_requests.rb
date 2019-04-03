class CreateFriendRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :friend_requests do |t|
      t.integer :from_user_id
      t.integer :to_user_id

      t.timestamps
    end
    add_index :friend_requests, :from_user_id
    add_index :friend_requests, :to_user_id
    add_index :friend_requests, [:from_user_id, :to_user_id], unique: true
  end
end
