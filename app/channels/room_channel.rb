class RoomChannel < ApplicationCable::Channel
  def subscribed
    some_channel = "room_channel"
    stream_from some_channel
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
  
  def speak(data)
    some_channel = "room_channel"
    ActionCable.server.broadcast some_channel, data['message']
  end
end
