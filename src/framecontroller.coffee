{EventEmitter} = require 'events'
Leap = require 'leapjs'
zmq = require 'zmq'

# Frame controller recieves leap frame data from leapd and parses it into a
# structured format we'll use later to configure gestures with 
class FrameController extends EventEmitter
    constructor: ->
        # Hand model - just the extended fingers of an arbitary hand for now
        @handModel = @yieldDefaultModel()
        console.log "Frame Controller initialized"

    yieldDefaultModel: ->
        extendedFingers :
            thumb : 0
            indexFinger : 0
            middleFinger : 0
            ringerFinger : 0
            pinky : 0
        position : {
            x : 0
            y : 0
            z : 0
        }

    processFrame: (frame) =>
        console.log "Processing frame..."

        if not frame.valid or frame.hands is null or frame.hands.length is 0
            @handModel = @yieldDefaultModel()
        else
            # Select the first hand and update extended fingers based on that.. for now
            firstHand = frame.hands[0]

            palmPosition = @relative3DPosition(frame, firstHand.palmPosition)

            # Update frame model
            @handModel =
                extendedFingers: 
                    thumb : firstHand.thumb.extended
                    indexFinger : firstHand.indexFinger.extended
                    middleFinger : firstHand.middleFinger.extended
                    ringerFinger : firstHand.ringFinger.extended
                    pinky : firstHand.pinky.extended
                position: palmPosition

        @emit 'update', @handModel
        console.log "Processed frame: ", frame.id

    ###
    # Produce x and y coordinates for a leap pointable.
    ###

    relative3DPosition: (frame, leapPoint) ->
        iBox = frame.interactionBox
        normalizedPoint = iBox.normalizePoint(leapPoint, false)

        # Translate coordinates so that origin is in the top left corner
        x = normalizedPoint[0]
        y = 1 - (normalizedPoint[1])
        z = normalizedPoint[2]

        # Clamp
        if x < 0
            x = 0
        if x > 1
            x = 1
        if y < 0
            y = 0
        if y > 1
            y = 1
        if z < -1
            z = -1
        if z > 1
            z = 1
        {
            x: x
            y: y
            z: z
        }


#
# Socket
# 
socket = zmq.socket 'pub'
# Register to monitoring events
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
socket.monitor 500, 0
#socket.bindSync 'tcp://127.0.0.1:8000'
socket.bindSync 'ipc://leapgim.ipc'

frameController = new FrameController

# frameController.on('update', socket.send)
# leapController.on('frame', frameController.processFrame)

frameController.on 'update', (handModel)->
    console.log "Frame Controller update", handModel
    socket.send [
        'update'
        JSON.stringify handModel
    ]
    return

# Init Leap Motion
leapController = new Leap.Controller ( 
    inBrowser:              false, 
    enableGestures:         true, 
    frameEventName:         'deviceFrame', 
    background:             true,
    loopWhileDisconnected:  false
)
console.log "Connecting Leap Controller"
leapController.connect()
console.log "Leap Controller connected"

consume = () ->
    frame = leapController.frame()
    frameController.processFrame(frame)
    console.log "Consumed frame ", frame.id


waitTime = 100

setInterval consume, waitTime