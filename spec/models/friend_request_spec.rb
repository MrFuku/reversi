require 'rails_helper'

RSpec.describe FriendRequest, type: :model do
  before do
    user1 = create(:user)
    user2 = create(:user)
    @friend_request = FriendRequest.new(from_user_id: user1.id, to_user_id: user2.id)
  end

  it "from_user,to_userと関連づけられていれば有効な状態であること" do
    expect(@friend_request).to be_valid
  end

  it "from_userと関連づけられていなければ無効な状態であること" do
    @friend_request.from_user_id = nil
    @friend_request.valid?
    expect(@friend_request.errors[:from_user]).to include("を入力してください")
  end

  it "to_userと関連づけられていなければ無効な状態であること" do
    @friend_request.to_user_id = nil
    @friend_request.valid?
    expect(@friend_request.errors[:to_user]).to include("を入力してください")
  end
end
