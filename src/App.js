require('babel-core/register');

import Leap from 'leapjs';
import robot from 'robotjs';
import YAML from 'yamljs';
import fs from 'fs';

import express from 'express';
let app = express();
let server = require('http').createServer(app);
let io = require('socket.io')(server);
let port = process.env.PORT || 3000;
server.listen(port, function() {
  console.log('Server listening at port %d', port);
  return;
});
// Routing
app.use(express.static(__dirname + '/../static'));

io.on('connection', function(socket) {
  console.log("A user connected");
  return socket.on('disconnect', ()=> console.log('user disconnected'));
});
  // socket.on 'new message', (data) ->
  //   # we tell the client to execute 'new message'
  //   socket.broadcast.emit 'new message',
  //     username: socket.username
  //     message: data
  //   return

import FeedbackController from './FeedbackController';
import ActionController from './ActionController';
import GestureController from './GestureController';
import FrameController from './FrameController';

let defaultProfile = 'etc/config.yml';

let loadProfile = function(profile) {
  console.log(`Load profile ${profile}`);
  let config = YAML.parse(fs.readFileSync(profile, 'utf8'));
  console.log("loaded config: ", config);
  let feedback = undefined;
  let actionHero = undefined;
  let translator = undefined;
  let frameController = undefined;

  console.log("Load profile with Socket.IO: ", io);
  feedback = new FeedbackController(io);
  actionHero = new ActionController(config, feedback);
  translator = new GestureController(config, feedback, actionHero);
  frameController = new FrameController(config, translator);

  // Init Leap Motion
  let leapController = new Leap.Controller(({
    inBrowser:        false,
    enableGestures:     true,
    frameEventName:     'deviceFrame',
    background:       true,
    loopWhileDisconnected:  false
  }));
  console.log("Connecting Leap Controller");
  leapController.connect();
  console.log("Leap Controller connected");

  let consume = function() {
    let frame = leapController.frame();

    // Skip invalid frame processing
    if (frame === null) {
      return;
    }
    return frameController.processFrame(frame);
  };
    // console.log "Consumed frame ", frame.id

  // Config key: interval
  setInterval(consume, config.interval);
  return;
};

loadProfile(defaultProfile);