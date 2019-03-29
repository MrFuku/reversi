class ChatChannel < ApplicationCable::Channel
  def subscribed
    some_channel = "chat_channel"
    room_id = current_user&.get_room
    some_channel += "_#{room_id}" if room_id
    stream_from some_channel
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def post(data)
    some_channel = "chat_channel"
    room_id = current_user&.get_room
    some_channel += "_#{room_id}" if room_id
    ActionCable.server.broadcast some_channel, data['template']
  end
end
