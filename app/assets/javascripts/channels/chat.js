App.chat = App.cable.subscriptions.create("ChatChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(message) {
    // Called when there's incoming data on the websocket for this channel

    // チャット追加
    var messages = document.getElementById('chat-contents')
    messages.innerHTML += message

    // 追加時のチャットウィンドウの自動スクロール処理
    var tl = $('#chat-contents');
    var scrollHeight = $(tl).get(0).scrollHeight;
    var nowHeight = $(tl).scrollTop();
    if (nowHeight > scrollHeight - 700) {
      $(tl).scrollTop(scrollHeight);
    }
  },

  post: function(template) {
    return this.perform('post', {template: template});
  }
});
