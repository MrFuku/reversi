class StaticPagesController < ApplicationController
  def index
    if user_signed_in?
      Redis.current.sadd('online_users', current_user.id)
    end
    @rooms = Room.where(guest_id: nil)
    list = Redis.current.smembers('online_users')
    @online_users = User.where("id IN (?)", list).paginate(page: params[:page], per_page: 8)
  end

  def about
    respond_to do |format|
      format.js
    end
  end

  def ad_request
    uri = URI.parse("http://18.182.76.60/api")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end
    case response
    when Net::HTTPSuccess
      render html: response.body.html_safe
    end
  end
end
