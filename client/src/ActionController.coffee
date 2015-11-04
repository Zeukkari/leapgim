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
        @mouseState =
            left : "up",
            right : "up"
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

    # keyboardTest: (down) =>
    #     if(down == 'down')
    #         console.log "Keyboard state: ", @recipeState.keyboardTest.status
    #         window.feedback.audioNotification 'asset/audio/mouseup.ogg'
    #         @robot.keyToggle 't', 'down', 'command'
    #         @robot.keyToggle 't', 'up', 'command'

    mouseMove: (position) =>
        screenSize = @robot.getScreenSize()
        moveTo =
            x: position.x * screenSize.width
            y: position.y * screenSize.height
        @robot.moveMouse(moveTo.x, moveTo.y)

    # down: up|down, button: left|right
    mouseButton: (buttonState, button) =>
        feedback = window.feedback
        if(buttonState == 'up')
            @robot.mouseToggle buttonState, button
            #if(@mouseState.button != buttonState)
                #window.feedback.audioNotification 'asset/audio/mouseup.ogg'
        else if(buttonState == 'down')
            if(@mouseState.button != buttonState)
                @robot.mouseToggle buttonState, button
                #window.feedback.audioNotification 'asset/audio/mousedown.ogg'
        window.feedback.mouseStatus button, buttonState
        @mouseState.button = buttonState

    executeAction: (action) =>
        #console.log "Execute action: ", action
        cmd = @actions[action]
        #console.log "cmd: ", cmd

        if(cmd.feedback)
            if(cmd.feedback.audio)
                window.feedback.audioNotification cmd.feedback.audio

        if(cmd.type == 'mouse')
            if(cmd.action == 'hold')
                button = cmd.target
                @mouseButton 'down', button
            if(cmd.action == 'release')
                button = cmd.target
                @mouseButton 'up', button
            if(cmd.action == 'move')
                @mouseMove(@position)
        if(cmd.type == 'keyboardTest')
            @keyboardTest(cmd.action)

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
        if(!actionName)
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
