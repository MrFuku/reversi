App.chat = App.cable.subscriptions.create("ChatChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(message) {
    const messages = document.getElementById('chat-contents')
    messages.innerHTML += '<p>' + message + '</p>'
    // Called when there's incoming data on the websocket for this channel
  },

  post: function(message) {
    return this.perform('post', {message: message});
  }
});
