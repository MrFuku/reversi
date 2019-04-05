require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(name: "user-name", email:"test@test.com", password:"password")
  end

  it "名前、メールアドレス、パスワードがあれば有効な状態であること" do
    expect(@user).to be_valid
  end

  it "名前がなければ無効な状態であること" do
    @user.name = nil
    @user.valid?
    expect(@user.errors[:name]).to include("を入力してください")
  end

  it "名前が20文字であれば有効な状態であること" do
    @user.name = "a" * 20
    expect(@user).to be_valid
  end

  it "名前が21文字であれば無効な状態であること" do
    @user.name = "a" * 21
    @user.valid?
    expect(@user.errors[:name]).to include("は20文字以内で入力してください")
  end

  it "メールアドレスがなければ無効な状態であること" do
    @user.email = nil
    @user.valid?
    expect(@user.errors[:email]).to include("を入力してください")
  end

  it "メールアドレスが重複していれば無効な状態であること" do
    other = User.create(name: "other-user", email:"test@test.com", password:"otherpass")
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

  describe "友達登録関連メソッド" do
    before do
      @taro = create(:user)
      @jiro = create(:user)
    end

    it "友達登録ができること" do
      expect{
        @taro.add_friend(@jiro)
      }.to change(Friendship, :count).by(2)
    end

    it "友達登録していることを確認できること" do
      expect(@taro.friend?(@jiro)).to eq(false)
      expect(@jiro.friend?(@taro)).to eq(false)
      @taro.add_friend(@jiro)
      expect(@taro.friend?(@jiro)).to eq(true)
      expect(@jiro.friend?(@taro)).to eq(true)
    end

    it "友達登録を解除できること" do
      @taro.add_friend(@jiro)
      expect(@taro.friend?(@jiro)).to eq(true)
      expect(@jiro.friend?(@taro)).to eq(true)
      @taro.remove_friend(@jiro)
      expect(@taro.friend?(@jiro)).to eq(false)
      expect(@jiro.friend?(@taro)).to eq(false)
    end
  end

  describe "戦績関連メソッド" do
    before do
      @user = create(:user)
      @result = @user.create_result
    end
    it "勝ち数が返ること" do
      expect(@user.number_of_wins).to eq(0)
      @result.assign_attributes(wins: 15)
      expect(@user.number_of_wins).to eq(15)
    end
    it "負け数が返ること" do
      expect(@user.number_of_losses).to eq(0)
      @result.assign_attributes(losses: 15)
      expect(@user.number_of_losses).to eq(15)
    end
    it "引き分け数が返ること" do
      expect(@user.number_of_draws).to eq(0)
      @result.assign_attributes(draws: 15)
      expect(@user.number_of_draws).to eq(15)
    end
    it "今までの対戦数が返ること" do
      expect(@user.number_of_games).to eq(0)
      @result.assign_attributes(wins: 1)
      @result.assign_attributes(losses: 10)
      @result.assign_attributes(draws: 100)
      expect(@user.number_of_games).to eq(111)
    end
    it "勝ち数を１増やせること" do
      expect{
        @user.add_wins
        @result.reload
      }.to change{@user.number_of_wins}.by(1)
    end
    it "負け数を１増やせること" do
      expect{
        @user.add_losses
        @result.reload
      }.to change{@user.number_of_losses}.by(1)
    end
    it "引き分け数を１増やせること" do
      expect{
        @user.add_draws
        @result.reload
      }.to change{@user.number_of_draws}.by(1)
    end
  end
end
