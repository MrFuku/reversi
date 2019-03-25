class RoomChannel < ApplicationCable::Channel
  def subscribed
    some_channel = 1234
    stream_from some_channel
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    some_channel = data['room_id'] || "room_channel"
    puts "aaaaaaaa #{some_channel}"
    ActionCable.server.broadcast some_channel, data['message']
  end
end
