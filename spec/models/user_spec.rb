require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(email:"test@test.com", password:"password")
  end


  it "メールアドレス、パスワードがあれば有効な状態であること" do
    expect(@user).to be_valid
  end

  it "メールアドレスがなければ無効な状態であること" do
    @user.email = nil
    @user.valid?
    expect(@user.errors[:email]).to include("can't be blank")
  end

  it "メールアドレスが重複していれば無効な状態であること" do
    other = User.create(email:"test@test.com", password:"otherpass")
    @user.valid?
    expect(@user.errors[:email]).to include("has already been taken")
  end

  it "パスワードがなければ無効な状態であること" do
    @user.password = nil
    @user.valid?
    expect(@user.errors[:password]).to include("can't be blank")
  end

  it "ルーム対して、オーナーとゲストの一方でしか関連付けができないこと" do
    @user.build_own_room
    @user.build_guest_room(owner_id: 2)
    @user.valid?
    expect(@user.errors[:room]).to include("Too many associations")
  end

  it "関連付けられているルームのidを返すこと" do
    own_room = @user.build_own_room
    expect(@user.get_room).to eq(own_room.id)
    own_room.destroy
    guest_room = @user.build_guest_room(owner_id: 2)
    expect(@user.get_room).to eq(guest_room.id)
  end
end
