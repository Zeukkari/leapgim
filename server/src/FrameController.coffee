{EventEmitter} = require 'events'
Leap = require 'leapjs'
zmq = require 'zmq'
YAML = require 'yamljs'

config = YAML.load 'etc/config.yml'

#SOCKET = 'tcp://127.0.0.1:3000'

# Frame controller recieves leap frame data from leapd and parses it into a
# structured format we'll use later to configure gestures with 
class FrameController extends EventEmitter

    # A map to convert Finger type codes into descriptive names
    nameMap : [
        'thumb'
        'indexFinger'
        'middleFinger'
        'ringFinger'
        'pinky'
    ]

    constructor: ->
        @model = @yieldDefaultModel()
        console.log "Frame Controller initialized"

    yieldDefaultHandModel: ->
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
        pinchStrength: 0
        pinchFinger: null

    yieldDefaultModel: =>
        leftHand = @yieldDefaultHandModel()
        leftHand.type = "left"
        rightHand = @yieldDefaultHandModel()
        rightHand.type = "right"
        return [ leftHand, rightHand ]



    findPinchingFingerType: (hand) =>
        pincher = undefined
        closest = 500
        f = 1
        while f < 5
            current = hand.fingers[f]
            distance = Leap.vec3.distance(hand.thumb.tipPosition, current.tipPosition)
            if current != hand.thumb and distance < closest
                closest = distance
                pincher = current
            f++
        pincherName = @nameMap[pincher.type]
        console.log "Pincher type: ", pincher.type
        console.log "Pincher: " + pincherName
        return pincherName

        # if pincher is not undefined
        #     console.log "Pincher type: ", pincher.type
        #     console.log "Pincher: ", pincher

    processFrame: (frame) =>
        console.log "Processing frame..."

        if not frame.valid or frame.hands is null or frame.hands.length is 0
            console.log "Invalid frame or no hands detected"
        else
            @model = []
            for hand in frame.hands
                palmPosition = @relative3DPosition(frame, hand.palmPosition)

                pinchStrength = hand.pinchStrength
                if pinchStrength > 0
                    pinchingFinger = @findPinchingFingerType hand
                else
                    pinchingFinger = null

                # Update frame model
                handModel =
                    type : hand.type
                    extendedFingers: 
                        thumb : hand.thumb.extended
                        indexFinger : hand.indexFinger.extended
                        middleFinger : hand.middleFinger.extended
                        ringerFinger : hand.ringFinger.extended
                        pinky : hand.pinky.extended
                    position: palmPosition
                    grabStrength : hand.grabStrength
                    pinchStrength : pinchStrength
                    pinchingFinger : pinchingFinger
                @model.push handModel
            @emit 'update', @model
        console.log "Processed frame: ", frame.id
        return

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
socket.bindSync config.socket

frameController = new FrameController

frameController.on 'update', (model)->
    console.log "Frame Controller update", model
    #console.log 'sending....'
    socket.send [
        'update'
        JSON.stringify model
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