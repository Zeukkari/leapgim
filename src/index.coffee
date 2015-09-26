{EventEmitter} = require 'events'
# Local gesture and actions configs
config = require '.././config.json'
Leap = require 'leapjs'

# Input controller's job is to recieve "leapgim frames" from the frame 
# controller. 
class InputController
    constructor: ->
        # Keyboard and mouse control
        @robot = require("robotjs")

    parseGestures: (handModel) =>
        console.log "handModel: ", handModel


# Frame controller recieves leap frame data from leapd and parses it into a
# structured format we'll use later to configure gestures with 
class FrameController extends EventEmitter
    constructor: ->
        # Hand model - just the extended fingers of an arbitary hand for now
        @handModel = 
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
        #console.info "frame: ", frame
        return if not frame.valid or frame.hands is null
        console.log "Processing frame..."

        # Select the first hand and update extended fingers based on that.. for now
        if frame.hands.length is 0
            console.log "No hands!"
            return

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

        console.log "Frame succesfully processed"
        @emit 'update', @handModel

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


# Init Leap Motion
loopController = new Leap.Controller ( 
    inBrowser:              false, 
    enableGestures:         true, 
    frameEventName:         'deviceFrame', 
    background:             true,
    loopWhileDisconnected:  false
)

frameController = new FrameController
inputController = new InputController

frameController.on('update', inputController.parseGestures)
loopController.on('frame', frameController.processFrame)

# Start the show
loopController.connect()