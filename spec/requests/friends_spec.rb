require 'rails_helper'

RSpec.describe "Friends", type: :request do
  describe "GET #index" do
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        get friends_path
        assert_redirected_to new_user_session_path
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
        expect(response).to have_http_status(:redirect)
      end
    end

    context "ログイン時" do
      it "友達画面が表示されること" do
        user = create(:user)
        sign_in user
        get friends_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
