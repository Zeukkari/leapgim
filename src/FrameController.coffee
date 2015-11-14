Leap = require 'leapjs'

# Frame controller recieves leap frame data from leapd and parses it into a
# structured format we'll use later to configure gestures with
class FrameController # extends EventEmitter


    # A map to convert Finger type codes into descriptive names
    nameMap : [
        'thumb'
        'indexFinger'
        'middleFinger'
        'ringFinger'
        'pinky'
    ]

    constructor: (config, gestureController)->
        @model = []
        @config = config
        @gestureController = gestureController
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
        # console.log "Pincher type: ", pincher.type
        # console.log "Pincher: " + pincherName
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

    roughDirection: (normalVector) ->
        unless(normalVector?)
            return false

        unless(normalVector.length is 3)
            return false

        vectorX = normalVector[0]
        vectorY = normalVector[1]
        vectorZ = normalVector[2]
        if vectorX < 0.5 and vectorY > 0.5 and vectorZ < 0.5
            return 'up'
        if vectorX < 0.5 and vectorY < -0.5 and vectorZ < 0.5
            return 'down'
        if vectorX < -0.5 and vectorY < 0.5 and vectorZ < 0.5
            return 'left'
        if vectorX > 0.5 and vectorY < 0.5 and vectorZ < 0.5
            return 'right'
        if vectorX < 0.5 and vectorY < 0.5 and vectorZ < -0.5
            return 'forward'
        if vectorX < 0.5 and vectorY < 0.5 and vectorZ > 0.5
            return 'backward'
        return false

    processFrame: (frame) =>
        # console.log "Processing frame..."

        if not frame.valid or frame.hands is null or frame.hands.length is 0
            # console.log "Invalid frame or no hands detected"
        else
            @model =
                hands : []
                gestures : []
                timestamp : frame.timestamp
                #pointables : []
            for hand in frame.hands
                if(@config.stabilize)
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


            if(frame.gestures)
                for gesture in frame.gestures when (gesture.type == 'circle' or gesture.type == 'swipe')
                    #console.log "Gesture #{gesture.type}"
                    gestureModel =
                        type : gesture.type
                        duration : gesture.duration
                        state : gesture.state

                    # Gestures
                    if(gesture.type == 'circle')
                        gestureModel.direction = @roughDirection gesture.normal
                        gestureModel.progress = gesture.progress
                    if(gesture.type == 'swipe')
                        gestureModel.direction = @roughDirection gesture.direction

                    @model.gestures.push gestureModel

            #console.log "Model: ", @model
            @gestureController.parseGestures(@model)
        # console.log "Processed frame: ", frame.id
        return

if(window)
    window.FrameController = FrameController
