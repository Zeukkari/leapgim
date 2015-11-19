#
# Action Controller
#
# Triggers mouse and keyboard actions based on configured recipes. Actions are idempotent operations.
#
execSh = require 'exec-sh'

class ActionController
    constructor:(config, feedback) ->
        @config = config
        @feedback = feedback
        @actions = config.actions
        @recipes = config.recipes
        @robot = require 'robotjs'
        @mouseState = @config.defaultMouseState or 'free' # free|frozen
        @position =
            x: 0
            y: 0
        @freezePosition =
            x: 0
            y: 0
        @unfreezePosition =
            x: 0
            y: 0
        @keyboardModel =
            test: false
        @recipeState = {}
        for name, recipe of @recipes
            @recipeState[name] =
                status: 'inactive'
                timerID: null
            if(recipe.tearDownDelay)
                @recipeState[name].tearDownDelay = recipe.tearDownDelay

    freezeMouse: (handPosition) =>
        @freezePosition = @robot.getMousePos()
        console.log "Freeze mouse", @freezePosition
        @mouseState = 'frozen'

    centerMouse: () =>
        screenSize = @robot.getScreenSize()
        center =
            x: 0.5 * screenSize.width
            y: 0.5 * screenSize.height
        console.log "Center mouse to #{center.x}, #{center.y}"
        @robot.moveMouse(center.x, center.y)

    unfreezeMouse: (handPosition) =>
        screenSize = @robot.getScreenSize()
        normalizedHandPosition =
            x: handPosition.x * screenSize.width
            y: handPosition.y * screenSize.height
        @unfreezePosition = normalizedHandPosition
        console.log "Unfreeze mouse", @unfreezePosition
        @mouseState = 'free'

    toggleMouseFreeze: (handPosition) =>
        if (@mouseState == 'frozen')
            @unfreezeMouse handPosition
        else if(@mouseState == 'free')
            @freezeMouse handPosition

    mouseMove: (handPosition) =>
        console.log "Mouse move ", handPosition
        if(@mouseState == 'free')
            screenSize = @robot.getScreenSize()
            normalizedHandPosition =
                x: handPosition.x * screenSize.width
                y: handPosition.y * screenSize.height
            offsetMapping =
                x: @freezePosition.x - @unfreezePosition.x
                y: @freezePosition.y - @unfreezePosition.y
            moveTo =
                x: normalizedHandPosition.x + offsetMapping.x
                y: normalizedHandPosition.y + offsetMapping.y
            @robot.moveMouse(moveTo.x, moveTo.y)

    # buttonAction: up|down|click|doubleClick, button: left|right
    mouseButton: (buttonAction, button) =>
        if(buttonAction == 'up')
            @robot.mouseToggle buttonAction, button
        else if(buttonAction == 'down')
            @robot.mouseToggle buttonAction, button
        else if(buttonAction == 'click')
            @robot.mouseClick button, false
        else if(buttonAction == 'doubleClick')
            @robot.mouseClick button, true

    # action: up|down|tap
    keyboard: (action, button) =>
        if(action == 'up')
            @robot.keyToggle button, action
        else if(action == 'down')
            @robot.keyToggle button, action
        else if(action == 'tap')
            @robot.keyTap button
        return

    scrollMouse: (direction, magnitude) =>
        if(@mouseState == 'frozen')
            if(direction == 'up' or direction == 'down')
                @robot.scrollMouse(magnitude, direction)
            else
                console.log 'This aint 3d, man!'

    delayMouse: (delay) =>
            @robot.delayMouse(delay)

    execSh: (cmd, options, callback) =>
        execSh cmd, options, callback

    loadProfile: (profile) ->
        console.log "Load profile #{profile}"
        throw "LOAD PROFILE NOT IMPLEMENTED!"

    processFeedback: (cmd) =>
        if(cmd.feedback?)
            if(cmd.feedback.audio?)
                @feedback.audioNotification cmd.feedback.audio
            if(cmd.feedback.visual?)
                options = cmd.feedback.visual
                @feedback.visualNotification options.id, options.msg

    executeAction: (action) =>
        #console.log "Execute action #{action}"

        cmd = @actions[action]
        #console.log "cmd: ", cmd
        screenSize = @robot.getScreenSize()

        # Execute command series
        if(cmd.type == 'compound')
            @executeAction action for action in cmd.actions

        # Execute command
        if(cmd.type == 'exec')
            @processFeedback(cmd)
            @execSh cmd.cmd, cmd.options, (err)->
                if(err)
                    console.log "Exec error", err

        # Change recipe set
        if(cmd.type == 'profile')
            if(cmd.action == 'load')
                @processFeedback(cmd)
                @loadProfile(cmd.target)

        # Change recipe set
        if(cmd.type == 'filler')
            @processFeedback(cmd)

        if(cmd.type == 'mouse')

            # Universal mouse actions
            if(cmd.action == 'toggleFreeze')
                @processFeedback(cmd)
                @toggleMouseFreeze(@position)
            if(cmd.action == 'centerMouse')
                console.log "Center mouse!"
                @processFeedback(cmd)
                @centerMouse()
            if(cmd.action in ['up', 'down', 'click', 'doubleClick'])
                @processFeedback(cmd)
                @mouseButton cmd.action, cmd.target

            # Frozen mouse actions
            if(@mouseState == 'frozen')
                if(cmd.action == 'unfreeze')
                    @processFeedback(cmd)
                    @unfreezeMouse(@position)
                if(cmd.action == 'scroll')
                    @processFeedback(cmd)
                    console.log "Scroll mouse #{cmd.direction}, #{cmd.magnitude}"
                    @scrollMouse cmd.direction, cmd.magnitude
                if(cmd.type == 'keyboard')
                    @processFeedback(cmd)
                    if(cmd.action in ['up', 'down', 'tap'])
                        @keyboard cmd.action, cmd.button

            # Free mouse actions
            if(@mouseState == 'free')
                if(cmd.action == 'move')
                    @mouseMove(@position)
                if(cmd.action == 'freeze')
                    @processFeedback(cmd)
                    @freezeMouse(@position)


    activateRecipe: (recipeName) =>
        recipe = @recipes[recipeName]
        #console.log "recipe data:", recipe
        actionName = recipe.action

        # Skip activation if charging
        if(!@recipeState[recipeName].timerID)
            if(recipe.continuous)
                if(@recipeState[recipeName].status != 'sleeping')
                    if(recipe.chargeDelay)
                        chargeDelay = recipe.chargeDelay
                        #console.log "Recipe #{recipeName} sleeping for #{chargeDelay}"
                        callback = () =>
                            #console.log "Recipe #{recipeName} is awake!"
                            @recipeState[recipeName].status = 'inactive'
                            @recipeState[recipeName].timerID = null
                        @recipeState[recipeName].status = 'sleeping'
                        @recipeState[recipeName].timerID = setTimeout callback, chargeDelay
                    #console.log "activate continuous recipe: ", recipeName
                    @executeAction(actionName)
                    return true
                else
                    #console.log "Recipe #{recipeName} is sleeping..."
                    return false
            else if(@recipeState[recipeName].status == 'inactive')
                if(!@recipeState[recipeName].timerID)
                    #console.log "Activate recipe #{recipeName}"
                    @recipeState[recipeName].status = 'active'
                    @executeAction(actionName)
                    return true
        return false

    tearDownRecipe: (recipeName) =>
        #console.log "Tear down #{recipeName}"
        recipe = @recipes[recipeName]
        return unless recipe
        actionName = recipe.tearDown

        # Apathy!
        if(!actionName)
            #throw "Teardown Action name missing!"
            @recipeState[recipeName].status = 'inactive'
            @recipeState[recipeName].timerID = null
            return false
        if(@recipeState[recipeName].status == 'active')
            if(!@recipeState[recipeName].timerID)
                #console.log "Tear down delay for #{recipeName} is " + @recipeState[recipeName].tearDownDelay
                if(@recipeState[recipeName].tearDownDelay)
                    callback = () =>
                        #console.log "Tear down timed recipe #{recipeName}"
                        @executeAction(actionName)
                        @recipeState[recipeName].status = 'inactive'
                        @recipeState[recipeName].timerID = null
                    @recipeState[recipeName].timerID = setTimeout callback, @recipeState[recipeName].tearDownDelay
                    return true
                else
                    #console.log "Tear down non-timed recipe #{recipeName}"
                    @executeAction(actionName)
                    @recipeState[recipeName].status = 'inactive'
                    @recipeState[recipeName].timerID = null
                    return true
            else
                #console.log "Tear down timer already triggered for #{recipeName}"
                return false
        else
            #console.log "Recipe status is inactive for #{recipeName}"
            return false
        #console.log "How the fuck did I get in here?"

    getActiveRecipes: (filter) =>
        #console.log "get Active recipes.."
        recipeList = []
        for recipeName, recipeState of @recipeState
            recipeStatus = recipeState.status
            #console.log "recipeName: #{recipeName}, recipeState: #{recipeStatus}"
            if(recipeState is 'active')
                if(typeof filter != 'function' or filter(recipeName))
                    recipeList.push recipeName
        return recipeList

if(window)
    window.ActionController = ActionController
