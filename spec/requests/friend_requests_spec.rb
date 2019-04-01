require 'rails_helper'

RSpec.describe "FriendRequests", type: :request do
  describe "POST #create" do
    before do
      @user1 = create(:user)
      @user2 = create(:user)
    end
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        post friend_requests_path({user_id: @user2.id})
        assert_redirected_to new_user_session_path
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
        expect(response).to have_http_status(:redirect)
      end
    end

    context "ログイン時" do
      before{ sign_in @user1 }
      context "未申請のユーザーに対して申請を送った場合" do
        it "申請が正常に行われること" do
          expect{
            post friend_requests_path({user_id: @user2.id})
          }.to change(FriendRequest, :count).by(1)
          expect(flash[:notice]).to eq("友達申請を送りました。")
          expect(response).to have_http_status(:redirect)
          assert_redirected_to friends_path
        end
      end

      context "存在しないユーザーに対して申請を送った場合" do
        it "申請が失敗すること" do
          expect{
            post friend_requests_path({user_id: -1})
          }.to change(FriendRequest, :count).by(0)
          expect(flash[:alert]).to eq("存在しないユーザーです。")
          expect(response).to have_http_status(:redirect)
          assert_redirected_to friends_path
        end
      end

      context "申請済みのユーザーに対して申請を送った場合" do
        it "申請が失敗すること" do
          post friend_requests_path({user_id: @user2.id})
          expect{
            post friend_requests_path({user_id: @user2.id})
          }.to change(FriendRequest, :count).by(0)
          expect(flash[:alert]).to eq("すでに友達申請を送っているユーザーです。")
          expect(response).to have_http_status(:redirect)
          assert_redirected_to friends_path
        end
      end

      context "自分に対して申請を送った場合" do
        it "申請が失敗すること" do
          expect{
            post friend_requests_path({user_id: @user1.id})
          }.to change(FriendRequest, :count).by(0)
          expect(flash[:alert]).to eq("不正な操作です。")
          expect(response).to have_http_status(:redirect)
          assert_redirected_to friends_path
        end
      end

      context "申請を送ってきた相手に申請しようとした場合" do
        it "申請が失敗し、相手からの申請の承認を促されること" do
          FriendRequest.create(from_user_id: @user2.id, to_user_id: @user1.id)
          expect{
            post friend_requests_path({user_id: @user2.id})
          }.to change(FriendRequest, :count).by(0)
          expect(flash[:alert]).to eq("そのユーザーから友達申請を受け取っています。友達になるには申請を承認してください。")
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
      FriendRequest.create(from_user_id: @user1.id, to_user_id: @user2.id)
    end

    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        delete friend_request_path @user2
        assert_redirected_to new_user_session_path
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
        expect(response).to have_http_status(:redirect)
      end
    end

    context "ログイン時" do
      before{ sign_in @user1 }
      context "申請済のユーザーに対してキャンセルを実行する時" do
        it "申請が削除されること" do
          expect{
            delete friend_request_path @user2
          }.to change(FriendRequest, :count).by(-1)
          expect(flash[:notice]).to eq("友達申請をキャンセルしました。")
          expect(response).to have_http_status(:redirect)
          assert_redirected_to friends_path
        end
      end

      context "未申請のユーザーに対してキャンセルを実行する時" do
        it "申請が削除されないこと（申請がないこと）" do
          other = create(:user)
          expect{
            delete friend_request_path other
          }.to change(FriendRequest, :count).by(0)
          expect(flash[:alert]).to eq("このユーザーに対して友達申請はされていません。")
          expect(response).to have_http_status(:redirect)
          assert_redirected_to friends_path
        end
      end
    end
  end
end
