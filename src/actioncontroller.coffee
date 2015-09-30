Leap = require 'leapjs'
zmq = require 'zmq'

#
# Action Controller
#
# Action controller's job is to recieve "leapgim frames" from the frame 
# controller. 
#
class ActionController
    constructor: ->
        @robot = require("robotjs")
    mouseMove: (handModel) =>
        screenSize = @robot.getScreenSize()
        console.log "Screen size: ", screenSize
        moveTo = 
            x: handModel.position.x * screenSize.width
            y: handModel.position.y * screenSize.height
        console.log "Move to: ", moveTo
        @robot.moveMouse(moveTo.x, moveTo.y)
    parseGestures: (handModel) =>
        console.log "handModel: ", handModel
        # Mouse Move test
        position = handModel.position

        # This conditional is hack to detect when no hand mode is present
        unless position.x is 0 and position.y is 0 and position.z is 0 
            @mouseMove(handModel)

actionController = new ActionController

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
    handModel = JSON.parse(message.toString())
    actionController.parseGestures(handModel)
  return