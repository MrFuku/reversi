App.room = App.cable.subscriptions.create( {channel: "RoomChannel"}, {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(message) {
    //const messages = document.getElementById('messages')
    //message = '<p>' + message + '</p>'
    //console.log(message);
    $("#board").html(message)
    //messages.innerHTML = message + messages.innerHTML
  },

  speak: function(content, room_id) {
    //console.log(content)
    //alert(room_id)
    return this.perform('speak', {message: content, room_id: room_id});
  },

  othello: function(content, room_id) {
    alert(content)
    return this.perform('speak', {message: content, room_id: room_id});
  }
});

document.addEventListener('DOMContentLoaded', function(){
  const room = document.getElementById('room-id')
  const input = document.getElementById('chat-input')
  const button = document.getElementById('button')
  button.addEventListener('click', function(){
    const content = input.value
    App.room.speak(content, room.value)
    input.value = ''
  })
})
