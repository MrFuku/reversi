require 'rails_helper'

RSpec.describe "Rooms", type: :request do
  describe "GET #new" do
    before{ @user = create(:user) }
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        get new_room_path, xhr: true
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
      end
    end

    context "ログイン時" do
      before{ sign_in @user }
      it "レスポンスが正常であること" do
        get new_room_path, xhr: true
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show" do
    before do
      @user = create(:user)
      @room = @user.create_own_room
      @room.create_game
    end
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        get room_path(@room)
        assert_redirected_to new_user_session_path
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
        expect(response).to have_http_status(:redirect)
      end
    end

    context "ログイン時" do
      before{ sign_in @user }
      context "ユーザーがルームオーナーである時" do
        it "レスポンスが正常であること" do
          get room_path(@room)
          expect(response).to have_http_status(:success)
        end
      end
      context "ユーザーがルームゲストである時" do
        it "レスポンスが正常であること" do
          user2 = create(:user)
          user2.guest_room = @room
          sign_in user2
          get room_path(@room)
          expect(response).to have_http_status(:success)
        end
      end
      context "ユーザーがオーナーでもゲストでもない時" do
        it "ホーム画面にリダイレクトされること" do
          other = create(:user)
          sign_in other
          get room_path(@room)
          assert_redirected_to root_path
          expect(response).to have_http_status(:redirect)
          expect(flash[:alert]).to eq("ルームに参加する権限がないか、存在しないルームです。")
        end
      end
    end
  end

  describe "POST #create" do
    before{ @user = create(:user) }
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        post "/rooms", params: { room: { password: "", password_confirmation: "", add_password: "", only_friends: "" } }
        assert_redirected_to new_user_session_path
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
        expect(response).to have_http_status(:redirect)
      end
    end

    context "ログイン時" do
      before{ sign_in @user }
      context "ルームにパラメーターを指定しない時" do
        it "参加に条件のないルームができること" do
          expect{
            post "/rooms", params: { room: { password: "", password_confirmation: "" } }
          }.to change(Room, :count).by(1)
          expect(flash[:notice]).to eq("ルームを作成しました。")
          expect(@user.own_room.only_friends?).to eq(false)
          expect(@user.own_room.has_password?).to eq(false)
          assert_redirected_to root_path
          expect(response).to have_http_status(:redirect)
        end
      end
      context "ルームに友達限定を指定した時" do
        it "友達限定のルームができること" do
          expect{
            post "/rooms", params: { only_friends: "1", room: { password: "", password_confirmation: ""} }
          }.to change(Room, :count).by(1)
          expect(flash[:notice]).to eq("ルームを作成しました。")
          expect(@user.own_room.only_friends?).to eq(true)
          expect(@user.own_room.has_password?).to eq(false)
          assert_redirected_to root_path
          expect(response).to have_http_status(:redirect)
        end
      end
      context "ルームにパスワードを設定した時" do
        it "パスワード付きのルームができること" do
          expect{
            post "/rooms", params: { add_password: "1", room: { password: "password", password_confirmation: "password"} }
          }.to change(Room, :count).by(1)
          expect(flash[:notice]).to eq("ルームを作成しました。")
          expect(@user.own_room.only_friends?).to eq(false)
          expect(@user.own_room.has_password?).to eq(true)
          assert_redirected_to root_path
          expect(response).to have_http_status(:redirect)
        end
      end
      context "ルームに友達限定、パスワードを設定した時" do
        it "友達限定、パスワード付きのルームができること" do
          expect{
            post "/rooms", params: { only_friends: "1", add_password: "1", room: { password: "password", password_confirmation: "password"} }
          }.to change(Room, :count).by(1)
          expect(flash[:notice]).to eq("ルームを作成しました。")
          expect(@user.own_room.only_friends?).to eq(true)
          expect(@user.own_room.has_password?).to eq(true)
          assert_redirected_to root_path
          expect(response).to have_http_status(:redirect)
        end
      end
      describe "パスワード異常系テスト" do
        context "パスワードが確認パスワードと異なる時" do
          it "ルーム作成できないこと" do
            expect{
              post "/rooms", params: { add_password: "1", room: { password: "password", password_confirmation: "foobar"} }
            }.to change(Room, :count).by(0)
            expect(flash[:alert]).to eq("入力したパスワードが一致しません。")
            assert_redirected_to root_path
            expect(response).to have_http_status(:redirect)
          end
        end
        context "パスワードが入力されていない時" do
          it "ルーム作成できないこと" do
            expect{
              post "/rooms", params: { add_password: "1", room: { password: "", password_confirmation: ""} }
            }.to change(Room, :count).by(0)
            expect(flash[:alert]).to eq("パスワードが入力されていません。")
            assert_redirected_to root_path
            expect(response).to have_http_status(:redirect)
          end
        end
      end
    end
  end

  describe "GET #edit" do
    before do
      @user = create(:user)
      @room = @user.create_own_room
    end
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        get edit_room_path(@room), xhr: true
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
      end
    end
    context "ログイン時" do
      it "レスポンスが正常であること" do
        get edit_room_path(@room), xhr: true
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH #update" do
    before do
      @owner = create(:user)
      @guest = create(:user)
      @room = @owner.create_own_room
    end

    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        patch "/rooms/#{@room.id}"
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
      end
    end

    context "ログイン時" do
      before{ sign_in @guest }
      context "参加制限のないルームの場合" do
        it "ルームに参加できること" do
          patch "/rooms/#{@room.id}"
          assert_redirected_to room_path(@room)
          expect(flash[:notice]).to eq("ルームに参加しました。")
          expect(response).to have_http_status(:redirect)
        end
      end

      context "存在しないルームの場合" do
        it "ルームに参加できないこと（ルームが存在しないこと）" do
          patch "/rooms/#{-1}"
          assert_redirected_to root_path
          expect(flash[:alert]).to eq("このルームは存在しません。")
          expect(response).to have_http_status(:redirect)
        end
      end

      context "オーナーとなっているルームが別にある場合" do
        it "ルームに参加できないこと" do
          @guest.create_own_room
          patch "/rooms/#{@room.id}"
          assert_redirected_to root_path
          expect(flash[:alert]).to eq("すでに参加しているルームがあるため、このルームには参加できません。")
          expect(response).to have_http_status(:redirect)
        end
      end

      context "ゲストとなっているルームが別にある場合" do
        it "ルームに参加できないこと" do
          other = create(:user)
          other.create_own_room(guest: @guest)
          patch "/rooms/#{@room.id}"
          assert_redirected_to root_path
          expect(flash[:alert]).to eq("すでに参加しているルームがあるため、このルームには参加できません。")
          expect(response).to have_http_status(:redirect)
        end
      end

      context "すでにゲストとなっているユーザーが存在する場合" do
        it "ルームに参加できないこと" do
          other = create(:user)
          @room.update_attributes( guest: other )
          patch "/rooms/#{@room.id}"
          assert_redirected_to root_path
          expect(flash[:alert]).to eq("すでに参加しているユーザーがいるため参加できません。")
          expect(response).to have_http_status(:redirect)
        end
      end

      context "友達限定ルームの場合" do
        before{ @room.update_attributes( only_friends: true ) }
        context "友達ユーザーの場合" do
          it "ルームに参加できること" do
            @guest.add_friend(@owner)
            patch "/rooms/#{@room.id}"
            assert_redirected_to room_path(@room)
            expect(flash[:notice]).to eq("ルームに参加しました。")
            expect(response).to have_http_status(:redirect)
          end
        end
        context "友達ユーザーでない場合" do
          it "ルームに参加できないこと" do
            patch "/rooms/#{@room.id}"
            assert_redirected_to root_path
            expect(flash[:alert]).to eq("このルームは友達限定です。")
            expect(response).to have_http_status(:redirect)
          end
        end
      end

      context "パスワード付きルームの場合" do
        before do
          @room.update_attributes( password: "password", password_confirmation: "password" )
        end
        context "正しいパスワードを入力した場合" do
          it "ルームに参加できること" do
            patch "/rooms/#{@room.id}", params: { room: { password: "password" } }
            assert_redirected_to room_path(@room)
            expect(flash[:notice]).to eq("ルームに参加しました。")
            expect(response).to have_http_status(:redirect)
          end
        end
        context "間違ったパスワードを入力した場合" do
          it "ルームに参加できないこと" do
            patch "/rooms/#{@room.id}", params: { room: { password: "invalid" } }
            assert_redirected_to root_path
            expect(flash[:alert]).to eq("パスワードが間違っています。")
            expect(response).to have_http_status(:redirect)
          end
        end
        context "パスワードを入力しなかった場合" do
          it "ルームに参加できないこと" do
            patch "/rooms/#{@room.id}", params: { room: { password: "" } }
            assert_redirected_to root_path
            expect(flash[:alert]).to eq("パスワードが入力されていません。")
            expect(response).to have_http_status(:redirect)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      @user = create(:user)
      @room = @user.create_own_room
    end

    context "未ログイン時" do
      it "ログイン画面にリダイレクトされること" do
        delete "/rooms/#{@room.id}"
        assert_redirected_to new_user_session_path
        expect(flash[:alert]).to eq("ログインまたは登録が必要です。")
        expect(response).to have_http_status(:redirect)
      end
    end

    context "ログイン時" do
      before{ sign_in @user }
      context "存在しないルームの時" do
        it "削除できないこと（ルームが存在しないこと）" do
          expect{
            delete "/rooms/#{-1}"
          }.to change(Room, :count).by(0)
          assert_redirected_to root_path
          expect(flash[:alert]).to eq("このルームは存在しません。")
          expect(response).to have_http_status(:redirect)
        end
      end

      context "ルームオーナーでない時" do
        it "削除できないこと" do
          room = create(:room)
          expect{
            delete "/rooms/#{room.id}"
          }.to change(Room, :count).by(0)
          assert_redirected_to root_path
          expect(flash[:alert]).to eq("このルームを削除する権限がありません。")
          expect(response).to have_http_status(:redirect)
        end
      end

      context "ルームオーナーである時" do
        it "削除できること" do
          expect{
            delete "/rooms/#{@room.id}"
          }.to change(Room, :count).by(-1)
          assert_redirected_to root_path
          expect(flash[:notice]).to eq("ルームを削除しました。")
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end
end
