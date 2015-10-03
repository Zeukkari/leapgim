zmq = require 'zmq'
io = require('socket.io')(app)

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

#socket.connect 'tcp://127.0.0.1:8000'
socket.connect 'ipc://leapgim.ipc'

socket.subscribe 'update'
socket.on 'message', (topic, message) ->
    if(topic.toString() == 'update')
        console.log "Update!"
        handModel = JSON.parse(message.toString())
        #console.log 'Hand model recieved: ', handModel
        #actionController.parseGestures(handModel)
        socket.emit 'update', handModel
    return


io.on 'connection', (socket) ->

    console.log 'Connected: ', socket

    io.on 'update', (data) ->
        socket.emit 'update', data
        return
    return

app = require('http').createServer()

app.listen 8080