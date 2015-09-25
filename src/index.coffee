# Local gesture and actions configs
config = require('.././config.json') # TODO: Use yaml


###
    The Call of Cthulhu!
    checks if two arrays are equal
### 
Array::arrayIsEqual = (o) ->
    return true if this is o
    return false if this.length isnt o.length
    for i in [0..this.length]
        return false if this[i] isnt o[i]
    true


# Frame controller recieves leap frame data from leapd and parses it into a structured format we'll use later to configure gestures with 
class FrameController
    constructor: () ->
        # State
        @gestureSequence = []
        @extendedFingers = []
        @timeout         = false
        @lastGestureTime = 0
        @wait            = 0

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
        # Guard statements
        return if not @frame.valid
        # return if !@hasToWait()

        @extendedFingers = @getExtendedFingers()
        console.log @extendedFingers
        # check if in mouse mode
        if @isInMouseMode()
            mouseAction = new MouseAction(@frame.hands[0])
            mouseAction.run()
        else
            gestureController = new GestureController(@frame, @extendedFingers)

            currentGesture = gestureController.detect()
            if currentGesture and currentGesture != @gestureSequence[@gestureSequence.length - 1] 
                # save detected time
                @lastGestureTime = new Date().getTime()
                # add it to gestureSequence
                @gestureSequence.push(currentGesture) 
                # get the config
                currentGestureConfig = config.gestures[currentGesture]
                @wait = currentGestureConfig.wait

                # check 
                for sequence in config.gestureSequences 
                    if sequence.gestures.arrayIsEqual @gestureSequence
                        console.log "found sequence -> " + sequence.action.keyCombo
                        if sequence.action.type is "keyboard"
                            keyboard.runKeyCombo(sequence.action.keyCombo)
                        # reset gesture sequence
                        @resetGestureSequence()

    isInMouseMode: ->
        @extendedFingers.length is 5
        
    getExtendedFingers: -> 
        extendedFingers = []
        if @frame.hands.length > 0
            hand = @frame.hands[0]
            fingerMap = ["thumb", "index", "middle", "ring", "pinky"]
            
            for finger in hand.fingers
                if finger.extended is on
                    extendedFingers.push(fingerMap[finger.type])

        return extendedFingers
    resetGestureSequence: -> 
        @gestureSequence    = []
    hasToWait: ->
        now = new Date() 
        return if ((now.getTime() - @lastGestureTime) < @wait) then true else false


# Gesture controller's job is to recieve "leapgim frames" from the frame controller. 
class GestureController

    constructor: (@frame, @extendedFingers) ->
        # Desktop Automation. Control the mouse, keyboard, and read the screen.
        @robot = require("robotjs")

    detect: ->
        if @frame.gestures.length > 0
            for gesture in @frame.gestures
                switch gesture.type
                    when "circle"
                        if @extendedFingers.arrayIsEqual ["thumb", "index"]
                            pointableID = gesture.pointableIds[0];
                            direction = @frame.pointable(pointableID).direction;
                            # dotProduct = @Leap.vec3.dot(direction, gesture.normal);
                            dotProduct = 0

                            if dotProduct > 0
                                return 'oneFingerRotateClockwise'
                            else
                                return 'oneFingerRotateContraClockwise'
        return false
class MouseAction
    constructor: (@hand) ->

    run: ->
        if @hand.pinchStrength > 0
            console.log( 'hand.pinchStrength: ' + @hand.pinchStrength)
            # do click

class KeyboardAction
    runKeyCombo: (keyCombo) -> 
        #press keys
        for key in keyCombo
            super
            robot.keyToggle(key, true)

        #release keys
        for key in keyCombo by -1
            super
            robot.keyToggle(key, false)


#-------------------------------------------------------------
# Boom
keyboard = new KeyboardAction()
frameController = new FrameController()