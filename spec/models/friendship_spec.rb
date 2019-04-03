require 'rails_helper'

RSpec.describe Friendship, type: :model do
  before do
    user1 = create(:user)
    user2 = create(:user)
    @frindship = Friendship.new(user_id: user1.id, friend_id: user2.id)
  end

  it "user_id,friend_idと関連づけられていれば有効な状態であること" do
    expect(@frindship).to be_valid
  end

  it "user_idと関連づけられていなければ無効な状態であること" do
    @frindship.user_id = nil
    @frindship.valid?
    expect(@frindship.errors[:user]).to include("を入力してください")
  end

  it "friend_idと関連づけられていなければ無効な状態であること" do
    @frindship.friend_id = nil
    @frindship.valid?
    expect(@frindship.errors[:friend]).to include("を入力してください")
  end
end
