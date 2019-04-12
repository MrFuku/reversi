# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  # before_action :already_online?, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
  # def already_online?
  #   if Redis
  #     unless Redis.current.sadd('online_users', current_user.id)
  #       user_name = current_user.name
  #       sign_out(resource)
  #       flash[:alert] = "ログインできません。#{user_name}はすでにオンライン状態です。"
  #       redirect_to root_path
  #     end
  #   end
  # end
  def after_sign_in_path_for(resource)
    super
    resource
  end
end