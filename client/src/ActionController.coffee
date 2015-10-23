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
        @robot = require 'robotjs'
        #@feedback = new window.FeedbackController
        @mouseState =
            left : "up",
            right : "up"
        @tearDownQueue = []
        @position =
            x: undefined
            y: undefined

    mouseMove: (position) =>
        screenSize = @robot.getScreenSize()
        moveTo =
            x: position.x * screenSize.width
            y: position.y * screenSize.height
        @robot.moveMouse(moveTo.x, moveTo.y)

    # down: up|down, button: left|right
    mouseButton: (buttonState, button) =>

        feedback = window.feedback

        console.log "Mouse state left: " + @mouseState.left + ", right: " + @mouseState.right
        console.log "mouseButton state: " + buttonState + ", button: " + button

        if(@mouseState.button != buttonState)
            console.log "Fubar"
            if(buttonState == 'down')
                window.feedback.audioNotification 'asset/audio/mousedown.ogg'
                window.feedback.mouseStatus button, buttonState
            else
                window.feedback.audioNotification 'asset/audio/mouseup.ogg'
                window.feedback.mouseStatus button, buttonState
            console.log "Fubar 2"
            @mouseState.button = buttonState
            @robot.mouseToggle buttonState, button

        # # Extra mouse up
        # if(buttonState == 'up')
        #     @robot.mouseToggle buttonState, button

    executeAction: (action) =>
        console.log "Execute action: ", action
        cmd = @actions[action]
        console.log "cmd: ", cmd
        if(cmd.type == 'mouse')
            if(cmd.action == 'hold')
                button = cmd.target
                @mouseButton 'down', button
            if(cmd.action == 'release')
                button = cmd.target
                @mouseButton 'up', button
            if(cmd.action == 'move')
                console.log "Moooove"
                console.log "Position: ", @position
                @mouseMove(@position)


window.ActionController = ActionController