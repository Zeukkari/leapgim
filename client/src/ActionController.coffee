robot = require 'robotjs'
zmq = require 'zmq'

SOCKET = 'tcp://127.0.0.1:3000'

#
# Action Controller
#
# Action controller's job is to recieve "leapgim frames" from the frame 
# controller. 
#
class ActionController
    constructor: ->
        @robot = require 'robotjs'
        # @mouseState = 
        #     left : "up",
        #     right : "down"
    mouseMove: (handModel) =>
        screenSize = @robot.getScreenSize()
        #console.log "Screen size: " + screenSize.width + "," + screenSize.height
        moveTo = 
            x: handModel.position.x * screenSize.width
            y: handModel.position.y * screenSize.height
        #console.log "Move to: " + moveTo.x + "," + moveTo.y
        @robot.moveMouse(moveTo.x, moveTo.y)
    # down: up|down, button: left|right
    mouseButton: (down, button) =>
        @robot.mouseToggle down, button
        # # Skip action if we're already in the correct state
        # unless (@mouseState[button] == down)        

    parseGestures: (model) =>

        console.log "Parsing gestures.."
        console.log "model: ", model

        handModel = model[0]
        for handModel in model
            console.log "handModel: ", handModel

            # Demo mouse clicking
            checkClick = (button, pinchingFinger) =>
                if (handModel.pinchStrength >  0.5 and handModel.pinchingFinger == pinchingFinger)
                    @mouseButton "down", button
                    console.log "Mouse button " + button + "down"
                else if (handModel.pinchStrength < 0.5)
                    @mouseButton "up", button
                    console.log "Mouse button " + button + "up"
                return
            checkClick 'left', 'indexFinger'
            checkClick 'right', 'ringFinger'

            # Mouse Move test
            position = handModel.position

            # Mouse Lock
            if (handModel.grabStrength > 0.3)
                holdMouse = true

            frameIsEmpty = model is null or model.length is 0
            unless holdMouse is true or frameIsEmpty 
                @mouseMove(handModel)

actionController = new ActionController

socket = zmq.socket('sub')

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

socket.on 'connect', (fd, ep) ->
    console.log 'connect, endpoint:', ep
    socket.subscribe 'update'
    socket.on 'message', (topic, message) ->
        str_topic = topic.toString()
        str_message = message.toString()

        console.log 'topic: ', topic
        console.log 'topic stringified: ', str_topic

        console.log 'message: ', message
        console.log 'message stringified: ', str_message
        if(topic.toString() == 'update')
            model = JSON.parse str_message
            actionController.parseGestures(model)
        return
    return

console.log('Start monitoring...');
socket.monitor 500, 0

socket.connect SOCKET