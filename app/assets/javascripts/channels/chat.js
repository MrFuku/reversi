App.chat = App.cable.subscriptions.create("ChatChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(template) {
    // Called when there's incoming data on the websocket for this channel
    addChat(template);
  },

  post: function(template) {
    return this.perform('post', {template: template});
  }
});
