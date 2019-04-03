class FriendsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @friends = User.all
  end
end
