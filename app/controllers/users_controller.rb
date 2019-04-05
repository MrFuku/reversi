class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find_by(id: params[:id])
    if @user == nil
      flash[:alert] = "存在しないユーザーです。"
      redirect_to users_path
    end
  end
end
