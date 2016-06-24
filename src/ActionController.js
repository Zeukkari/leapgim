//
// Action Controller
//
// Triggers mouse and keyboard actions based on configured recipes. Actions are idempotent operations.
//
import execSh from 'exec-sh';

class ActionController {
    constructor(config, feedback) {
        this.freezeMouse = this.freezeMouse.bind(this);
        this.centerMouse = this.centerMouse.bind(this);
        this.unfreezeMouse = this.unfreezeMouse.bind(this);
        this.toggleMouseFreeze = this.toggleMouseFreeze.bind(this);
        this.mouseMove = this.mouseMove.bind(this);
        this.mouseButton = this.mouseButton.bind(this);
        this.keyboard = this.keyboard.bind(this);
        this.scrollMouse = this.scrollMouse.bind(this);
        this.delayMouse = this.delayMouse.bind(this);
        this.execSh = this.execSh.bind(this);
        this.processFeedback = this.processFeedback.bind(this);
        this.executeAction = this.executeAction.bind(this);
        this.activateRecipe = this.activateRecipe.bind(this);
        this.tearDownRecipe = this.tearDownRecipe.bind(this);
        this.getActiveRecipes = this.getActiveRecipes.bind(this);
        this.config = config;
        this.feedback = feedback;
        this.actions = config.actions;
        this.recipes = config.recipes;
        this.robot = require('robotjs');
        this.mouseState = this.config.defaultMouseState || 'free'; // free|frozen
        this.position = {
            x: 0,
            y: 0
        };
        this.freezePosition = {
            x: 0,
            y: 0
        };
        this.unfreezePosition = {
            x: 0,
            y: 0
        };
        this.recipeState = {};
        for (let name in this.recipes) {
            let recipe = this.recipes[name];
            this.recipeState[name] = {
                status: 'inactive',
                timerID: null
            };
            if(recipe.tearDownDelay) {
                this.recipeState[name].tearDownDelay = recipe.tearDownDelay;
            }
        }
    }

    freezeMouse(handPosition) {
        this.freezePosition = this.robot.getMousePos();
        console.log("Freeze mouse", this.freezePosition);
        return this.mouseState = 'frozen';
    }

    centerMouse() {
        let screenSize = this.robot.getScreenSize();
        let center = {
            x: 0.5 * screenSize.width,
            y: 0.5 * screenSize.height
        };
        console.log(`Center mouse to ${center.x}, ${center.y}`);
        return this.robot.moveMouse(center.x, center.y);
    }

    unfreezeMouse(handPosition) {
        let screenSize = this.robot.getScreenSize();
        let normalizedHandPosition = {
            x: handPosition.x * screenSize.width,
            y: handPosition.y * screenSize.height
        };
        this.unfreezePosition = normalizedHandPosition;
        console.log("Unfreeze mouse", this.unfreezePosition);
        return this.mouseState = 'free';
    }

    toggleMouseFreeze(handPosition) {
        if (this.mouseState === 'frozen') {
            return this.unfreezeMouse(handPosition);
        } else if(this.mouseState === 'free') {
            return this.freezeMouse(handPosition);
        }
    }

    mouseMove(handPosition) {
        if(this.mouseState === 'free') {
            let screenSize = this.robot.getScreenSize();
            let normalizedHandPosition = {
                x: handPosition.x * screenSize.width,
                y: handPosition.y * screenSize.height
            };
            let offsetMapping = {
                x: this.freezePosition.x - this.unfreezePosition.x,
                y: this.freezePosition.y - this.unfreezePosition.y
            };
            let moveTo = {
                x: normalizedHandPosition.x + offsetMapping.x,
                y: normalizedHandPosition.y + offsetMapping.y
            };
            return this.robot.moveMouse(moveTo.x, moveTo.y);
        }
    }

