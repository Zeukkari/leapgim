//
// Gesture Controller
//
// Parses signs (leapgim's own gestures) and triggers actions based on recipes.
//

let manager;
class GestureController {
    constructor(config, feedback, actionController) {
        this.resetSignRecord = this.resetSignRecord.bind(this);
        this.wipeRecord = this.wipeRecord.bind(this);
        this.updateSignRecord = this.updateSignRecord.bind(this);
        this.updateRecipeRecord = this.updateRecipeRecord.bind(this);
        this.assertHand = this.assertHand.bind(this);
        this.assertGesture = this.assertGesture.bind(this);
        this.assertSign = this.assertSign.bind(this);
        this.getActiveSigns = this.getActiveSigns.bind(this);
        this.parseGestures = this.parseGestures.bind(this);
        this.config = config;
        this.feedback = feedback;
        this.actionHero = actionController;
        this.startTime = null;
        // General state data
        let state = {};
        state.lastTimestamp = 0;
        state.currentTimestamp = 0;
        state.signRecord = {};
        state.recipeRecord = {};
        state.activeSigns = [];
        state.lastActiveSigns = [];
        state.timeout = this.config.timeout;

        // Sign record
        for (let signName in this.config.signs) {
            let sign = this.config.signs[signName];
            sign.name = signName;
            sign.timeVisible = 0;
            // Sign status can be active/pending/inactive. A pending status implies that the sign has been visible but not long enough.
            sign.status = 'inactive';
            state.signRecord[signName] = sign;
        }
        // Recipe record
        for (let recipeName in this.config.recipes) {
            let recipe = this.config.recipes[recipeName];
            recipe.name = recipeName;
            recipe.timeVisible = 0;
            // recipe status can be active/pending/inactive. A pending status implies that the recipe has been visible but not long enough.
            recipe.signIndex = 0;
            state.recipeRecord[recipeName] = recipe;
        }
        this.state = state;
        this.currentFrame = {};
    }

    resetSignRecord(sign) {
        //console.log "Reset sign #{sign}"
        let data = this.state.signRecord[sign];
        data.status = 'inactive';
        return data.timeVisible = 0;
    }

    wipeRecord() {
        console.log("Wiping record..");
        //console.log "ActionHero recipe state: ", window.actionHero.recipeState
        
      let signRecord = this.state.signRecord;
      for(let sign in signRecord) {
        this.resetSignRecord(sign);
      }
      
      let recipeRecord = this.state.recipeRecord;
      for(let recipe in recipeRecord) {
        this.state.recipeRecord[recipe].signIndex = 0;
        this.actionHero.tearDownRecipe(recipe);
      }
    }
//        for sign of @state.signRecord
//            @resetSignRecord sign
//
//        for recipe of @state.recipeRecord
//            @state.recipeRecord[recipe].signIndex = 0
//            manager.tearDownRecipe recipe

    // Arg1 = sign name
    updateSignRecord(sign) {
        //console.log "Update sign #{sign}"
        let data = this.state.signRecord[sign];
        let oldStatus = data.status;
        //console.log "Assert sign", data
        if(this.assertSign(data, this.state.currentFrame)) {
            // Sign passes assertion
            if(oldStatus !== 'inactive') {
                // Update timeVisible
                data.timeVisible += this.state.currentTimestamp - this.state.lastTimestamp;
            }
            if(!data.minTime || data.minTime < data.timeVisible) {
                return data.status = 'active';
            } else {
                return data.status = 'pending';
            }
        } else {
            return this.resetSignRecord(sign);
        }
    }

