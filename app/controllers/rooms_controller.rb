class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :belongs_to_room, only: [:show]

  def new
    @room = Room.new
  end

  def show
    @room.turn_user=0
    @room.save!
    @game = @room.game
    @game.init_board
    @game.set_message("turn_black") if @room.guest
    @stones = @game.get_stones
    @message = @game.get_message
    @chats = @room.chats
  end

  def create
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
    redirect_to root_path
  end

  def edit
    @room = Room.find(params[:id])
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
