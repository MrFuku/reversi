require 'rails_helper'

RSpec.describe Game, type: :model do
  initBoard = "........,........,........,...wb...,...bw...,........,........,........,wait_start"
  message_list = {
    "wait_start" => "対戦相手の参加を待っています。",
    "turn_black" => "黒のターンです。",
    "turn_white" => "白のターンです。",
    "pass_black" => "黒がパスしました。白のターンです。",
    "pass_white" => "白がパスしました。黒のターンです。",
    "win_black" => "ゲーム終了です。黒の勝ちです。",
    "win_white" => "ゲーム終了です。白の勝ちです。",
    "draw" => "ゲーム終了です。引き分けです。"
  }

  before do
    @room = create(:room)
    allow(@room).to receive(:track_record).and_return(true)
    @game = @room.build_game
    @game.init_board
  end

  it "ルームと関連付けられていれば有効な状態であること" do
    expect(@game).to be_valid
  end

  it "ルームと関連付けられてなければ無効な状態であること" do
    @game.room_id = nil
    @game.valid?
    expect(@game.errors[:room_id]).to include("を入力してください")
  end

  it "オセロの盤面を初期化できること" do
    @game.stones = ""
    expect(@game.stones).to_not eq(initBoard)
    @game.init_board
    expect(@game.stones).to eq(initBoard)
  end

  it "オセロの盤面を二次元配列で返すこと" do
    stones = initBoard.split(',')
    expect(@game.get_stones).to eq(stones)
  end

  it "指定した石の個数を返すこと" do
    nonStone0 = "........,........,........,........,........,........,........,........,wait_start"
    black32 = "bbbb....,bbbb....,bbbb....,bbbb....,bbbb....,bbbb....,bbbb....,bbbb....,wait_start"
    black64 = "bbbbbbbb,bbbbbbbb,bbbbbbbb,bbbbbbbb,bbbbbbbb,bbbbbbbb,bbbbbbbb,bbbbbbbb,wait_start"
    white32 = "wwww....,wwww....,wwww....,wwww....,wwww....,wwww....,wwww....,wwww....,wait_start"
    white64 = "wwwwwwww,wwwwwwww,wwwwwwww,wwwwwwww,wwwwwwww,wwwwwwww,wwwwwwww,wwwwwwww,wait_start"
    b32w32 = "bwbwbwbw,bwbwbwbw,bwbwbwbw,bwbwbwbw,wbwbwbwb,wbwbwbwb,wbwbwbwb,wbwbwbwb,wait_start"
    @game.stones = nonStone0
    expect(@game.count_black).to eq(0)
    expect(@game.count_white).to eq(0)
    @game.stones = black32
    expect(@game.count_black).to eq(32)
    @game.stones = black64
    expect(@game.count_black).to eq(64)
    @game.stones = white32
    expect(@game.count_white).to eq(32)
    @game.stones = white64
    expect(@game.count_white).to eq(64)
    @game.stones = b32w32
    expect(@game.count_black).to eq(32)
    expect(@game.count_white).to eq(32)
  end

  it "メッセージの設定と、それに応じたメッセージが取得ができること" do
    message_list.each do |key, value|
      @game.set_message(key)
      expect(@game.get_message).to eq(value)
    end
  end

  it "リストに載っていないメッセージを設定しようとするとエラーが発生すること" do
    expect{
      @game.set_message("invalid_message")
    }.to raise_error(RuntimeError)
  end

  describe "自分のターンにしか石を置けないこと" do
    context "黒を置く場合" do
      message_list.each do |key, value|
        context "メッセージが「#{key}」の時" do
          before { @game.set_message(key) }
          if ["turn_black", "pass_white"].include?(key)
            it "石が置けること" do
              expect{
                @game.put_stone(2, 3, "b")
              }.to change{@game.count_black}.by(2)
            end
          else
            it "石が置けないこと" do
              expect{
                @game.put_stone(2, 3, "b")
              }.to change{@game.count_black}.by(0)
            end
          end
        end
      end
    end

    context "白を置く場合" do
      message_list.each do |key, value|
        context "メッセージが「#{key}」の時" do
          before { @game.set_message(key) }
          if ["turn_white", "pass_black"].include?(key)
            it "石が置けること" do
              expect{
                @game.put_stone(2, 4, "w")
              }.to change{@game.count_white}.by(2)
            end
          else
            it "石が置けないこと" do
              expect{
                @game.put_stone(2, 4, "w")
              }.to change{@game.count_white}.by(0)
            end
          end
        end
      end
    end
  end

  describe "石が返らない位置に石を置けないこと" do
    context "初期配置から黒が打つ場合" do
      possiblePositions = [[2,3],[3,2],[4,5],[5,4]]
      it "#{possiblePositions}にのみ置けること" do
        for y in 0...8 do
          for x in 0..8 do
            @game.init_board
            @game.set_message("turn_black")
            if possiblePositions.include?([y, x])
              expect{ @game.put_stone(y, x, "b") }.to change{@game.count_black}.by(2)
            else
              expect{ @game.put_stone(y, x, "b") }.to change{@game.count_black}.by(0)
            end
          end
        end
      end
    end

    context "初期配置から白が打つ場合" do
      possiblePositions = [[2,4],[3,5],[4,2],[5,3]]
      it "#{possiblePositions}にのみ置けること" do
        for y in 0...8 do
          for x in 0..8 do
            @game.init_board
            @game.set_message("turn_white")
            if possiblePositions.include?([y, x])
              expect{ @game.put_stone(y, x, "w") }.to change{@game.count_white}.by(2)
            else
              expect{ @game.put_stone(y, x, "w") }.to change{@game.count_white}.by(0)
            end
          end
        end
      end
    end
  end

  describe "石が適切に返ること" do
    it "右方向に返ること" do
      @game.stones =  ".wwwwwwb,........,........,........,........,........,........,........,turn_black"
      expect_stones = "bbbbbbbb,........,........,........,........,........,........,........,win_black"
      @game.put_stone(0, 0, "b")
      expect(@game.stones).to eq(expect_stones)
    end
    it "左方向に返ること" do
      @game.stones =  "bwwwwww.,........,........,........,........,........,........,........,turn_black"
      expect_stones = "bbbbbbbb,........,........,........,........,........,........,........,win_black"
      @game.put_stone(0, 7, "b")
      expect(@game.stones).to eq(expect_stones)
    end
    it "上方向に返ること" do
      @game.stones =  "w.......,b.......,b.......,b.......,b.......,b.......,b.......,........,turn_white"
      expect_stones = "w.......,w.......,w.......,w.......,w.......,w.......,w.......,w.......,win_white"
      @game.put_stone(7, 0, "w")
      expect(@game.stones).to eq(expect_stones)
    end
    it "下方向に返ること" do
      @game.stones =  "........,b.......,b.......,b.......,b.......,b.......,b.......,w.......,turn_white"
      expect_stones = "w.......,w.......,w.......,w.......,w.......,w.......,w.......,w.......,win_white"
      @game.put_stone(0, 0, "w")
      expect(@game.stones).to eq(expect_stones)
    end
    it "八方向に返ること" do
      @game.stones =  "........,.bwbwb..,.wwwww..,.bw.wb..,.wwwww..,.bwbwb..,........,........,turn_black"
      expect_stones = "........,.bwbwb..,.wbbbw..,.bbbbb..,.wbbbw..,.bwbwb..,........,........,turn_white"
      @game.put_stone(3, 3, "b")
      expect(@game.stones).to eq(expect_stones)
    end
  end

  describe "適切にターンが切り替わること" do
    context "黒が打ち、相手のターンに切り替わる場面" do
      it "白のターンに切り替わること" do
        @game.stones = "........,........,........,...wb...,...bw...,........,........,........,turn_black"
        @game.put_stone(2, 3, "b")
        expect(@game.get_message).to eq(message_list["turn_white"])
      end
    end
    context "黒が打ち、白が手詰まりになり黒のターンに戻る場面" do
      it "白がパスし、黒のターンに戻ること" do
        @game.stones = "bwww....,w.......,........,........,........,........,........,........,turn_black"
        @game.put_stone(0, 4, "b")
        expect(@game.get_message).to eq(message_list["pass_white"])
      end
    end
    context "白が打ち、相手のターンに切り替わる場面" do
      it "黒のターンに切り替わること" do
        @game.stones = "........,........,........,...wb...,...bw...,........,........,........,turn_white"
        @game.put_stone(2, 4, "w")
        expect(@game.get_message).to eq(message_list["turn_black"])
      end
    end
    context "白が打ち、黒が手詰まりになり白のターンに戻る場面" do
      it "黒がパスし、白のターンに戻ること" do
        @game.stones = "wbbb....,b.......,........,........,........,........,........,........,turn_white"
        @game.put_stone(0, 4, "w")
        expect(@game.get_message).to eq(message_list["pass_black"])
      end
    end
  end

  describe "ゲーム終了時の勝敗判定" do
    context "盤面は埋まっていないが、両者手詰まりとなり終了する場合" do
      context "黒が24、白が24の時" do
        it "引き分けになること" do
          @game.stones = ".bbbbbbw,wwwwwwww,wwwwwwww,........,........,bbbbbbbb,bbbbbbbb,bbbbbbbb,turn_white"
          @game.put_stone(0, 0, "w")
          expect(@game.get_message).to eq(message_list["draw"])
        end
      end
      context "黒が25、白が24の時" do
        it "黒の勝ちとなること" do
          @game.stones = ".bbbbbbw,wwwwwwww,wwwwwwww,........,.......b,bbbbbbbb,bbbbbbbb,bbbbbbbb,turn_white"
          @game.put_stone(0, 0, "w")
          expect(@game.get_message).to eq(message_list["win_black"])
        end
      end
      context "黒が24、白が25の時" do
        it "白の勝ちとなること" do
          @game.stones = ".bbbbbbw,wwwwwwww,wwwwwwww,w.......,........,bbbbbbbb,bbbbbbbb,bbbbbbbb,turn_white"
          @game.put_stone(0, 0, "w")
          expect(@game.get_message).to eq(message_list["win_white"])
        end
      end
    end

    context "盤面が全て埋まった場合" do
      context "黒が32、白が32の時" do
        it "引き分けになること" do
          @game.stones = "wwwwwwww,wwwwwwww,wwwwwwww,wwwwwwww,bbbbbbbb,bbbbbbbb,bbbbbbbb,.wwwwwwb,turn_black"
          @game.put_stone(7, 0, "b")
          expect(@game.get_message).to eq(message_list["draw"])
        end
      end
      context "黒が33、白が31の時" do
        it "黒の勝ちとなること" do
          @game.stones = "wwwwwwww,wwwwwwww,wwwwwwww,wwwwwwwb,bbbbbbbb,bbbbbbbb,bbbbbbbb,.wwwwwwb,turn_black"
          @game.put_stone(7, 0, "b")
          expect(@game.get_message).to eq(message_list["win_black"])
        end
      end
      context "黒が31、白が33の時" do
        it "白の勝ちとなること" do
          @game.stones = "wwwwwwww,wwwwwwww,wwwwwwww,wwwwwwww,wbbbbbbb,bbbbbbbb,bbbbbbbb,.wwwwwwb,turn_black"
          @game.put_stone(7, 0, "b")
          expect(@game.get_message).to eq(message_list["win_white"])
        end
      end
    end
  end

  describe "設定されているメッセージによって終了判定が行われること" do
    message_list.each do |key, value|
      context "メッセージが「#{key}」の時" do
        before { @game.set_message(key) }
        if ["draw", "win_black", "win_white"].include?(key)
          it "終了判定がtrueであること" do
            expect(@game.end?).to eq(true)
          end
        else
          it "終了判定がfalseであること" do
            expect(@game.end?).to eq(false)
          end
        end
      end
    end
  end
end
