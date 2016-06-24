import Leap from 'leapjs';

// A map to convert Finger type codes into descriptive names
const nameMap  = [
    'thumb',
    'indexFinger',
    'middleFinger',
    'ringFinger',
    'pinky'
];

// Frame controller recieves leap frame data from leapd and parses it into a
// structured format we'll use later to configure gestures with
class FrameController { // extends EventEmitter

    constructor(config, gestureController){
        this.findPinchingFingerType = this.findPinchingFingerType.bind(this);
        this.processFrame = this.processFrame.bind(this);
        this.model = [];
        this.config = config;
        this.gestureController = gestureController;
        console.log("Frame Controller initialized");
    }

    // TODO: return an array of pinching fingers if two fingers are both
    // sufficiently close to the thumb.
    findPinchingFingerType(hand) {
        let pincher = undefined;
        let closest = 500;
        let f = 1;
        while (f < 5) {
            let current = hand.fingers[f];
            let distance = Leap.vec3.distance(hand.thumb.tipPosition, current.tipPosition);
            if (current !== hand.thumb && distance < closest) {
                closest = distance;
                pincher = current;
            }
            f++;
        }
        let pincherName = nameMap[pincher.type];
        // console.log "Pincher type: ", pincher.type
        // console.log "Pincher: " + pincherName
        return pincherName;
    }

    /*
     * Produce x and y coordinates for a leap pointable.
     */

    relative3DPosition(frame, leapPoint) {
        let iBox = frame.interactionBox;
        let normalizedPoint = iBox.normalizePoint(leapPoint, false);

        // Translate coordinates so that origin is in the top left corner
        let x = normalizedPoint[0];
        let y = 1 - (normalizedPoint[1]);
        let z = normalizedPoint[2];

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
            x,
            y,
            z
        };
    }

    roughDirection(normalVector) {
        if(normalVector == null) {
            return false;
        }

        if(normalVector.length !== 3) {
            return false;
        }

        let vectorX = normalVector[0];
        let vectorY = normalVector[1];
        let vectorZ = normalVector[2];
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

    processFrame(frame) {
        console.log("Processing frame..." + frame.id);
        //console.log(frame);

        if (!frame.valid || frame.hands === null || frame.hands.length === 0) {
            //console.log("Invalid frame or no hands detected");
            return;
        }
        this.model = {
            hands : [],
            gestures : [],
            timestamp : frame.timestamp
        };
            //pointables : []
        for (let i = 0; i < frame.hands.length; i++) {
            let hand = frame.hands[i];
            if(this.config.stabilize) {
                var position = hand.stabilizedPalmPosition;
            } else {
                var position = hand.palmPosition;
            }
            let palmPosition = this.relative3DPosition(frame, position);

            let { pinchStrength } = hand;
            if (pinchStrength > 0) {
                var pinchingFinger = this.findPinchingFingerType(hand);
            } else {
                var pinchingFinger = null;
            }

            let handModel = {
                type : hand.type,
                visible : hand.timeVisible,
                confidence : hand.confidence,
                extendedFingers: {
                    thumb : hand.thumb.extended,
                    indexFinger : hand.indexFinger.extended,
                    middleFinger : hand.middleFinger.extended,
                    ringFinger : hand.ringFinger.extended,
                    pinky : hand.pinky.extended
                },
                position: palmPosition,
                grabStrength : hand.grabStrength,
                pinchStrength,
                pinchingFinger,
                speed : hand.palmVelocity,
                pitch : hand.pitch,
                roll  : hand.roll,
                direction : this.roughDirection(hand.palmNormal)
            };
            this.model.hands.push(handModel);
        }


        if(frame.gestures) {
            for (let j = 0; j < frame.gestures.length; j++) {
                //console.log "Gesture #{gesture.type}"
                let gesture = frame.gestures[j];
                let gestureModel = {
                    type : gesture.type,
                    duration : gesture.duration,
                    state : gesture.state
                };

                // Gestures
                if(gesture.type === 'circle') {
                    gestureModel.direction = this.roughDirection(gesture.normal);
                    gestureModel.progress = gesture.progress;
                    this.model.gestures.push(gestureModel);
                }
                if(gesture.type === 'swipe') {
                    gestureModel.direction = this.roughDirection(gesture.direction);
                    this.model.gestures.push(gestureModel);
                }
            }
        }

        //console.log "Model: ", @model
        return this.gestureController.parseGestures(this.model);
    }
}
        // console.log "Processed frame: ", frame.id
        //return

export default FrameController;