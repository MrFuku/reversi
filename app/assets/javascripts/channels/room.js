App.room = App.cable.subscriptions.create( {channel: "RoomChannel"}, {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(message) {
    $("#board").html(message)
  },

  speak: function(content, room_id) {
    return this.perform('speak', {message: content, room_id: room_id});
  }
});

document.addEventListener('DOMContentLoaded', function(){
  const room = document.getElementById('room-id')
  const button = document.getElementById('button')
  button.addEventListener('click', function(){
    App.room.speak(content, room.value)
    input.value = ''
  })
})
