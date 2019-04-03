require 'rails_helper'

RSpec.describe "Friendships", type: :request do
  describe "POST #create" do
    before do
      @user1 = create(:user)
      @user2 = create(:user)
      @friend_request = FriendRequest.create(from_user_id: @user2.id, to_user_id: @user1.id)
    end
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        post friendships_path({from_user_id: @user2.id})
        assert_redirected_to new_user_session_path
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
        expect(response).to have_http_status(:redirect)
      end
    end
    context "ログイン時" do
      before{ sign_in @user1 }
      context "自分宛の友達申請を承認した時" do
        it "友達登録が成功すること" do
          expect{
            expect{
              post friendships_path({from_user_id: @user2.id})
            }.to change(Friendship, :count).by(2)
          }.to change(FriendRequest, :count).by(-1)
          expect(flash[:notice]).to eq("友達登録しました。")
          expect(response).to have_http_status(:redirect)
          assert_redirected_to friends_path
        end
      end
      context "存在しない友達申請を承認した時" do
        it "友達登録が失敗すること" do
          expect{
            expect{
              post friendships_path({from_user_id: -1})
            }.to change(Friendship, :count).by(0)
          }.to change(FriendRequest, :count).by(0)
          expect(flash[:alert]).to eq("友達申請を確認できませんでした。この友達申請はすでに処理された可能性があります。")
          expect(response).to have_http_status(:redirect)
          assert_redirected_to friends_path
        end
      end
      context "友達申請がすでに承認されていた時" do
        it "新たに友達登録されないこと" do
          @user1.add_friend(@user2)
          expect{
            expect{
              post friendships_path({from_user_id: @user2.id})
            }.to change(Friendship, :count).by(0)
          }.to change(FriendRequest, :count).by(-1)
          expect(flash[:alert]).to eq("すでに友達登録されています。")
          expect(response).to have_http_status(:redirect)
          assert_redirected_to friends_path
        end
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      @user1 = create(:user)
      @user2 = create(:user)
      @user1.add_friend(@user2)
    end
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        delete friendship_path(@user2)
        assert_redirected_to new_user_session_path
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
        expect(response).to have_http_status(:redirect)
      end
    end
    context "ログイン時" do
      before{ sign_in @user1 }
      context "友達登録されているユーザーを登録解除する時" do
        it "友達登録が解除されること" do
          expect{
            delete friendship_path(@user2)
          }.to change(Friendship, :count).by(-2)
          assert_redirected_to friends_path
          expect(flash[:notice]).to eq("友達登録を解除しました。")
          expect(response).to have_http_status(:redirect)
        end
      end
      context "存在しないユーザーを登録解除する時" do
        it "友達登録が解除されないこと（友達登録がないこと）" do
          expect{
            delete friendship_path(-1)
          }.to change(Friendship, :count).by(0)
          assert_redirected_to friends_path
          expect(flash[:alert]).to eq("存在しないユーザーです。")
          expect(response).to have_http_status(:redirect)
        end
      end
      context "友達でないユーザーを登録解除する時" do
        it "友達登録が解除されないこと（友達登録がないこと）" do
          other = create(:user)
          expect{
            delete friendship_path(other)
          }.to change(Friendship, :count).by(0)
          assert_redirected_to friends_path
          expect(flash[:alert]).to eq("友達登録されていないユーザーです。")
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
