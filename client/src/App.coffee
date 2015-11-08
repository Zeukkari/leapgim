robot = require 'robotjs'
YAML = require 'yamljs'
fs = require 'fs'
defaultProfile = 'etc/config.yml'

window.loadProfile = (profile) ->

    console.log "Load profile #{profile}"

    # Clear possible old instances
    window.feedback = undefined
    window.actionHero = undefined
    window.translator = undefined

    # Load config
    config = YAML.parse fs.readFileSync profile, 'utf8'
    window.config = config

    console.log "loaded config: ", config
    window.feedback = new window.FeedbackController
    window.actionHero = new window.ActionController
    window.translator = new window.GestureController
    #window.frameController = new window.FrameController
    window.frameController.on 'update', (model)->
        window.translator.parseGestures(model)
        return
    return " FAIL "

window.loadProfile(defaultProfile)
