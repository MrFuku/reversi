class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :belongs_to_room, only: [:show]

  def new
    @room = Room.new
  end

  def show
    if request.path_info != session[:ref]
      session[:ref] = request.path_info
      # 通常時の処理
      @game = @room.game
      @game.set_message("turn_black") if @room.guest
      @stones = @game.get_stones
      @message = @game.get_message
      @chats = @room.chats
    else
      # reload時の処理
      flash[:alert] = "再読み込み禁止です。"
      redirect_to root_path
    end

  end

  def create
    @room = nil
    if current_user.get_room != nil
      flash[:alert] = "すでに参加しているルームがあるため、作成できません。"
    elsif params[:add_password] && params[:room][:password] != params[:room][:password_confirmation]
      flash[:alert] = "入力したパスワードが一致しません。"
    elsif params[:add_password] && params[:room][:password] == ""
      flash[:alert] = "パスワードが入力されていません。"
    else
      Room.transaction do
        Game.transaction do
          @room = current_user.create_own_room(room_params)
          @room.only_friends = true if params[:only_friends] == "1"
          @room.save!
          @game = @room.build_game
          @game.init_board
          flash[:notice] = "ルームを作成しました。"
        end
      end
    end

    if @room
      redirect_to room_path(@room)
    else
      redirect_to root_path
    end
  end

  def edit
    if !@room = Room.find_by(id: params[:id])
      flash[:alert] = "このルームは削除されました。"
      render :js => "window.location = '/'"
    elsif @room.only_friends? && !@room.owner.friend?(current_user)
      flash[:alert] = "このルームは友達限定です。"
      render :js => "window.location = '/'"
    end
  end

  def update
    room = Room.find_by(id: params[:id])
    if room == nil
      flash[:alert] = "このルームは存在しません。"
    elsif room.belongs_to?(current_user)
      flash[:notice] = "入室しました。"
    elsif current_user.get_room != nil
      flash[:alert] = "すでに参加しているルームがあるため、このルームには参加できません。"
    elsif room.guest != nil
      flash[:alert] = "すでに参加しているユーザーがいるため参加できません。"
    elsif room.only_friends? && !room.owner.friend?(current_user)
      flash[:alert] = "このルームは友達限定です。"
    elsif room.has_password? && params[:room][:password] == ""
      flash[:alert] = "パスワードが入力されていません。"
    elsif room.has_password? && !room.authenticate(params[:room][:password])
      flash[:alert] = "パスワードが間違っています。"
    else
      current_user.guest_room = room
      current_user.save!
      flash[:notice] = "ルームに参加しました。"
    end

    if room&.belongs_to?(current_user)
      redirect_to room_path(room)
    else
      redirect_to root_path
    end
  end

  def destroy
    room = Room.find_by(id: params[:id])
    if room == nil
      flash[:alert] = "このルームは存在しません。"
    elsif room.owner != current_user
      flash[:alert] = "このルームを削除する権限がありません。"
    else
      room.destroy
      flash[:notice] = "ルームを削除しました。"
    end
    redirect_to root_path
  end

  def update_score_board
    @room = current_user.own_room || current_user.guest_room
    @game = @room&.game
    stone = @room&.color?(current_user)
    if @game.end?
      flash.now[:alert] = "ゲームが終了しました。"
    elsif params[:message]
      flash.now[:notice] = params[:message]
    elsif @game.is_turn?(stone)
      @plase = @game.place_to_put(stone)
      flash.now[:notice] = "あなたのターンです。"
    else
      flash.now[:warning] = "相手のターンです。"
    end

    respond_to do |format|
      format.js
    end
  end

  def close_room
    room = current_user.own_room || current_user.guest_room
    if room == nil
      respond_to do |format|
        format.js { render js: "window.location = '/'" }
      end
    end
    if room.game.end?
      @command = "game_end"
    elsif room.guest == nil
      @command = "game_end"
    else
      room.dropout_user(current_user)
      @command = "cancel_game"
    end
    respond_to do |format|
      format.js
    end
  end

  def exist_room
    if current_user.get_room == nil
      respond_to do |format|
        format.js { render js: "alert('予期せぬエラーが起きました。\nトップ画面に戻ります。'); window.location = '/'" }
      end
    end
  end

  private

  def room_params
    if params[:add_password] =="1"
      params.require(:room).permit(:password, :password_confirmation)
    else
      params.require(:room).permit()
    end
  end

  def belongs_to_room
    @room = Room.find_by(id: params[:id])
    if @room == nil || !@room.belongs_to?(current_user)
      flash[:alert] = "ルームに参加する権限がないか、存在しないルームです。"
      redirect_to root_path
    end
  end
end
