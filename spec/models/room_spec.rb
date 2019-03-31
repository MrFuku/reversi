require 'rails_helper'

RSpec.describe Room, type: :model do
  before do
    @user = create(:user)
    @room = Room.new(owner_id: @user.id)
  end

  it "オーナーユーザーが関連づけられていれば有効な状態であること" do
    expect(@room).to be_valid
  end

  it "オーナーユーザーがいなければ無効な状態であること" do
    @room.owner_id = nil
    @room.valid?
    expect(@room.errors[:owner]).to include("must exist")
  end

  it "オーナーユーザーが存在しないユーザーであれば無効な状態であること" do
    expect(User.find_by(id: 100)).to eq(nil)
    @room.owner_id = 100
    @room.valid?
    expect(@room.errors[:owner]).to include("must exist")
  end

  it "ゲストユーザーが存在しないユーザーであれば無効な状態であること" do
    expect(User.find_by(id: 100)).to eq(nil)
    @room.guest_id = 100
    @room.valid?
    expect(@room.errors[:guest]).to include("when guest_id is present, the user must exist")
  end

  it "関連づけられているユーザーを判別できること" do
    guest_user = create(:user)
    other_user = create(:user)
    @room.guest_id = guest_user.id

    expect(@room.belongs_to?(@user)).to eq(true)
    expect(@room.belongs_to?(guest_user)).to eq(true)
    expect(@room.belongs_to?(other_user)).to eq(false)
  end

  it "ユーザーが置ける石を返すこと" do
    guest_user = create(:user)
    other_user = create(:user)
    @room.guest_id = guest_user.id

    # ルームオーナー（先攻）の時は黒
    expect(@room.color?(@user)).to eq("b")
    # ルームゲスト（後攻）の時は白
    expect(@room.color?(guest_user)).to eq("w")
    # それ以外の時はnone
    expect(@room.color?(other_user)).to eq("none")
  end

  it "パスワード設定の有無を返すこと" do
    expect(@room.has_password?).to eq(false)
    password_room = Room.new(owner_id: @user.id,
       password: "password", password_confirmation: "password")
    expect(password_room.has_password?).to eq(true)
  end
end
