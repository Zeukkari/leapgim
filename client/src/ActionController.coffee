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
        @mouseState =
            left : "up",
            right : "up"
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
        #console.log "Execute action: ", action
        cmd = @actions[action]
        if(cmd.type == 'mouse')
            if(cmd.action == 'hold')
                button = cmd.target
                @mouseButton 'down', button
            if(cmd.action == 'release')
                button = cmd.target
                @mouseButton 'up', button
            if(cmd.action == 'move')
                @mouseMove(@position)

window.ActionController = ActionController
