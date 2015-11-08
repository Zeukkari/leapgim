robot = require 'robotjs'
zmq = require 'zmq'
YAML = require 'yamljs'
fs = require 'fs'
defaultProfile = 'etc/config.yml'

window.loadProfile = (profile) ->

    console.log "Load profile #{profile}"

    # # Close possible zmq socket
    # if(window.socket)
    #     console.log "Close socket"
    #     window.socket.close()

    # Clear possible old instances
    window.feedback = undefined
    window.actionHero = undefined
    window.translator = undefined
    #window.frameController = undefined

    # Load config
    config = YAML.parse fs.readFileSync profile, 'utf8'
    window.config = config

    console.log "loaded config: ", config

    # socket = zmq.socket('sub')
    # socket.on 'connect', (fd, ep) ->
    #     console.log 'connect, endpoint:', ep
    #     socket.subscribe 'update'
    #     socket.on 'message', (topic, message) ->
    #         try
    #             str_topic = topic.toString()
    #             str_message = message.toString()

    #             if(topic.toString() == 'update')
    #                 model = JSON.parse str_message
    #                 translator.parseGestures(model)
    #         catch e
    #             console.log "error", e.message
    #             console.log "trace", e.stack
    #         return
    #     return
    # socket.on 'connect_delay', (fd, ep) ->
    #     console.log 'connect_delay, endpoint:', ep
    #     return
    # socket.on 'connect_retry', (fd, ep) ->
    #     console.log 'connect_retry, endpoint:', ep
    #     return
    # socket.on 'listen', (fd, ep) ->
    #     console.log 'listen, endpoint:', ep
    #     return
    # socket.on 'bind_error', (fd, ep) ->
    #     console.log 'bind_error, endpoint:', ep
    #     return
    # socket.on 'accept', (fd, ep) ->
    #     console.log 'accept, endpoint:', ep
    #     return
    # socket.on 'accept_error', (fd, ep) ->
    #     console.log 'accept_error, endpoint:', ep
    #     return
    # socket.on 'close', (fd, ep) ->
    #     console.log 'close, endpoint:', ep
    #     return
    # socket.on 'close_error', (fd, ep) ->
    #     console.log 'close_error, endpoint:', ep
    #     return
    # socket.on 'disconnect', (fd, ep) ->
    #     console.log 'disconnect, endpoint:', ep
    #     return
    # console.log 'Start monitoring...'
    # socket.monitor 500, 0

    #window.socket = socket
    window.feedback = new window.FeedbackController
    window.actionHero = new window.ActionController
    window.translator = new window.GestureController
    #window.frameController = new window.FrameController
    window.frameController.on 'update', (model)->
        window.translator.parseGestures(model)
        return
    return " FAIL "

    #console.log "Connect to " + config.socket
    # slowConnect = ()->
    #     window.socket.connect config.socket
    # setTimeout slowConnect, 1000

window.loadProfile(defaultProfile)
