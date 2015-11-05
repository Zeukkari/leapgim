#
# Gesture Controller
#
# Parses signs (leapgim's own gestures) and triggers actions based on recipes.
#

config = window.config

class GestureController
    constructor: ->

        # General state data
        state = {}
        state.lastTimestamp = 0
        state.currentTimestamp = 0
        state.signRecord = {}
        state.recipeRecord = {}
        state.activeSigns = []
        state.lastActiveSigns = []
        #state.status = "Disconnected" # disconnect/connected/something
        state.timeout = window.config.timeout

        # Sign record
        for signName, sign of window.config.signs
            sign.name = signName
            sign.timeVisible = 0
            # Sign status can be active/pending/inactive. A pending status implies that the sign has been visible but not long enough.
            sign.status = 'inactive'
            state.signRecord[signName] = sign
        # Recipe record
        for recipeName, recipe of window.config.recipes
            recipe.name = recipeName
            recipe.timeVisible = 0
            # recipe status can be active/pending/inactive. A pending status implies that the recipe has been visible but not long enough.
            recipe.signIndex = 0
            state.recipeRecord[recipeName] = recipe
        @state = state
        @currentFrame = {}
        window.gestureController = @

    resetSignRecord: (sign) =>
        #console.log "Reset sign #{sign}"
        data = @state.signRecord[sign]
        data.status = 'inactive'
        data.timeVisible = 0

    wipeRecord: () =>
        #console.log "Wiping record.."
        #console.log "ActionHero recipe state: ", window.actionHero.recipeState
        manager = window.actionHero
        for sign of @state.signRecord
            @resetSignRecord sign

        for recipe of @state.recipeRecord
            @state.recipeRecord[recipe].signIndex = 0
            manager.tearDownRecipe recipe



    # Arg1 = sign name
    updateSignRecord: (sign) =>
        #console.log "Update sign #{sign}"
        data = @state.signRecord[sign]
        oldStatus = data.status
        if(@assertSign(data, @state.currentFrame))
            # Sign passes assertion
            if(oldStatus != 'inactive')
                # Update timeVisible
                data.timeVisible += @state.currentTimestamp - @state.lastTimestamp
            if(!data.minTime or data.minTime < data.timeVisible)
                data.status = 'active'
            else
                data.status = 'pending'
        else
            @resetSignRecord sign

    # Arg1 = recipe name
    updateRecipeRecord: (recipe) =>
        #console.log "Update recipe #{recipe}"
        data = @state.recipeRecord[recipe]
        #console.log "data: ", data
        oldIndex = data.signIndex

        #console.log "oldIndex: ", oldIndex

        # Figure out the sign to look for
        sign = data.signs[oldIndex]

        #console.log "sign: ", sign
        #console.log "active signs: ", @state.activeSigns

        if sign in @state.activeSigns
            data.signIndex += 1
        else if(oldIndex > 0)
            secondaryIndex = oldIndex-1
            secondarySign = data.signs[secondaryIndex]
            if secondarySign in @state.activeSigns
                data.signIndex = oldIndex # Keep it as it is..
            else
                data.signIndex = 0
        else
            data.signIndex = 0

        manager = window.actionHero
        #console.info "Data: ", data
        if(data.signIndex == data.signs.length)
            # Activate recipe
            manager.activateRecipe data.name
        else
            # Tear down recipe.. action controller handles extra events
            manager.tearDownRecipe data.name

            # Tear down with timers
            manager.tearDownRecipe data.name

    assertSign: (sign, frameData) =>
        # Assert true unless a filter statement is found
        sign_ok = true

        for handModel in frameData.hands
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
                if(extendedFingers.indexFinger?)
                    if extendedFingers.indexFinger != handModel.extendedFingers.indexFinger
                        sign_ok = false
                if(extendedFingers.middleFinger?)
                    if extendedFingers.middleFinger != handModel.extendedFingers.middleFinger
                        sign_ok = false
                if(extendedFingers.ringFinger?)
                    if extendedFingers.ringFinger != handModel.extendedFingers.ringFinger
                        sign_ok = false
                if(extendedFingers.pinky?)
                    if extendedFingers.pinky != handModel.extendedFingers.pinky
                        sign_ok = false
                if(extendedFingers.thumb?)
                    if extendedFingers.thumb != handModel.extendedFingers.thumb
                        sign_ok = false
        return sign_ok

    getActiveSigns: () =>
        activeSigns = []
        for sign, data of @state.signRecord
            if(data.status == 'active')
                activeSigns.push sign
                if(data.feedback and data.feedback.audio)
                    if(sign not in @state.lastActiveSigns)
                        #console.log "Audio notification #{data.feedback.audio}"
                        window.feedback.audioNotification data.feedback.audio
        return activeSigns

    parseGestures: (model) =>
        #console.log "Parse gestures: ", model
        clearTimeout(@timerID)
        @state.lastActiveSigns = @state.activeSigns

        manager = window.actionHero
        # Update position for mouse movement
        manager.position = model.hands[0].position
        #console.log "Set position: ", manager.position

        # Update timestamps
        @state.lastTimestamp = @state.currentTimestamp
        @state.currentTimestamp = model.timestamp
        # Current frame
        @state.currentFrame = model

        # Process signs
        #console.log "Process signs", @state.signRecord
        for sign of @state.signRecord
            #console.log "Sign: ", sign
            @updateSignRecord(sign)

        # Set active signs
        @state.activeSigns = @getActiveSigns()

        # Process recipes
        #console.log "Process recipes", @state.recipeRecord
        for recipe of @state.recipeRecord
            @updateRecipeRecord(recipe)

        callback = => @wipeRecord()
        delay = window.config.timeout

        #console.log "Callback", callback
        #console.log "Delay: ", delay

        # Set timeout
        @timerID = setTimeout callback, delay