    // Arg1 = recipe name
    updateRecipeRecord(recipe) {
        //console.log "Update recipe #{recipe}"
        let data = this.state.recipeRecord[recipe];
        //console.log "data: ", data
        let oldIndex = data.signIndex;

        //console.log "oldIndex: ", oldIndex

        // Figure out the sign to look for
        let sign = data.signs[oldIndex];

        //console.log "sign: ", sign
        //console.log "active signs: ", @state.activeSigns

        if (__in__(sign, this.state.activeSigns)) {
            data.signIndex += 1;
        } else if(oldIndex > 0) {
            let secondaryIndex = oldIndex-1;
            let secondarySign = data.signs[secondaryIndex];
            if (__in__(secondarySign, this.state.activeSigns)) {
                data.signIndex = oldIndex; // Keep it as it is..
            } else {
                data.signIndex = 0;
            }
        } else {
            data.signIndex = 0;
        }

        let manager = this.actionHero;
        //console.info "Data: ", data
        if(data.signIndex === data.signs.length) {
            // Activate recipe
            return manager.activateRecipe(data.name);
        } else {
            // Tear down recipe.. action controller handles extra events
            manager.tearDownRecipe(data.name);

            // Tear down with timers
            return manager.tearDownRecipe(data.name);
        }
    }

    assertHand(sign, handModel) {
        let sign_ok = true;
        if(sign.grab) {
            let { grabStrength } = handModel;
            if(sign.grab.min) {
                if(grabStrength < sign.grab.min) {
                    sign_ok = false;
                }
            }
            if(sign.grab.max) {
                if(grabStrength > sign.grab.max) {
                    sign_ok = false;
                }
            }
        }
        if(sign.pinch) {
            let { pinchStrength } = handModel;
            let pincher = handModel.pinchingFinger;

            if(sign.pinch.pincher) {
                if (sign.pinch.pincher !== pincher) {
                    sign_ok = false;
                }
            }
            if(sign.pinch.min) {
                if(pinchStrength < sign.pinch.min) {
                    sign_ok = false;
                }
            }
            if(sign.pinch.max) {
                if(pinchStrength > sign.pinch.max) {
                    sign_ok = false;
                }
            }
        }
        if(sign.extendedFingers) {
            let { extendedFingers } = sign;
            if(extendedFingers.indexFinger != null) {
                if (extendedFingers.indexFinger !== handModel.extendedFingers.indexFinger) {
                    sign_ok = false;
                }
            }
            if(extendedFingers.middleFinger != null) {
                if (extendedFingers.middleFinger !== handModel.extendedFingers.middleFinger) {
                    sign_ok = false;
                }
            }
            if(extendedFingers.ringFinger != null) {
                if (extendedFingers.ringFinger !== handModel.extendedFingers.ringFinger) {
                    sign_ok = false;
                }
            }
            if(extendedFingers.pinky != null) {
                if (extendedFingers.pinky !== handModel.extendedFingers.pinky) {
                    sign_ok = false;
                }
            }
            if(extendedFingers.thumb != null) {
                if (extendedFingers.thumb !== handModel.extendedFingers.thumb) {
                    sign_ok = false;
                }
            }
        }
        if (sign.hover) {
            if (sign.hover.left != null) {
                if (hand.type === !'left' && sign.hover.left === true) {
                    sign_ok = false;
                }
            }
            if (sign.hover.minTime != null) {
                if (sign.hover.minTime > hand.timeVisible) {
                    sign_ok = false;
                }
            }
        }

        if (sign.direction) {
            if (sign.direction !== handModel.direction) {
                sign_ok = false;
            }
        }

        return sign_ok;
    }


    assertGesture(sign, gestureData) {
        if (sign.circle) {
            if (gestureData.type !== 'circle') {
                return false;
            }
            if (sign.circle.direction != null) {
                if (gestureData.direction !== sign.circle.direction) {
                    return false;
                }
            }
            //if sign.circle.progress?.min?
            if (sign && sign.circle && sign.circle.progress && sign.circle.progress.min) {
                if (sign.circle.progress.min > gestureData.progress) {
                    return false;
                }
            }
            //if sign.circle.progress?.max?
            if (sign && sign.circle && sign.circle.progress && sign.circle.progress.max) {
                if (sign.circle.progress.max < gestureData.progress) {
                    return false;
                }
            }
            //if sign.circle.duration?.min?
            if (sign && sign.circle && sign.circle.duration && sign.circle.duration.min) {
                if (sign.circle.duration.min > gestureData.duration) {
                    return false;
                }
            }
            //if sign.circle.duration?.max?
            if (sign && sign.circle && sign.circle.duration && sign.circle.duration.max) {
                if (sign.circle.duration.max < gestureData.duration) {
                    return false;
                }
            }
        }
        return true;
    }

