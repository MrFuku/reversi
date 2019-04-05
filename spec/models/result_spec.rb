require 'rails_helper'

RSpec.describe Result, type: :model do
  before do
    @user = create(:user)
    @result = Result.new(user: @user)
  end

  it "ユーザーとの関連付けがあれば有効な状態であること" do
    expect(@result).to be_valid
  end

  it "ユーザーとの関連付けがなければ無効な状態であること" do
    @result.user = nil
    @result.valid?
    expect(@result.errors[:user]).to include("を入力してください")
  end
end
