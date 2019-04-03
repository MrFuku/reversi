class ApplicationController < ActionController::Base

  private

  def authenticate_user!
    unless user_signed_in?
      flash[:alert] = "ログインまたは登録が必要です。"
      respond_to do |format|
        format.html { redirect_to new_user_session_path }
        format.js { render js: "window.location = '/users/sign_in'" }
      end
    end

  end
end
