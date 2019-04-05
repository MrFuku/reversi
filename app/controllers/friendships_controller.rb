class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @user = params[:from_user_id]
    friend_request = FriendRequest.find_by(from_user_id: params[:from_user_id], to_user_id: current_user.id)
    if friend_request == nil
      flash[:alert] = "友達申請を確認できませんでした。この友達申請はすでに処理された可能性があります。"
    else
      @user = friend_request.from_user
      if current_user.friend?(@user)
        flash[:alert] = "すでに友達登録されています。"
      else
        current_user.add_friend(@user)
        flash[:notice] = "友達登録しました。"
      end
      friend_request.destroy
    end

    respond_to do |format|
      format.html { redirect_to friends_path }
      format.js { render "/friends/update_friend_tag" }
    end
  end

  def destroy
    @user = User.find_by(id: params[:id])
    if @user == nil
      flash[:alert] = "存在しないユーザーです。"
    elsif !current_user.friend?(@user)
      flash[:alert] = "友達登録されていないユーザーです。"
    else
      current_user.remove_friend(@user)
      flash[:notice] = "友達登録を解除しました。"
    end
    respond_to do |format|
      format.html { redirect_to friends_path }
      format.js { render "/friends/update_friend_tag" }
    end
  end
end