    assertSign(sign, frameData) {
        // Assert true unless a filter statement is found
        let sign_ok = true;

        let hand_spotted = false;
        for (let i = 0; i < frameData.hands.length; i++) {
            let handModel = frameData.hands[i];
            let hand_ok = this.assertHand(sign, handModel);
            if(hand_ok) {
                hand_spotted = true;
            }
        }
        if(!hand_spotted) {
            sign_ok = false;
        }

        if(sign.circle || sign.swipe) {
            if(frameData.gestures.length === 0) {
                sign_ok = false;
            }
            let gesture_spotted = false;
            for (let j = 0; j < frameData.gestures.length; j++) {
                let gestureModel = frameData.gestures[j];
                let gesture_ok = this.assertGesture(sign, gestureModel);
                if (gesture_ok) { gesture_spotted = true; }
            }
            if(!gesture_spotted) {
                sign_ok = false;
            }
        }

        return sign_ok;
    }

    getActiveSigns() {
        let activeSigns = [];
        for (let sign in this.state.signRecord) {
            let data = this.state.signRecord[sign];
            if(data.status === 'active') {
                activeSigns.push(sign);
                //if(data.feedback?.audio)
                if( data.feedback && data.feedback.audio ) {
                    if(!__in__(sign, this.state.lastActiveSigns)) {
                        //console.log "Audio notification #{data.feedback.audio}"
                        this.feedback.audioNotification(data.feedback.audio);
                    }
                }
                //if(data.feedback?.visual?)
                if( data.feedback && data.feedback.visual ) {
                    let options = data.feedback.visual;
                    this.feedback.visualNotification(options.id, options.msg);
                }
            }
        }

        return activeSigns;
    }

    parseGestures(model) {
        //console.log "Parse gestures: ", model
        clearTimeout(this.timerID);
        this.state.lastActiveSigns = this.state.activeSigns;

        let manager = this.actionHero;
        // Update position for mouse movement
        manager.position = model.hands[0].position;
        //console.log "Set position: ", manager.position

        // Update timestamps
        this.state.lastTimestamp = this.state.currentTimestamp;
        this.state.currentTimestamp = model.timestamp;
        // Current frame
        this.state.currentFrame = model;

        if (!this.startTime) {
            this.startTime = model.timestamp;
        } else {
            this.currentTotalTime = model.timestamp;
        }

        // Overall time elapsed in ms since the start
        let elapsedMS = this.currentTotalTime - this.startTime;
        let elapsedSeconds = elapsedMS / 1000000;

        this.feedback.time(elapsedSeconds);

        let { visible } = model.hands[0];

        this.feedback.handVisible(visible);

        let { confidence } = model.hands[0];

        this.feedback.confidenceMeter(confidence);

        // Process signs
        //console.log "Process signs", @state.signRecord
        for (let sign in this.state.signRecord) {
            //console.log "Sign: ", sign
            this.updateSignRecord(sign);
        }

        // Set active signs
        this.state.activeSigns = this.getActiveSigns();

        // Process recipes
        //console.log "Process recipes", @state.recipeRecord
        for (let recipe in this.state.recipeRecord) {
            this.updateRecipeRecord(recipe);
        }

        let callback = () => this.wipeRecord();
        let delay = this.config.timeout;

        //console.log "Callback", callback
        //console.log "Delay: ", delay

        // Set timeout
        return this.timerID = setTimeout(callback, delay);
    }
}

export default GestureController;
function __in__(needle, haystack) {
  return haystack.indexOf(needle) >= 0;
}