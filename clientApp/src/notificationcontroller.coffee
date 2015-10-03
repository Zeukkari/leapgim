zmq = require 'zmq'

class NotificationController
	visualNotitication: (message) =>
		new Notification(message, {tag: 'leapgim'})

	audioNotitication: (filename) =>
		document.getElementById("audioNotitication").innerHTML='<audio autoplay="autoplay"><source src="sounds/' + filename + '.ogg" type="audio/mpeg" /><source src="sounds/' + filename + '.ogg" type="audio/ogg" /><embed hidden="true" autostart="true" loop="false" src="sounds/' + filename +'.ogg" /></audio>'

Notification = new NotificationController


#
# Socket
#
socket = zmq.socket('sub')
socket.on 'connect', (fd, ep) ->
    console.log 'connect, endpoint:', ep
    return
socket.on 'connect_delay', (fd, ep) ->
    console.log 'connect_delay, endpoint:', ep
    return
socket.on 'connect_retry', (fd, ep) ->
    console.log 'connect_retry, endpoint:', ep
    return
socket.on 'listen', (fd, ep) ->
    console.log 'listen, endpoint:', ep
    return
socket.on 'bind_error', (fd, ep) ->
    console.log 'bind_error, endpoint:', ep
    return
socket.on 'accept', (fd, ep) ->
    console.log 'accept, endpoint:', ep
    return
socket.on 'accept_error', (fd, ep) ->
    console.log 'accept_error, endpoint:', ep
    return
socket.on 'close', (fd, ep) ->
    console.log 'close, endpoint:', ep
    return
socket.on 'close_error', (fd, ep) ->
    console.log 'close_error, endpoint:', ep
    return
socket.on 'disconnect', (fd, ep) ->
    console.log 'disconnect, endpoint:', ep
    return

console.log('Start monitoring...');
socket.monitor 500, 0

# connect to zmq
# socket.connect 'ipc://leapgim.ipc'
socket.connect 'tcp://127.0.0.1:8000'


socket.subscribe 'update'
socket.on 'message', (topic, message) ->
  if(topic.toString() == 'update')
  	console.log message.toString()
  return