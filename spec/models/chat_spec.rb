require 'rails_helper'

RSpec.describe Chat, type: :model do
  before do
    @room = create(:room)
    @chat = @room.chats.build(content: "test content")
  end

  it "ルームとの関連付け、コンテンツがあれば有効な状態であること" do
    expect(@chat).to be_valid
  end

  it "ルームとの関連付けがなければ無効な状態であること" do
    @chat.room = nil
    @chat.valid?
    expect(@chat.errors[:room]).to include("must exist")
  end

  it "コンテンツがなければ無効な状態であること" do
    @chat.content = nil
    @chat.valid?
    expect(@chat.errors[:content]).to include("can't be blank")
  end
end
