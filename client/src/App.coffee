robot = require 'robotjs'
zmq = require 'zmq'
YAML = require 'yamljs'
fs = require 'fs'
gui = require('nw.gui')

window.config = YAML.parse fs.readFileSync('etc/config.yml', 'utf8')
config = window.config

console.log "Config: ", config

window.feedback = new window.FeedbackController
window.actionHero = new window.ActionController
window.translator = new window.GestureController

# show connecting icon in tray
tray = new gui.Tray({ title: 'Leapgim', tooltip: 'Open Settings', icon: 'asset/image/Rock-&-Roll.png' })

socket = zmq.socket('sub')

##
# Debugging stuff
##
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

    if tray then tray.remove()
    tray = new gui.Tray({ title: 'Leapgim', tooltip: 'Open Settings', icon: 'asset/image/Thumb-Down.png' })

    window.feedback.visualNotification(
        'Server Disconnected', 
        {
            body: 'Connection with Leapgim Server is down', 
            icon: 'Thumb-Down.png', 
            tag: 'zqm'
        }
    )
    return

console.log 'Start monitoring...'
socket.monitor 500, 0


##
# Connection
##
socket.on 'connect', (fd, ep) ->
    console.log 'connect, endpoint:', ep

    # Show tray
    if tray then tray.remove()
    tray = new gui.Tray({ title: 'Leapgim', tooltip: 'Open Settings', icon: 'asset/image/Thumb-up.png' })

    socket.subscribe 'update'
    socket.on 'message', (topic, message) ->
        str_topic = topic.toString()
        str_message = message.toString()

        if(topic.toString() == 'update')
            model = JSON.parse str_message
            translator.parseGestures(model)
        return
    return

console.log "Connect to " + config.socket
socket.connect config.socket
