'use strict';

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _leapjs = require('leapjs');

var _leapjs2 = _interopRequireDefault(_leapjs);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

// A map to convert Finger type codes into descriptive names
var nameMap = ['thumb', 'indexFinger', 'middleFinger', 'ringFinger', 'pinky'];

// Frame controller recieves leap frame data from leapd and parses it into a
// structured format we'll use later to configure gestures with

var FrameController = function () {
    // extends EventEmitter

    function FrameController(config, gestureController) {
        _classCallCheck(this, FrameController);

        this.findPinchingFingerType = this.findPinchingFingerType.bind(this);
        this.processFrame = this.processFrame.bind(this);
        this.model = [];
        this.config = config;
        this.gestureController = gestureController;
        console.log("Frame Controller initialized");
    }

    // TODO: return an array of pinching fingers if two fingers are both
    // sufficiently close to the thumb.


    _createClass(FrameController, [{
        key: 'findPinchingFingerType',
        value: function findPinchingFingerType(hand) {
            var pincher = undefined;
            var closest = 500;
            var f = 1;
            while (f < 5) {
                var current = hand.fingers[f];
                var distance = _leapjs2.default.vec3.distance(hand.thumb.tipPosition, current.tipPosition);
                if (current !== hand.thumb && distance < closest) {
                    closest = distance;
                    pincher = current;
                }
                f++;
            }
            var pincherName = nameMap[pincher.type];
            // console.log "Pincher type: ", pincher.type
            // console.log "Pincher: " + pincherName
            return pincherName;
        }

        /*
         * Produce x and y coordinates for a leap pointable.
         */

    }, {
        key: 'relative3DPosition',
        value: function relative3DPosition(frame, leapPoint) {
            var iBox = frame.interactionBox;
            var normalizedPoint = iBox.normalizePoint(leapPoint, false);

            // Translate coordinates so that origin is in the top left corner
            var x = normalizedPoint[0];
            var y = 1 - normalizedPoint[1];
            var z = normalizedPoint[2];

            // Clamp
            if (x < 0) {
                x = 0;
            }
            if (x > 1) {
                x = 1;
            }
            if (y < 0) {
                y = 0;
            }
            if (y > 1) {
                y = 1;
            }
            if (z < -1) {
                z = -1;
            }
            if (z > 1) {
                z = 1;
            }
            return {
                x: x,
                y: y,
                z: z
            };
        }
    }, {
        key: 'roughDirection',
        value: function roughDirection(normalVector) {
            if (normalVector == null) {
                return false;
            }

            if (normalVector.length !== 3) {
                return false;
            }

            var vectorX = normalVector[0];
            var vectorY = normalVector[1];
            var vectorZ = normalVector[2];
            if (vectorX < 0.5 && vectorY > 0.5 && vectorZ < 0.5) {
                return 'up';
            }
            if (vectorX < 0.5 && vectorY < -0.5 && vectorZ < 0.5) {
                return 'down';
            }
            if (vectorX < -0.5 && vectorY < 0.5 && vectorZ < 0.5) {
                return 'left';
            }
            if (vectorX > 0.5 && vectorY < 0.5 && vectorZ < 0.5) {
                return 'right';
            }
            if (vectorX < 0.5 && vectorY < 0.5 && vectorZ < -0.5) {
                return 'forward';
            }
            if (vectorX < 0.5 && vectorY < 0.5 && vectorZ > 0.5) {
                return 'backward';
            }
            return false;
        }
    }, {
        key: 'processFrame',
        value: function processFrame(frame) {
            console.log("Processing frame..." + frame.id);
            //console.log(frame);

            if (!frame.valid || frame.hands === null || frame.hands.length === 0) {
                //console.log("Invalid frame or no hands detected");
                return;
            }
            this.model = {
                hands: [],
                gestures: [],
                timestamp: frame.timestamp
            };
            //pointables : []
            for (var i = 0; i < frame.hands.length; i++) {
                var hand = frame.hands[i];
                if (this.config.stabilize) {
                    var position = hand.stabilizedPalmPosition;
                } else {
                    var position = hand.palmPosition;
                }
                var palmPosition = this.relative3DPosition(frame, position);

                var pinchStrength = hand.pinchStrength;

                if (pinchStrength > 0) {
                    var pinchingFinger = this.findPinchingFingerType(hand);
                } else {
                    var pinchingFinger = null;
                }

                var handModel = {
                    type: hand.type,
                    visible: hand.timeVisible,
                    confidence: hand.confidence,
                    extendedFingers: {
                        thumb: hand.thumb.extended,
                        indexFinger: hand.indexFinger.extended,
                        middleFinger: hand.middleFinger.extended,
                        ringFinger: hand.ringFinger.extended,
                        pinky: hand.pinky.extended
                    },
                    position: palmPosition,
                    grabStrength: hand.grabStrength,
                    pinchStrength: pinchStrength,
                    pinchingFinger: pinchingFinger,
                    speed: hand.palmVelocity,
                    pitch: hand.pitch,
                    roll: hand.roll,
                    direction: this.roughDirection(hand.palmNormal)
                };
                this.model.hands.push(handModel);
            }

            if (frame.gestures) {
                for (var j = 0; j < frame.gestures.length; j++) {
                    //console.log "Gesture #{gesture.type}"
                    var gesture = frame.gestures[j];
                    var gestureModel = {
                        type: gesture.type,
                        duration: gesture.duration,
                        state: gesture.state
                    };

                    // Gestures
                    if (gesture.type === 'circle') {
                        gestureModel.direction = this.roughDirection(gesture.normal);
                        gestureModel.progress = gesture.progress;
                        this.model.gestures.push(gestureModel);
                    }
                    if (gesture.type === 'swipe') {
                        gestureModel.direction = this.roughDirection(gesture.direction);
                        this.model.gestures.push(gestureModel);
                    }
                }
            }

            //console.log "Model: ", @model
            return this.gestureController.parseGestures(this.model);
        }
    }]);

    return FrameController;
}();
// console.log "Processed frame: ", frame.id
//return

exports.default = FrameController;