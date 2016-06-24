'use strict';

var _leapjs = require('leapjs');

var _leapjs2 = _interopRequireDefault(_leapjs);

var _robotjs = require('robotjs');

var _robotjs2 = _interopRequireDefault(_robotjs);

var _yamljs = require('yamljs');

var _yamljs2 = _interopRequireDefault(_yamljs);

var _fs = require('fs');

var _fs2 = _interopRequireDefault(_fs);

var _express = require('express');

var _express2 = _interopRequireDefault(_express);

var _FeedbackController = require('./FeedbackController');

var _FeedbackController2 = _interopRequireDefault(_FeedbackController);

var _ActionController = require('./ActionController');

var _ActionController2 = _interopRequireDefault(_ActionController);

var _GestureController = require('./GestureController');

var _GestureController2 = _interopRequireDefault(_GestureController);

var _FrameController = require('./FrameController');

var _FrameController2 = _interopRequireDefault(_FrameController);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

require('babel-core/register');

var app = (0, _express2.default)();
var server = require('http').createServer(app);
var io = require('socket.io')(server);
var port = process.env.PORT || 3000;
server.listen(port, function () {
  console.log('Server listening at port %d', port);
  return;
});
// Routing
app.use(_express2.default.static(__dirname + '/../static'));

io.on('connection', function (socket) {
  console.log("A user connected");
  return socket.on('disconnect', function () {
    return console.log('user disconnected');
  });
});
// socket.on 'new message', (data) ->
//   # we tell the client to execute 'new message'
//   socket.broadcast.emit 'new message',
//     username: socket.username
//     message: data
//   return

var defaultProfile = 'etc/config.yml';

var loadProfile = function loadProfile(profile) {
  console.log('Load profile ' + profile);
  var config = _yamljs2.default.parse(_fs2.default.readFileSync(profile, 'utf8'));
  console.log("loaded config: ", config);
  var feedback = undefined;
  var actionHero = undefined;
  var translator = undefined;
  var frameController = undefined;

  console.log("Load profile with Socket.IO: ", io);
  feedback = new _FeedbackController2.default(io);
  actionHero = new _ActionController2.default(config, feedback);
  translator = new _GestureController2.default(config, feedback, actionHero);
  frameController = new _FrameController2.default(config, translator);

  // Init Leap Motion
  var leapController = new _leapjs2.default.Controller({
    inBrowser: false,
    enableGestures: true,
    frameEventName: 'deviceFrame',
    background: true,
    loopWhileDisconnected: false
  });
  console.log("Connecting Leap Controller");
  leapController.connect();
  console.log("Leap Controller connected");

  var consume = function consume() {
    var frame = leapController.frame();

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