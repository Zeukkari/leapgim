{EventEmitter} = require 'events'
# Local gesture and actions configs
config = require('.././config.json') # TODO: Use yaml

# Input controller's job is to recieve "leapgim frames" from the frame controller. 
class InputController
    constructor: ->
        # Keyboard and mouse control
        @robot = require("robotjs")

    parseGestures: (frameModel) =>
        extendedFingers = frameModel.extendedFingers
        console.log "Extended fingers: ", extendedFingers

# Frame controller recieves leap frame data from leapd and parses it into a structured format we'll use later to configure gestures with 
class FrameController extends EventEmitter
    constructor: ->
        # Frame model - just the extended fingers of an arbitary hand for now
        @handModel = 
            extendedFingers = 
                thumb : 0
                indexFinger : 0
                middleFinger : 0
                ringerFinger : 0
                pinky : 0
            # Palm direction ?

    processFrame: (frame) =>
        #console.info "frame: ", frame
        return if not frame.valid or frame.hands is null
        console.log "Processing frame..."

        # Select the first hand and update extended fingers based on that.. for now
        if frame.hands.length is 0
            console.log "No hands!"
            return

        firstHand = frame.hands[0]
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
        @emit 'update', @handModel

# Init Leap Motion
@Leap = require("leapjs")

loopController = new @Leap.Controller ( 
    inBrowser:              false, 
    enableGestures:         true, 
    frameEventName:         'deviceFrame', 
    background:             true,
    loopWhileDisconnected:  false
)

frameController = new FrameController
inputController = new InputController

frameController.on('update', inputController.parseGestures)
frameController.on 'update', ->
    console.log "Foo"
loopController.on('frame', frameController.processFrame)

# Start the show
loopController.connect()