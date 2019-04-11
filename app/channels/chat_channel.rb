class ChatChannel < ApplicationCable::Channel
  def subscribed
    # some_channel = "chat_channel"
    # room_id = current_user&.get_room
    # some_channel += "_#{room_id}" if room_id
    # stream_from some_channel
    stream_from "chat_channel_#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def post(data)
    # some_channel = "chat_channel"
    # room_id = current_user&.get_room
    # some_channel += "_#{room_id}" if room_id
    # ActionCable.server.broadcast some_channel, data['template']
    room = current_user.own_room || current_user.guest_room
    if room == nil
      current_user.reload
      room = current_user.own_room || current_user.guest_room
    end

    message = "<div><p>" + data['template'] + "</p></div>"
    mine_message = "<div class=mine ><p>" + data['template'] + "</p></div>"

    if room.owner == current_user
      ActionCable.server.broadcast "chat_channel_#{room.owner.id}", mine_message
      ActionCable.server.broadcast "chat_channel_#{room.guest.id}", message if room.guest
    elsif room.guest == current_user
      ActionCable.server.broadcast "chat_channel_#{room.owner.id}", message if room.owner
      ActionCable.server.broadcast "chat_channel_#{room.guest.id}", mine_message
    end
  end
end
