class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]

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

  def guest_new
    @user = User.new
  end

  def guest_create
    @user = User.new(guest_params)
    while true do
      @user.email = (0...14).map{ ('a'..'z').to_a[rand(26)] }.join + "@example.com"
      break unless User.find_by(email: @user.email)
    end

    if @user.save
      flash[:notice] = "ゲストユーザーを登録しました。"
      @user.create_result
      sign_in @user
      redirect_to @user
    else
      render '/users/guest_new'
    end
  end

  private

  def guest_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
end
