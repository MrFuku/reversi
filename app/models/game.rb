class Game < ApplicationRecord
  belongs_to :room
  validates :room_id, presence: true

  def init_board
    self.stones = "........,........,........,...wb...,...bw...,........,........,........,wait_start"
    save!
  end

  def get_stones
    stones.split(",")
  end

  def count_black
    self.stones[0,72].count("b")
  end

  def count_white
    self.stones[0,72].count("w")
  end

  def get_message
    conversion_message(get_stones[8])
  end

  def set_message(token)
    conversion_message(token) #リストにないtokenであればエラーが返る
    stones_array = get_stones
    stones_array[8] = token
    self.stones = stones_array.join(",")
    save!
  end

  def place_to_put(stone)
    place = Array.new(8).map{Array.new(8)}
    if is_turn?(stone)
      for y in 0...8 do
        for x in 0...8 do
          if put_it?(y, x, stone)
            place[y][x] = "can-be-#{stone}"
          end
        end
      end
    end
    return place
  end

  def put_stone(y, x, stone)
    if is_turn?(stone) && directions = put_it?(y, x, stone)
      reverse_stone(y, x, directions, stone)
      change_turn
      true
    else
      return false
    end
  end

  def end?
    token = get_stones[8]
    ["draw", "win_black", "win_white"].include?(token)
  end

  def is_turn?(stone)
    token = get_stones[8]
    if stone == "b"
      ["turn_black", "pass_white"].include?(token)
    elsif stone == "w"
      ["turn_white", "pass_black"].include?(token)
    end
  end

  private

  DY = [-1, -1, 0, 1, 1, 1, 0, -1]
  DX = [0, 1, 1, 1, 0, -1, -1, -1]

  def stuck?(stone)
    for i in 0...8
      for j in 0...8
        return false if put_it?(i, j, stone)
      end
    end
    true
  end

  def range_check(y, x)
    y>=0 && y<8 && x>=0 && x<8
  end

  def change_turn
    token = ""
    nextTurn = is_turn?("b") ? "w" : "b"
    # 1回目の手詰まり判定
    if stuck?(nextTurn)
      # 1回目の手詰まり判定 trueの時
      # 自分のターンに戻り、2回目の手詰まり判定へ
      nextTurn = nextTurn == "b" ? "w" : "b"
      if stuck?(nextTurn)
        # 2回目の手詰まり判定 trueの時
        # ゲーム終了となり、勝敗判定を行う
        if count_black == count_white
          token = "draw"
        else
          token = count_black > count_white ? "win_black" : "win_white"
        end
        self.room.track_record(token)
      else
        # 2回目の手詰まり判定 falseの時
        # 相手のターンはパスされ、自分のターンに移行
        token = nextTurn == "b" ? "pass_white" : "pass_black"
      end
    else
      # 1回目の手詰まり判定 falseの時
      # 通常通り相手のターンに移行
      token = nextTurn == "b" ? "turn_black" : "turn_white"
    end
    set_message(token)
  end

  def reverse_stone?(y, x, myColor)
    stones = get_stones
    rivalColor = myColor=="w"? "b":"w"

    directions = []
    for dir in 0...8 do
      for k in 1...8 do
        nowy = y + DY[dir] * k
        nowx = x + DX[dir] * k
        break unless range_check(nowy, nowx) && stones[nowy][nowx] != "."
        stone = stones[nowy][nowx]
        if  stone == myColor
          if k > 1
            directions << dir
          else
            break
          end
        end
      end
    end
    directions != [] ? directions : false
  end

  def reverse_stone(y, x, directions, myColor)
    stones_array = get_stones
    stones_array[y][x] = myColor
    for dir in directions do
      for k in 1...8 do
        nowy = y + DY[dir] * k
        nowx = x + DX[dir] * k
        if stones_array[nowy][nowx] == myColor
          break
        else
          stones_array[nowy][nowx] = myColor
        end
      end
    end
    self.stones = stones_array.join(",")
    save
  end

  def put_it?(y, x, stone)
    stones_array = get_stones
    return false unless range_check(y, x) && stones_array[y][x] == "."
    reverse_stone?(y, x, stone)
  end

  def conversion_message(token)
    trans_list = {
      "wait_start" => "対戦相手の参加を待っています。",
      "turn_black" => "黒のターンです。",
      "turn_white" => "白のターンです。",
      "pass_black" => "黒がパスしました。白のターンです。",
      "pass_white" => "白がパスしました。黒のターンです。",
      "win_black" => "ゲーム終了です。黒の勝ちです。",
      "win_white" => "ゲーム終了です。白の勝ちです。",
      "draw" => "ゲーム終了です。引き分けです。"
    }
    message = trans_list[token]
    message != nil ? message : raise
  end
end
