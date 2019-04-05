class FriendRequestsController < ApplicationController
  before_action :authenticate_user!

  def create
    @user = User.find_by(id: params[:user_id])
    if @user == nil
      flash.now[:alert] = "存在しないユーザーです。"
    elsif current_user.sent_request?(@user)
      flash.now[:alert] = "すでに友達申請を送っているユーザーです。"
    elsif current_user == @user
      flash.now[:alert] = "不正な操作です。"
    elsif current_user.received_request?(@user)
       flash.now[:alert] = "そのユーザーから友達申請を受け取っています。友達になるには申請を承認してください。"
    else
      if current_user.sent_request(@user)
        flash.now[:notice] = "友達申請を送りました。"
      else
        flash.now[:alert] = "エラーが起きました。もう一度友達申請をやり直してください。"
      end
    end
    respond_to do |format|
      format.html { redirect_to friends_path }
      format.js { render "/friends/update_friend_tag" }
    end
  end

  def update
    @user = User.find_by(id: params[:id])
    if @user == nil || !@user.sent_request?(current_user)
      flash.now[:alert] = "友達申請はすでに存在していません。"
    else
      @user.cancel_request(current_user)
      flash.now[:warning] = "友達申請を拒否しました。"
    end
    respond_to do |format|
      format.html { redirect_to friends_path }
      format.js { render "/friends/update_friend_tag" }
    end
  end

  def destroy
    @user = User.find_by(id: params[:id])
    if @user == nil
      flash.now[:alert] = "存在しないユーザーです。"
    elsif !current_user.sent_request?(@user)
      flash.now[:alert] = "このユーザーに対して友達申請はされていません。"
    else
      if current_user.cancel_request(@user)
        flash.now[:warning] = "友達申請をキャンセルしました。"
      else
        flash.now[:alert] = "エラーが起きました。もう一度キャンセルをやり直してください。"
      end
    end
    respond_to do |format|
      format.html { redirect_to friends_path }
      format.js { render "/friends/update_friend_tag" }
    end
  end
end
