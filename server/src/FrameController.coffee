{EventEmitter} = require 'events'
Leap = require 'leapjs'
zmq = require 'zmq'
YAML = require 'yamljs'

config = YAML.load 'etc/config.yml'

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
        @model = []
        console.log "Frame Controller initialized"

    # TODO: return an array of pinching fingers if two fingers are both
    # sufficiently close to the thumb.
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

    processFrame: (frame) =>
        console.log "Processing frame..."

        if not frame.valid or frame.hands is null or frame.hands.length is 0
            console.log "Invalid frame or no hands detected"
        else

            console.log "Gestures: ", frame.gestures


            @model =
                hands : []
                gestures : []
                timestamp : frame.timestamp
                #pointables : []
            for hand in frame.hands
                if(config.stabilize)
                    console.log "Stabilized position in use!"
                    position = hand.stabilizedPalmPosition
                else
                    position = hand.palmPosition
                palmPosition = @relative3DPosition(frame, position)

                pinchStrength = hand.pinchStrength
                if pinchStrength > 0
                    pinchingFinger = @findPinchingFingerType hand
                else
                    pinchingFinger = null

                handModel =
                    type : hand.type
                    visible : hand.timeVisible
                    confidence : hand.confidence
                    extendedFingers:
                        thumb : hand.thumb?.extended
                        indexFinger : hand.indexFinger?.extended
                        middleFinger : hand.middleFinger?.extended
                        ringFinger : hand.ringFinger?.extended
                        pinky : hand.pinky?.extended
                    position: palmPosition
                    grabStrength : hand.grabStrength
                    pinchStrength : pinchStrength
                    pinchingFinger : pinchingFinger
                    speed : hand.palmVelocity
                    pitch : hand.pitch
                    roll  : hand.roll
                    direction : hand.direction
                @model.hands.push handModel

            # # Basically fingers, but also pencils etc.
            # for pointable of frame.pointables

            #     if(config.stabilize)
            #         fingerPosition = pointable.stabilizedTipPosition
            #     else
            #         fingerPosition = pointable.tipPosition
            #         tipPosition = relative3DPosition(frame, fingerPosition)

            #     pointableModel =
            #         direction : pointable.direction
            #         length : pointable.length
            #         id : pointable.id
            #         tool : pointable.tool
            #         speed : pointable.tipVelocity
            #     model.pointables.push pointableModel

            # Gestures
            for gesture in frame.gestures

                if gesture.type is "circle"
                    circleVector = frame.pointable(gesture.pointableIds[0]).direction

                    console.log "Circle vector", circleVector
                    console.log "Cirlce normal", gesture.normal

                    gesture.direction = Leap.vec3.dot(circleVector, gesture.normal)

                gestureModel =
                    type : gesture.type
                    duration : gesture.duration
                    progress: gesture.progress
                    state : gesture.state
                    radius : gesture.radius
                    center : gesture.center
                    hands : gesture.handIds
                    speed : gesture.speed
                    startPosition : gesture.startPosition
                    position : gesture.position
                    direction : gesture.direction

                @model.gestures.push gestureModel
            @emit 'update', @model
        console.log "Processed frame: ", frame.id
        return


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
console.log 'Start monitoring...'
socket.monitor 500, 0


# Config key: socket
socket.bindSync config.socket

frameController = new FrameController

frameController.on 'update', (model)->
    console.log "Frame Controller update", model
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

    # Skip invalid frame processing
    if frame is null
        return
    frameController.processFrame(frame)
    console.log "Consumed frame ", frame.id

# Config key: interval
setInterval consume, config.interval
