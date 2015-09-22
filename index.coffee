# Load LeapJS 
`Leap = require('leapjs');` # embed JavaScript code directly in your CoffeeScript so 'Leap' is global

# <-- This approach looks like a hack, but I remember doing something similar. Do we really need to include leapjs like this???

# Load LeapJS hand entry plugin
require('./lib/leap.hand-entry.js') # TODO: Deprecate


# Desktop Automation. Control the mouse, keyboard, and read the screen.
robot = require("robotjs")

# Local gesture and actions configs
config = require('./config.json') # TODO: Use yaml


loopController = new Leap.Controller( 
                        inBrowser:              false, 
                        enableGestures:         true, 
                        frameEventName:         'deviceFrame', 
                        background:             true,
                        loopWhileDisconnected:  false
                    )
loopController.use('handEntry') # TODO: Deprecate and implement something similar for scratch

class MainController
    constructor: () ->
        @gestureSequence = []
        @extendedFingers = []
        @timeout         = false
        @lastGestureTime = 0
        @wait            = 0
    setFrame: (@frame) -> 

    # This stuff needs structure.
    # - 
    run: ->
        @extendedFingers = @getExtendedFingers()
        # check if in mouse mode
        if @isInMouseMode()
            console.log "mouse mode"
            mouseAction = new MouseAction(@frame.hands[0])
            mouseAction.run()
            # move mouse/exec mouse actions
        # check if in keyboard shortcut mode / has gestures
        else
            gestureController = new Gesture(@frame, @extendedFingers)

            currentGesture = gestureController.detect()
            console.log currentGesture
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
                # debugger

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

class Gesture
    # First argument already contains the data included in the second argument right?
    constructor: (@frame, @extendedFingers) -> 

    detect: ->
        if @frame.gestures.length > 0
            for gesture in @frame.gestures
                switch gesture.type
                    when "circle"
                        if @extendedFingers.arrayIsEqual ["thumb", "index"]
                            pointableID = gesture.pointableIds[0];
                            direction = @frame.pointable(pointableID).direction;
                            dotProduct = Leap.vec3.dot(direction, gesture.normal);

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
            robot.keyToggle(key, true)

        #release keys
        for key in keyCombo by -1
            robot.keyToggle(key, false)

processFrame = (frame) ->
    if frame.valid and !mainController.hasToWait()
        mainController.setFrame(frame)
        mainController.run()
    else
        console.log('Invalid frame')

# The 'new' keyword here caught my attention and got me thinking.. Most of the classes are fundamentally singletons and there's coffeescript syntax available to do exactly that, right? 
# https://coffeescript-cookbook.github.io/chapters/design_patterns/singleton
keyboard = new KeyboardAction()
mainController = new MainController()
loopController.connect()
loopController.on('frame', processFrame)


###
    The Call of Cthulhu
    checks if two arrays are equal
### 
Array::arrayIsEqual = (o) ->
    return true if this is o
    return false if this.length isnt o.length
    for i in [0..this.length]
        return false if this[i] isnt o[i]
    true