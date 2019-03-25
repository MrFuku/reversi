class RoomChannel < ApplicationCable::Channel
  def subscribed
    some_channel = "some_channel"
    stream_from some_channel
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    some_channel = "some_channel"
    #some_channel = data['room_id'] || "room_channel"
    ActionCable.server.broadcast some_channel, data['message']
  end

  def othello(data)
    some_channel = "some_channel"
    #some_channel = data['room_id'] || "room_channel"
    ActionCable.server.broadcast some_channel, data['template']
  end
end
