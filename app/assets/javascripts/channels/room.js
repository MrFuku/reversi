App.room = App.cable.subscriptions.create( {channel: "RoomChannel"}, {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(template) {
    $("#board").html(template)
  },

  speak: function(template) {
    return this.perform('speak', {template: template});
  }
});
