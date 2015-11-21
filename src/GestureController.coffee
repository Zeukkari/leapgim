#
# Gesture Controller
#
# Parses signs (leapgim's own gestures) and triggers actions based on recipes.
#

class GestureController
    constructor: (config, feedback, actionController) ->
        @config = config
        @feedback = feedback
        @actionHero = actionController
        @startTime = null
        # General state data
        state = {}
        state.lastTimestamp = 0
        state.currentTimestamp = 0
        state.signRecord = {}
        state.recipeRecord = {}
        state.activeSigns = []
        state.lastActiveSigns = []
        state.timeout = @config.timeout

        # Sign record
        for signName, sign of @config.signs
            sign.name = signName
            sign.timeVisible = 0
            # Sign status can be active/pending/inactive. A pending status implies that the sign has been visible but not long enough.
            sign.status = 'inactive'
            state.signRecord[signName] = sign
        # Recipe record
        for recipeName, recipe of @config.recipes
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
        manager = @actionHero
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
        #console.log "Assert sign", data
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

        manager = @actionHero
        #console.info "Data: ", data
        if(data.signIndex == data.signs.length)
            # Activate recipe
            manager.activateRecipe data.name
        else
            # Tear down recipe.. action controller handles extra events
            manager.tearDownRecipe data.name

            # Tear down with timers
            manager.tearDownRecipe data.name

    assertHand: (sign, handModel) =>
        sign_ok = true
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
        if sign.hover
            if sign.hover.left?
                if hand.type is not 'left' and sign.hover.left is true
                    sign_ok = false
            if sign.hover.minTime?
                if sign.hover.minTime > hand.timeVisible
                    sign_ok = false

        if sign.direction
            if sign.direction != handModel.direction
                sign_ok = false

        return sign_ok


    assertGesture: (sign, gestureData) =>
        if sign.circle
            if gestureData.type != 'circle'
                return false
            if sign.circle.direction?
                if gestureData.direction != sign.circle.direction
                    return false
            if sign.circle.progress?.min?
                if sign.circle.progress.min > gestureData.progress
                    return false
            if sign.circle.progress?.max?
                if sign.circle.progress.max < gestureData.progress
                    return false
            if sign.circle.duration?.min?
                if sign.circle.duration.min > gestureData.duration
                    return false
            if sign.circle.duration?.max?
                if sign.circle.duration.max < gestureData.duration
                    return false
        return true

    assertSign: (sign, frameData) =>
        # Assert true unless a filter statement is found
        sign_ok = true

        hand_spotted = false
        for handModel in frameData.hands
            hand_ok = @assertHand sign, handModel
            if(hand_ok)
                hand_spotted = true
        if(!hand_spotted)
            sign_ok = false

        if(sign.circle or sign.swipe)
            if(frameData.gestures.length == 0)
                sign_ok = false
            gesture_spotted = false
            for gestureModel in frameData.gestures
                gesture_ok = @assertGesture sign, gestureModel
                if gesture_ok then gesture_spotted = true
            if(!gesture_spotted)
                sign_ok = false

        return sign_ok

    getActiveSigns: () =>
        activeSigns = []
        for sign, data of @state.signRecord
            if(data.status == 'active')
                activeSigns.push sign
                if(data.feedback?.audio)
                    if(sign not in @state.lastActiveSigns)
                        #console.log "Audio notification #{data.feedback.audio}"
                        @feedback.audioNotification data.feedback.audio
                if(data.feedback?.visual?)
                    options = data.feedback.visual
                    @feedback.visualNotification options.id, options.msg

        return activeSigns

    parseGestures: (model) =>
        #console.log "Parse gestures: ", model
        clearTimeout(@timerID)
        @state.lastActiveSigns = @state.activeSigns

        manager = @actionHero
        # Update position for mouse movement
        manager.position = model.hands[0].position
        #console.log "Set position: ", manager.position

        # Update timestamps
        @state.lastTimestamp = @state.currentTimestamp
        @state.currentTimestamp = model.timestamp
        # Current frame
        @state.currentFrame = model

        if !@startTime
            @startTime = model.timestamp
        else
            @currentTotalTime = model.timestamp

        # Overall time elapsed in ms since the start
        elapsedMS = @currentTotalTime - @startTime
        elapsedSeconds = elapsedMS / 1000000

        @feedback.time elapsedSeconds

        visible = model.hands[0].visible

        @feedback.handVisible visible

        confidence = model.hands[0].confidence

        @feedback.confidenceMeter confidence

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
        delay = @config.timeout

        #console.log "Callback", callback
        #console.log "Delay: ", delay

        # Set timeout
        @timerID = setTimeout callback, delay

if(window)
    window.GestureController = GestureController
