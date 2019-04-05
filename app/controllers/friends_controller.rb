class FriendsController < ApplicationController
  before_action :authenticate_user!

  def index
    @friends = current_user.friends.paginate(page: params[:friends_page], per_page: 8)
    @sent_users = current_user.sent_users.paginate(page: params[:sent_page], per_page: 4)
    @received_users = current_user.received_users.paginate(page: params[:received_page], per_page: 4)
  end
end
