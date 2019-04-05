# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_04_03_060810) do

  create_table "chats", force: :cascade do |t|
    t.integer "room_id"
    t.integer "user_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id", "created_at"], name: "index_chats_on_room_id_and_created_at"
    t.index ["room_id"], name: "index_chats_on_room_id"
  end

  create_table "friend_requests", force: :cascade do |t|
    t.integer "from_user_id"
    t.integer "to_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_user_id", "to_user_id"], name: "index_friend_requests_on_from_user_id_and_to_user_id", unique: true
    t.index ["from_user_id"], name: "index_friend_requests_on_from_user_id"
    t.index ["to_user_id"], name: "index_friend_requests_on_to_user_id"
  end

  create_table "friendships", force: :cascade do |t|
    t.integer "user_id"
    t.integer "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["friend_id"], name: "index_friendships_on_friend_id"
    t.index ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true
    t.index ["user_id"], name: "index_friendships_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.text "stones"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "room_id"
    t.index ["room_id"], name: "index_games_on_room_id"
  end

  create_table "results", force: :cascade do |t|
    t.integer "user_id"
    t.integer "wins", default: 0, null: false
    t.integer "losses", default: 0, null: false
    t.integer "draws", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_results_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id"
    t.integer "guest_id"
    t.integer "turn_user"
    t.string "password_digest"
    t.boolean "only_friends", default: false, null: false
    t.index ["game_id"], name: "index_rooms_on_game_id"
    t.index ["guest_id"], name: "index_rooms_on_guest_id"
    t.index ["owner_id"], name: "index_rooms_on_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
