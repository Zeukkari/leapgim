Leap = require 'leapjs'
robot = require 'robotjs'
YAML = require 'yamljs'
fs = require 'fs'

express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io')(server)
port = process.env.PORT or 3000
server.listen port, ->
  console.log 'Server listening at port %d', port
  return
# Routing
app.use express.static(__dirname + '/../static')

io.on 'connection', (socket) ->
  console.log "A user connected"
  socket.on 'disconnect', ()->
    console.log('user disconnected');  
  # socket.on 'new message', (data) ->
  #   # we tell the client to execute 'new message'
  #   socket.broadcast.emit 'new message',
  #     username: socket.username
  #     message: data
  #   return

FeedbackController = require './FeedbackController'
ActionController = require './ActionController'
GestureController = require './GestureController'
FrameController = require './FrameController'

defaultProfile = 'etc/config.yml'

loadProfile = (profile) ->
  console.log "Load profile #{profile}"
  config = YAML.parse fs.readFileSync profile, 'utf8'
  console.log "loaded config: ", config
  feedback = undefined
  actionHero = undefined
  translator = undefined
  frameController = undefined

  console.log "Load profile with Socket.IO: ", io
  feedback = new FeedbackController io
  actionHero = new ActionController config, feedback
  translator = new GestureController config, feedback, actionHero
  frameController = new FrameController config, translator

  # Init Leap Motion
  leapController = new Leap.Controller (
    inBrowser:        false,
    enableGestures:     true,
    frameEventName:     'deviceFrame',
    background:       true,
    loopWhileDisconnected:  false
  )
  console.log "Connecting Leap Controller"
  leapController.connect()
  console.log "Leap Controller connected"

  consume = () ->
    frame = leapController.frame()

    # Skip invalid frame processing
    if frame is null
      return
    frameController.processFrame(frame)
    # console.log "Consumed frame ", frame.id

  # Config key: interval
  setInterval consume, config.interval
  return

loadProfile(defaultProfile)