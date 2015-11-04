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
            @recipeState[name] = 'inactive'

    # keyboardTest: (down) =>
    #     if(down == 'down')
    #         console.log "Keyboard state: ", @recipeState.keyboardTest
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
            if(@mouseState.button != buttonState)
                window.feedback.audioNotification 'asset/audio/mouseup.ogg'
        else if(buttonState == 'down')
            if(@mouseState.button != buttonState)
                @robot.mouseToggle buttonState, button
                window.feedback.audioNotification 'asset/audio/mousedown.ogg'
        window.feedback.mouseStatus button, buttonState
        @mouseState.button = buttonState

    executeAction: (action) =>
        console.log "Execute action: ", action
        cmd = @actions[action]
        #console.log "cmd: ", cmd
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
            console.log "activate recipe: ", recipeName
            @executeAction(actionName)
        else if(@recipeState[recipeName] == 'inactive')
            console.log "activate recipe: ", recipeName
            @recipeState[recipeName] = 'active'
            @executeAction(actionName)
            return true
        else
            return false

    deactivateRecipe: (recipeName) =>
        recipe = @recipes[recipeName]
        if(@recipeState[recipeName] == 'active')

            setTimeout (recipe.tearDownDelay or 0)=>
                @executeAction(recipe.tearDown)
                @recipeState[recipeName] = 'inactive'



    tearDownRecipe: (recipeName) =>
        recipe = @recipes[recipeName]
        actionName = recipe.tearDown
        if(@recipeState[recipeName] == 'active')
            console.log "Tear down: #{recipeName}"
            if(recipe.tearDownDelay)
                console.log "Tear down: #{recipeName}"
                setTimeout(()=>
                    @executeAction(actionName)
                    @recipeState[recipeName] = 'inactive'
                ), recipe.TearDownDelay
            return true
        else
            return false

    getActiveRecipes: (filter) =>
        console.log "get Active recipes.."
        recipeList = []
        for recipeName, recipeState of @recipeState
            console.log "recipeName: #{recipeName}, recipeState: #{recipeState}"
            if(recipeState is 'active')
                if(typeof filter != 'function' or filter(recipeName))
                    recipeList.push recipeName
        return recipeList

    tearDownRecipes: (filter) =>
        console.log "Tear down recipes: ", filter
        for recipeName, state of @recipeState
            console.log "recipeName, state: ", recipeName, state
            if(state != 'inactive')
                if(typeof filter != 'function' or filter(recipeName, state))
                    @tearDownRecipe recipeName
        return
# execute action, execute tear down action, set action state active/inactive.. fuuuu
#
