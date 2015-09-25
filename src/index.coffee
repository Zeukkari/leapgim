# Local gesture and actions configs
config = require('.././config.json') # TODO: Use yaml

# Input controller's job is to recieve "leapgim frames" from the frame controller. 
class InputController

    constructor: ->
        # Desktop Automation. Control the mouse, keyboard, and read the screen.
        @robot = require("robotjs")

    parseGestures: (frameModel) =>
        extendedFingers = frameModel.extendedFingers
        console.log "Extended fingers: ", extendedFingers



# Frame controller recieves leap frame data from leapd and parses it into a structured format we'll use later to configure gestures with 
class FrameController
    constructor: ->
        # Frame model - just the extended fingers of an arbitary hand for now
        @handModel = 
            extendedFingers = 
                thumb : 0
                indexFinger : 0
                middleFinger : 0
                ringerFinger : 0
                pinky : 0

        # Init Input controller
        @inputController = new InputController()

        # Init Leap Motion
        @Leap = require("leapjs")
        loopController = new @Leap.Controller ( 
            inBrowser:              false, 
            enableGestures:         true, 
            frameEventName:         'deviceFrame', 
            background:             true,
            loopWhileDisconnected:  false
        )
        loopController.connect()
        loopController.on('frame', @processFrame)

    processFrame: (@frame) =>
        return if not @frame.valid
        console.log "Processing frame..."

        # Select the first hand and update extended fingers based on that.. for now
        if @frame.hands.length is 0
            console.log "No hands!"
            return

        firstHand = @frame.hands[0]
        #console.log "First hand: ", firstHand

        # Update frame model
        @handModel.extendedFingers = 
            @extendedFingers = 
                thumb : firstHand.thumb.extended
                indexFinger : firstHand.indexFinger.extended
                middleFinger : firstHand.middleFinger.extended
                ringerFinger : firstHand.ringFinger.extended
                pinky : firstHand.pinky.extended

        console.log "Frame succesfully processed"

        #console.log @extendedFingers
        @inputController.parseGestures(@handModel)


# Start the show
frameController = new FrameController()