#
# Gesture Controller
#
# Parses signs (leapgim's own gestures) and triggers actions based on recipes.
#

config = window.config
manager = window.actionHero

class GestureController
    constructor: ->
        @signs = window.config.signs
        @recipes = window.config.recipes
        # Milliseconds. Release mouse buttons if no new data is received during this time frame.
        #@timeout = config.timeout
        @tearDownQueue = []


    assertSign: (sign, frameData) =>

        #console.log "Assert sign: ", sign, frameData

        # Assert true unless a filter statement is found
        sign_ok = true

        for handModel in frameData.hands
            #console.log "handModel: ", handModel
            if(sign.grab)
                grabStrength = handModel.grabStrength
                if(sign.grab.min)
                    if(grabStrength < sign.grab.min)
                        sign_ok = false
                if(sign.grab.max)
                    if(grabStrength > sign.grab.max)
                        sign_ok = false
            if(sign.pinch)
                pinchStrength = handModel.pinchStrength
                pincher = handModel.pinchingFinger

                if(sign.pinch.pincher)
                    if (sign.pinch.pincher != pincher)
                        sign_ok = false
                if(sign.pinch.min)
                    if(pinchStrength < sign.pinch.min)
                        sign_ok = false
                if(sign.pinch.max)
                    if(pinchStrength > sign.pinch.max)
                        sign_ok = false
            if(sign.extendedFingers)
                extendedFingers = sign.extendedFingers
                if(extendedFingers.indexFinger is not undefined)
                    if extendedFingers.indexFinger != handModel.extendedFingers.indexFinger
                        sign_ok = false
                if(extendedFingers.middleFinger is not undefined)
                    if extendedFingers.middleFinger != handModel.extendedFingers.middleFinger
                        sign_ok = false
                if(extendedFingers.ringFinger is not undefined)
                    if extendedFingers.ringFinger != handModel.extendedFingers.ringFinger
                        sign_ok = false
                if(extendedFingers.pinky is not undefined)
                    if extendedFingers.pinky != handModel.extendedFingers.ringFinger
                        sign_ok = false
                if(extendedFingers.thumb is not undefined)
                    if extendedFingers.thumb != handModel.extendedFingers.thumb
                        sign_ok = false
        return sign_ok

    parseGestures: (model) =>

        console.log "Parsing gestures.."
        console.log "model: ", model
        #console.log "config.signs: ", config.signs

        # Mouse tracking quick'n'dirty
        manager = window.actionHero
        manager.position = model.hands[0].position
        console.log "Position: ", manager.position

        #@timestamp = model.timestamp
        # TODO: Implement processSign and properly figure out this shit
        # Timeout handling
        #if(@timer)
        #    clearTimeout(@timer)
        #@timer = setTimeout()

        validSigns = []

        console.log "signs: ", @signs
        console.log "recipes: ", @recipes

        # This is defunct after refactoring.. why?
        for signName,signData of @signs
            console.log "Sign name: " + signName
            console.log "Sign data: " + signData
            console.log "Assert " + signName
            if(@assertSign(signData, model))
                console.log "Assert ok for " + signName
                validSigns.push signName

        # TODO: Figure out tear down mechanism

        for recipeName, recipe of @recipes
            if(recipe.sign in validSigns)
                console.log "Trigger recipe action: " + recipe.action
                #console.log "Config actions: ", config.actions
                #action = config.actions[recipe.action]
                #console.log "Interpolated: ", action
                manager = window.actionHero
                manager.executeAction(recipe.action)
                #@tearDownQueue.push(action.tearDown)


window.GestureController = GestureController