    // buttonAction: up|down|click|doubleClick, button: left|right
    mouseButton(buttonAction, button) {
        if(buttonAction === 'up') {
            return this.robot.mouseToggle(buttonAction, button);
        } else if(buttonAction === 'down') {
            return this.robot.mouseToggle(buttonAction, button);
        } else if(buttonAction === 'click') {
            return this.robot.mouseClick(button, false);
        } else if(buttonAction === 'doubleClick') {
            return this.robot.mouseClick(button, true);
        }
    }

    // action: up|down|tap
    keyboard(action, button) {
        if(action === 'up') {
            this.robot.keyToggle(button, action);
        } else if(action === 'down') {
            this.robot.keyToggle(button, action);
        } else if(action === 'tap') {
            this.robot.keyTap(button);
        }
        return;
    }

    scrollMouse(direction, magnitude) {
        if(this.mouseState === 'frozen') {
            if(direction === 'up' || direction === 'down') {
                return this.robot.scrollMouse(magnitude, direction);
            } else {
                return console.log('This aint 3d, man!');
            }
        }
    }

    delayMouse(delay) {
            return this.robot.delayMouse(delay);
        }

    execSh(cmd, options, callback) {
        return execSh(cmd, options, callback);
    }

    loadProfile(profile) {
        console.log(`Load profile ${profile}`);
        throw "LOAD PROFILE NOT IMPLEMENTED!";
    }

    processFeedback(cmd) {
        if(cmd.feedback != null) {
            if(cmd.feedback.audio != null) {
                this.feedback.audioNotification(cmd.feedback.audio);
            }
            if(cmd.feedback.visual != null) {
                let options = cmd.feedback.visual;
                return this.feedback.visualNotification(options.id, options.msg);
            }
        }
    }

    executeAction(action) {
        //console.log "Execute action #{action}"

        let cmd = this.actions[action];

        // Skip frames based on mouse state
        if(cmd.mouseState) {
            if(this.mouseState !== cmd.mouseState) {
                return false;
            }
        }

        //console.log "cmd: ", cmd
        let screenSize = this.robot.getScreenSize();

        // Execute command series
        if(cmd.type === 'compound') {
            for (let i = 0; i < cmd.actions.length; i++) { action = cmd.actions[i];             this.executeAction(action); }
        }

        // Execute command
        if(cmd.type === 'exec') {
            this.processFeedback(cmd);
            this.execSh(cmd.cmd, cmd.options, function(err){
                if(err) {
                    return console.log("Exec error", err);
                }
            });
        }

        // Change recipe set
        if(cmd.type === 'profile') {
            if(cmd.action === 'load') {
                this.processFeedback(cmd);
                this.loadProfile(cmd.target);
            }
        }

        // Change recipe set
        if(cmd.type === 'filler') {
            this.processFeedback(cmd);
        }

        if(cmd.type === 'keyboard') {
            console.log(`Key ${cmd.target} action ${cmd.action}`);
            this.processFeedback(cmd);
            if(cmd.action === 'down') {
                this.robot.keyToggle(cmd.target, 'down');
            }
            if(cmd.action === 'up') {
                this.robot.keyToggle(cmd.target, 'up');
            }
            if(cmd.action === 'tap') {
                this.robot.keyTap(cmd.target);
            }
        }

        if(cmd.type === 'mouse') {

            // Universal mouse actions
            if(cmd.action === 'toggleFreeze') {
                this.processFeedback(cmd);
                this.toggleMouseFreeze(this.position);
            }
            if(cmd.action === 'centerMouse') {
                console.log("Center mouse!");
                this.processFeedback(cmd);
                this.centerMouse();
            }
            if(__in__(cmd.action, ['up', 'down', 'click', 'doubleClick'])) {
                this.processFeedback(cmd);
                this.mouseButton(cmd.action, cmd.target);
            }
            if(cmd.action === 'unfreeze') {
                this.processFeedback(cmd);
                this.unfreezeMouse(this.position);
            }
            if(cmd.action === 'scroll') {
                this.processFeedback(cmd);
                this.scrollMouse(cmd.direction, cmd.magnitude);
            }
            if(cmd.type === 'keyboard') {
                this.processFeedback(cmd);
                if(__in__(cmd.action, ['up', 'down', 'tap'])) {
                    this.keyboard(cmd.action, cmd.button);
                }
            }
            if(cmd.action === 'move') {
                this.mouseMove(this.position);
            }
            if(cmd.action === 'freeze') {
                this.processFeedback(cmd);
                return this.freezeMouse(this.position);
            }
        }
    }


