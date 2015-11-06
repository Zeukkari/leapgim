#
# Action Controller
#
# Triggers mouse and keyboard actions based on configured recipes. Actions are idempotent operations.
#
execSh = require 'exec-sh'

feedback = window.feedback
config = window.config


class ActionController
    constructor: ->
        @actions = window.config.actions
        @recipes = window.config.recipes
        @robot = require 'robotjs'
        @mouseState = 'free' # free|frozen
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
<<<<<<< HEAD
=======
        #console.log "Freeze mouse", @freezePosition
>>>>>>> cf25dea83d37f449eeec8024a98d876b95485f86
        @mouseState = 'frozen'

    unfreezeMouse: (handPosition) =>
        screenSize = @robot.getScreenSize()
        normalizedHandPosition =
            x: handPosition.x * screenSize.width
            y: handPosition.y * screenSize.height
        @unfreezePosition = normalizedHandPosition
<<<<<<< HEAD
        console.log "Unfreeze mouse", @unfreezePosition
=======
>>>>>>> cf25dea83d37f449eeec8024a98d876b95485f86
        @mouseState = 'free'

    toggleMouseFreeze: (handPosition) =>
        if (@mouseState == 'frozen')
            @unfreezeMouse handPosition
        else if(@mouseState == 'free')
            @freezeMouse handPosition

    mouseMove: (handPosition) =>
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
        feedback = window.feedback
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
        feedback = window.feedback
        if(action == 'up')
            @robot.keyToggle button, action
        else if(action == 'down')
            @robot.keyToggle button, action
        else if(action == 'tap')
            @robot.keyTap button
        return

    scrollMouse: (direction, magnitude) =>
        if(direction == 'up' or direction == 'down')
            @robot.scrollMouse(magnitude, direction)
        else
            console.log 'This aint 3d, man!'

<<<<<<< HEAD
    delayMouse: (delay) =>
            @robot.delayMouse(delay)
=======
    execSh: (cmd, options, callback) =>
        execSh cmd, options, callback

    loadProfile: (profile) ->
        console.log "Load profile #{profile}"
        window.loadProfile(profile)
>>>>>>> cf25dea83d37f449eeec8024a98d876b95485f86

    executeAction: (action) =>
        cmd = @actions[action]
        # console.log "cmd: ", cmd
<<<<<<< HEAD
=======
        screenSize = @robot.getScreenSize()

>>>>>>> cf25dea83d37f449eeec8024a98d876b95485f86
        if(cmd.feedback?)
            if(cmd.feedback.audio?)
                window.feedback.audioNotification cmd.feedback.audio
            if(cmd.feedback.visual?)
                options = cmd.feedback.visual
                window.feedback.visualNotification options.id, options.msg

        if(cmd.type == 'mouse')
            if(cmd.action == 'freeze')
                @freezeMouse(@position)
            if(cmd.action == 'unfreeze')
                @unfreezeMouse(@position)
            if(cmd.action == 'toggleFreeze')
                @toggleMouseFreeze(@position)
            if(cmd.action in ['up', 'down', 'click', 'doubleClick'])
                @mouseButton cmd.action, cmd.target
            if(cmd.action == 'move')
                @mouseMove(@position)
            if(cmd.action == 'scroll')
                @scrollMouse cmd.direction, cmd.magnitude
            if(cmd.action == 'delay')
                @delayMouse cmd.delay
        if(cmd.type == 'keyboard')
            if(cmd.action in ['up', 'down', 'tap'])
                @keyboard cmd.action, cmd.button
        if(cmd.type == 'compound')
            @executeAction action for action in cmd.actions
        if(cmd.type == 'exec')
            @execSh cmd.cmd, cmd.options, (err)->
                if(err)
                    console.log "Exec error", err
        if(cmd.type == 'profile')
            if(cmd.action == 'load')
                @loadProfile(cmd.target)

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
        recipe = @recipes[recipeName]
        return unless recipe
        actionName = recipe.tearDown

        # Apathy!
        if(!actionName)
            @recipeState[recipeName].status = 'inactive'
            @recipeState[recipeName].timerID = null
            return false
        if(@recipeState[recipeName].status == 'active')
            if(!@recipeState[recipeName].timerID)
                #console.log "Tear down delay for #{recipeName} is " + @recipeState[recipeName].tearDownDelay
                if(@recipeState[recipeName].tearDownDelay)
                    callback = () =>
                        console.log "Tear down timed recipe #{recipeName}"
                        @executeAction(actionName)
                        @recipeState[recipeName].status = 'inactive'
                        @recipeState[recipeName].timerID = null
                    @recipeState[recipeName].timerID = setTimeout callback, @recipeState[recipeName].tearDownDelay
                    return true
                else
                    console.log "Tear down non-timed recipe #{recipeName}"
                    @recipeState[recipeName].status = 'inactive'
                    @recipeState[recipeName].timerID = null
                    @executeAction(actionName)
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

# execute action, execute tear down action, set action state active/inactive.. fuuuu
<<<<<<< HEAD
#
=======
#
window.ActionController = ActionController
>>>>>>> cf25dea83d37f449eeec8024a98d876b95485f86
