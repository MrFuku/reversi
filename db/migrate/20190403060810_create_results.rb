class CreateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :results do |t|
      t.references :user, foreign_key: true
      t.integer :wins, default: 0, null: false
      t.integer :losses, default: 0, null: false
      t.integer :draws, default: 0, null: false

      t.timestamps
    end
  end
end
