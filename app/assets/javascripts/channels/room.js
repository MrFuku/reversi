App.room = App.cable.subscriptions.create( {channel: "RoomChannel"}, {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(command) {
    if (command == "game_update") {
      $.ajax({url: '/rooms/update_score_board', type: "GET"});
    } else if (command == "participation_guest") {
      $.ajax({url: '/rooms/update_score_board', type: "GET", data: {message: "対戦相手が入室しました。"} });
    } else if (command == "dropout") {
      alert("対戦相手がゲームから離脱しました。\nトップ画面に戻ります。")
      location.href='/'
    } else if (command == "game_end") {
      alert("ゲーム終了です。\nトップ画面に戻ります。")
      location.href = '/'
    } else if (command == "game_end_win") {
      alert("相手プレイヤーが対戦を終了しました。\nトップ画面に戻ります。")
      location.href = '/'
    } else if (command == "game_end_lose") {
      alert("対戦を棄権しました。\nトップ画面に戻ります。")
      location.href = '/'
    }
  },

  speak: function(command) {
    return this.perform('speak', { command: command });
  }
});
