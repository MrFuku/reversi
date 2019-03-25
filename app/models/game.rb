class Game < ApplicationRecord
  belongs_to :room

  def init_bord
    self.stones = "........,........,........,...wb...,...bw...,........,........,........"
    save
  end

  def range_check(y, x)
    y>=0 && y<8 && x>=0 && x<8
  end

  def get_stones
    stones.split(",")
  end

  def put_stone(y, x, myColor)
    directions = put_it?(y, x, myColor)
    p directions
    if directions
      reverse_stone(y, x, directions, myColor)
    else
      false
    end
  end

  private

  def reverse_stone?(y, x, myColor)
    stones = get_stones
    rivalColor = myColor=="w"? "b":"w"
    dy = [-1, -1, 0, 1, 1, 1, 0, -1]
    dx = [0, 1, 1, 1, 0, -1, -1, -1]
    directions = []
    for dir in 0...8 do
      for k in 1...8 do
        nowy = y + dy[dir] * k
        nowx = x + dx[dir] * k
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
    dy = [-1, -1, 0, 1, 1, 1, 0, -1]
    dx = [0, 1, 1, 1, 0, -1, -1, -1]
    stones_array[y][x] = myColor
    for dir in directions do
      for k in 1...8 do
        nowy = y + dy[dir] * k
        nowx = x + dx[dir] * k
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

  def put_it?(y, x, myColor)
    stones = get_stones
    return false unless range_check(y, x)
    return false unless stones[y][x] == "."
    directions = reverse_stone?(y, x, myColor)
  end
end
