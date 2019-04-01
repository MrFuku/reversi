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
    expect(@user.errors[:email]).to include("を入力してください")
  end

  it "メールアドレスが重複していれば無効な状態であること" do
    other = User.create(email:"test@test.com", password:"otherpass")
    @user.valid?
    expect(@user.errors[:email]).to include("はすでに存在します")
  end

  it "パスワードがなければ無効な状態であること" do
    @user.password = nil
    @user.valid?
    expect(@user.errors[:password]).to include("を入力してください")
  end

  it "ルーム対して、オーナーとゲストの両方で関連付けされていると無効な状態であること" do
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

  it "関連付けられているルームがない時はnilを返すこと" do
    expect(@user.get_room).to eq(nil)
  end

  describe "友達申請関連メソッド" do
    before do
      @taro = create(:user)
      @jiro = create(:user)
    end

    it "友達申請が送れること" do
      expect{
        @taro.sent_request(@jiro)
      }.to change(FriendRequest, :count).by(1)
    end

    it "友達申請を送ったこと、受け取ったことを確認できること" do
      expect(@taro.sent_request?(@jiro)).to eq(false)
      expect(@jiro.received_request?(@taro)).to eq(false)
      @taro.sent_request(@jiro)
      expect(@taro.sent_request?(@jiro)).to eq(true)
      expect(@jiro.received_request?(@taro)).to eq(true)
    end

    it "友達申請をキャンセルできること" do
      @taro.sent_request(@jiro)
      expect{
        @taro.cancel_request(@jiro)
      }.to change(FriendRequest, :count).by(-1)
    end
  end

end
