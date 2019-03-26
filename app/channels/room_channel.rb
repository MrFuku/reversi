class RoomChannel < ApplicationCable::Channel
  def subscribed
    some_channel = "some_channel"
    if user = current_user
      channel = user.get_room || some_channel
      stream_from channel
    else
      stream_from some_channel
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    some_channel = "some_channel"
    if user = current_user
      channel = user.get_room || some_channel
      ActionCable.server.broadcast channel, data['message']
    else
      ActionCable.server.broadcast some_channel, data['message']
    end
  end
end
