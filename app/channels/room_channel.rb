class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel_#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    current_user.reload
    if room = current_user&.own_room || current_user&.guest_room
      room_channel_owner = "room_channel_#{room.owner&.id}"
      room_channel_guest = "room_channel_#{room.guest&.id}"
      if !room.game.end? && room.guest
        room.dropout_user(current_user)
        if room.owner == current_user
          ActionCable.server.broadcast room_channel_owner, "game_end_lose"
          ActionCable.server.broadcast room_channel_guest, "game_end_win" if room.guest
        elsif room.guest == current_user
          ActionCable.server.broadcast room_channel_owner, "game_end_win" if room.owner
          ActionCable.server.broadcast room_channel_guest, "game_end_lose"
        end
      else
        ActionCable.server.broadcast room_channel_owner, "game_end" if room.owner
        ActionCable.server.broadcast room_channel_guest, "game_end" if room.guest
      end
      room.destroy
    end
  end

  def speak(data)
    command = data['command']
    current_user.reload
    if room = current_user.own_room || current_user.guest_room
      room_channel_owner = "room_channel_#{room.owner&.id}"
      room_channel_guest = "room_channel_#{room.guest&.id}"
      if command == "game_update"
        ActionCable.server.broadcast room_channel_owner, command if room.owner
        ActionCable.server.broadcast room_channel_guest, command if room.guest
      elsif command == "participation_guest"
        ActionCable.server.broadcast room_channel_owner, command if room.owner
      elsif command == "cancel_game"
        if room.owner == current_user
          ActionCable.server.broadcast room_channel_owner, "game_end_lose"
          ActionCable.server.broadcast room_channel_guest, "game_end_win" if room.guest
        elsif room.guest == current_user
          ActionCable.server.broadcast room_channel_owner, "game_end_win" if room.owner
          ActionCable.server.broadcast room_channel_guest, "game_end_lose"
        end
        room.destroy
      elsif command == "game_end"
        ActionCable.server.broadcast room_channel_owner, command if room.owner
        ActionCable.server.broadcast room_channel_guest, command if room.guest
        room.destroy
      end
    end
  end


end
