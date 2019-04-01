class FriendRequestsController < ApplicationController
  before_action :authenticate_user!

  def create
    user = User.find_by(id: params[:user_id])
    if user == nil
      flash[:alert] = "存在しないユーザーです。"
    elsif current_user.sent_request?(user)
      flash[:alert] = "すでに友達申請を送っているユーザーです。"
    elsif current_user == user
      flash[:alert] = "不正な操作です。"
    elsif current_user.received_request?(user)
       flash[:alert] = "そのユーザーから友達申請を受け取っています。友達になるには申請を承認してください。"
    else
      if current_user.sent_request(user)
        flash[:notice] = "友達申請を送りました。"
      else
        flash[:alert] = "エラーが起きました。もう一度友達申請をやり直してください。"
      end
    end
    redirect_to friends_path
  end

  def destroy
    user = User.find_by(id: params[:id])
    if user == nil
      flash[:alert] = "存在しないユーザーです。"
    elsif !current_user.sent_request?(user)
      flash[:alert] = "このユーザーに対して友達申請はされていません。"
    else
      if current_user.cancel_request(user)
        flash[:notice] = "友達申請をキャンセルしました。"
      else
        flash[:alert] = "エラーが起きました。もう一度キャンセルをやり直してください。"
      end
    end
    redirect_to friends_path
  end
end
