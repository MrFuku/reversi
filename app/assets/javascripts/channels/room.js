App.room = App.cable.subscriptions.create("RoomChannel", {
  connected: function() {
    // Called when the subscription is ready for use on the server
  },

  disconnected: function() {
    // Called when the subscription has been terminated by the server
  },

  received: function(message) {
    const messages = document.getElementById('messages')
    message = '<p>' + message + '</p>'
    messages.innerHTML = message + messages.innerHTML
  },

  speak: function(content) {
    console.log(content)
    return this.perform('speak', {message: content});
  }
});

document.addEventListener('DOMContentLoaded', function(){
  const input = document.getElementById('chat-input')
  const button = document.getElementById('button')
  button.addEventListener('click', function(){
    const content = input.value
    App.room.speak(content)
    input.value = ''
  })
})
