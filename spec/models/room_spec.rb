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
    expect(@room.errors[:owner]).to include("を入力してください")
  end

  it "オーナーユーザーが存在しないユーザーであれば無効な状態であること" do
    @room.owner_id = -1
    @room.valid?
    expect(@room.errors[:owner]).to include("を入力してください")
  end

  it "ゲストユーザーが存在しないユーザーであれば無効な状態であること" do
    @room.guest_id = -1
    @room.valid?
    expect(@room.errors[:guest]).to include("は存在しないユーザーです")
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

  describe "与えられた入力ごとに戦績の記録を行うこと" do
    before do
      @guest = create(:user)
      @user.create_result
      @guest.create_result
      @room.guest = @guest
    end
    it "両者の戦績が０であること" do
      expect(@room.owner.number_of_games).to eq(0)
      expect(@room.guest.number_of_games).to eq(0)
    end
    context "黒が勝った場合" do
      it "オーナーの勝ちが増え、ゲストの負けが増えること" do
        expect{
          expect{
            @room.track_record("win_black")
          }.to change{ @room.guest.number_of_losses }.by(1)
        }.to change{ @room.owner.number_of_wins }.by(1)
      end
    end
    context "白が勝った場合" do
      it "オーナーの負けが増え、ゲストの勝ちが増えること" do
        expect{
          expect{
            @room.track_record("win_white")
          }.to change{ @room.guest.number_of_wins }.by(1)
        }.to change{ @room.owner.number_of_losses }.by(1)
      end
    end
    context "引き分けの場合" do
      it "両者引き分けが増えること" do
        expect{
          expect{
            @room.track_record("draw")
          }.to change{ @room.guest.number_of_draws }.by(1)
        }.to change{ @room.owner.number_of_draws }.by(1)
      end
    end
  end
end
