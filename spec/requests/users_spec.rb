require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET #index" do
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        get users_path
        assert_redirected_to new_user_session_path
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
        expect(response).to have_http_status(:redirect)
      end
    end

    context "ログイン時" do
      it "ユーザー一覧画面が表示されること" do
        user = create(:user)
        sign_in user
        get users_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show" do
    before{ @user = create(:user) }
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        get user_path @user
        assert_redirected_to new_user_session_path
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
        expect(response).to have_http_status(:redirect)
      end
    end

    context "ログイン時" do
      before{ sign_in @user }
      context "ユーザーが存在する場合" do
        it "ユーザーの詳細画面を表示すること" do
          get user_path @user
          expect(response).to have_http_status(:success)
          expect(response.body).to include @user.email
        end
      end

      context "ユーザーが存在しない場合" do
        it "ユーザー一覧にリダイレクトされること" do
          get user_path -1
          expect(flash[:alert]).to eq("存在しないユーザーです。")
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
