Leap = require 'leapjs'
robot = require 'robotjs'
YAML = require 'yamljs'
fs = require 'fs'
defaultProfile = 'etc/config.yml'

loadProfile = (profile) ->
    console.log "Load profile #{profile}"
    config = YAML.parse fs.readFileSync profile, 'utf8'
    console.log "loaded config: ", config
    feedback = undefined
    actionHero = undefined
    translator = undefined
    frameController = undefined

    feedback = new FeedbackController config
    actionHero = new ActionController config, feedback
    translator = new GestureController config, feedback, actionHero
    frameController = new FrameController config, translator

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

    frameController = new FrameController

    consume = () ->
        frame = leapController.frame()

        # Skip invalid frame processing
        if frame is null
            return
        frameController.processFrame(frame)
        # console.log "Consumed frame ", frame.id

    # Config key: interval
    setInterval consume, config.interval
    return "Foo.."

loadProfile(defaultProfile)
