class GamesController < ApplicationController
  def edit
    @room = Room.find(cookies[:room_id])
    @game = @room.game
    y = params[:y].to_i
    x = params[:x].to_i
    myColor = @room.color?
    if @room.is_turn?(current_user) && @game.put_stone(y,x,myColor)
      @room.change_turn
      @message = @room.get_message
      if @game.stuck?(@room.color?)
        @message = @room.color? + "がパスしました。"
        @room.change_turn
        if @game.stuck?(@room.color?)
          @message = "ゲーム終了。"
          if @game.count_black == @game.count_white
            @message += "引き分けです。"
          else
            @message += @game.count_black > @game.count_white ? "黒":"白"
            @message += "の勝ちです。"
          end
        end
      end
    end
    @stones = @game.get_stones
    respond_to do |format|
      format.js
    end
  end
end
