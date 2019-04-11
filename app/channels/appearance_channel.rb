class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    if current_user
      if Redis.current.sismember('online_users', current_user.id)
        puts "*****************************************オンライン情報キャッシュ残り検知*****************************************"
      end
    end
    puts "*****************************************オンライン情報追加*****************************************"
    Redis.current.sadd('online_users', current_user.id) if current_user
    stream_from current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    puts "*****************************************オンライン情報削除*****************************************"
    Redis.current.srem('online_users', current_user.id) if current_user
  end
end