    activateRecipe(recipeName) {
        let recipe = this.recipes[recipeName];
        //console.log "recipe data:", recipe
        let actionName = recipe.action;

        // Skip activation if charging
        if(!this.recipeState[recipeName].timerID) {
            if(recipe.continuous) {
                if(this.recipeState[recipeName].status !== 'sleeping') {
                    if(recipe.chargeDelay) {
                        let { chargeDelay } = recipe;
                        //console.log "Recipe #{recipeName} sleeping for #{chargeDelay}"
                        let callback = () => {
                            //console.log "Recipe #{recipeName} is awake!"
                            this.recipeState[recipeName].status = 'inactive';
                            return this.recipeState[recipeName].timerID = null;
                        };
                        this.recipeState[recipeName].status = 'sleeping';
                        this.recipeState[recipeName].timerID = setTimeout(callback, chargeDelay);
                    }
                    //console.log "activate continuous recipe: ", recipeName
                    this.executeAction(actionName);
                    return true;
                } else {
                    //console.log "Recipe #{recipeName} is sleeping..."
                    return false;
                }
            } else if(this.recipeState[recipeName].status === 'inactive') {
                if(!this.recipeState[recipeName].timerID) {
                    //console.log "Activate recipe #{recipeName}"
                    this.recipeState[recipeName].status = 'active';
                    this.executeAction(actionName);
                    return true;
                }
            }
        }
        return false;
    }

    tearDownRecipe(recipeName) {
        //console.log "Tear down #{recipeName}"
        let recipe = this.recipes[recipeName];
        if (!recipe) { return; }
        let actionName = recipe.tearDown;

        // Apathy!
        if(!actionName) {
            //throw "Teardown Action name missing!"
            this.recipeState[recipeName].status = 'inactive';
            this.recipeState[recipeName].timerID = null;
            return false;
        }
        if(this.recipeState[recipeName].status === 'active') {
            if(!this.recipeState[recipeName].timerID) {
                //console.log "Tear down delay for #{recipeName} is " + @recipeState[recipeName].tearDownDelay
                if(this.recipeState[recipeName].tearDownDelay) {
                    let callback = () => {
                        //console.log "Tear down timed recipe #{recipeName}"
                        this.executeAction(actionName);
                        this.recipeState[recipeName].status = 'inactive';
                        return this.recipeState[recipeName].timerID = null;
                    };
                    this.recipeState[recipeName].timerID = setTimeout(callback, this.recipeState[recipeName].tearDownDelay);
                    return true;
                } else {
                    //console.log "Tear down non-timed recipe #{recipeName}"
                    this.executeAction(actionName);
                    this.recipeState[recipeName].status = 'inactive';
                    this.recipeState[recipeName].timerID = null;
                    return true;
                }
            } else {
                //console.log "Tear down timer already triggered for #{recipeName}"
                return false;
            }
        } else {
            //console.log "Recipe status is inactive for #{recipeName}"
            return false;
        }
    }
        //console.log "How the fuck did I get in here?"

    getActiveRecipes(filter) {
        //console.log "get Active recipes.."
        let recipeList = [];
        for (let recipeName in this.recipeState) {
            let recipeState = this.recipeState[recipeName];
            let recipeStatus = recipeState.status;
            //console.log "recipeName: #{recipeName}, recipeState: #{recipeStatus}"
            if(recipeState === 'active') {
                if(typeof filter !== 'function' || filter(recipeName)) {
                    recipeList.push(recipeName);
                }
            }
        }
        return recipeList;
    }
}

export default ActionController;
function __in__(needle, haystack) {
  return haystack.indexOf(needle) >= 0;
}