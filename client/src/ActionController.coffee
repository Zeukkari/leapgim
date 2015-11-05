    #
# Action Controller
#
# Triggers mouse and keyboard actions based on configured recipes. Actions are idempotent operations.
#

feedback = window.feedback
config = window.config

class ActionController
    constructor: ->
        @actions = window.config.actions
        @recipes = window.config.recipes
        window.ActionController = @
        @robot = require 'robotjs'
        @mouseState = 'free' # free|frozen
        @position =
            x: undefined
            y: undefined
        @keyboardModel =
            test: false
        @recipeState = {}
        for name, recipe of @recipes
            @recipeState[name] =
                status: 'inactive'
                timerID: null
            if(recipe.tearDownDelay)
                @recipeState[name].tearDownDelay = recipe.tearDownDelay

    freezeMouse: () => @mouseState = 'frozen'
    unfreezeMouse: () => @mouseState = 'free'
    toggleMouseFreeze: () =>
        if (@mouseState == 'frozen')
            @mouseState = 'free'
        else if(@mouseState == 'free')
            @mouseState = 'frozen'

    mouseMove: (position) =>
        if(@mouseState == 'free')
            screenSize = @robot.getScreenSize()
            moveTo =
                x: position.x * screenSize.width
                y: position.y * screenSize.height
            @robot.moveMouse(moveTo.x, moveTo.y)
        else
            console.log "Mouse is frozen.."

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

    scrollMouse: (direction, magnitude = 50) =>
        if(direction == 'up' or direction == 'down')
            @robot.scrollMouse(magnitude, direction)
        else
            console.log 'This aint 3d, man!'

    executeAction: (action) =>
        #console.log "Execute action: ", action
        cmd = @actions[action]
        #console.log "cmd: ", cmd

        if(cmd.feedback?)
            if(cmd.feedback.audio?)
                window.feedback.audioNotification cmd.feedback.audio

        if(cmd.type == 'mouse')
            if(cmd.action == 'freeze')
                @freezeMouse()
            if(cmd.action == 'unfreeze')
                @unfreezeMouse()
            if(cmd.action == 'toggleFreeze')
                @toggleMouseFreeze()
            if(cmd.action in ['up', 'down', 'click', 'doubleClick'])
                @mouseButton cmd.action, cmd.target
            if(cmd.action == 'move')
                @mouseMove(@position)
            if(cmd.action == 'scroll')
                @scrollMouse cmd.direction, cmd.magnitude
        if(cmd.type == 'keyboard')
            if(cmd.action in ['up', 'down', 'tap'])
                @keyboard cmd.action, cmd.button

    activateRecipe: (recipeName) =>
        recipe = @recipes[recipeName]
        #console.log "recipe data:", recipe
        actionName = recipe.action
        if(recipe.continuous)
            #console.log "activate continuous recipe: ", recipeName
            @executeAction(actionName)
            return true
        else if(@recipeState[recipeName].status == 'inactive')
            if(!@recipeState[recipeName].timerID)
                console.log "Activate recipe #{recipeName}"
                @recipeState[recipeName].status = 'active'
                @executeAction(actionName)
                return true
        return false

    tearDownRecipe: (recipeName) =>
        recipe = @recipes[recipeName]
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
#
