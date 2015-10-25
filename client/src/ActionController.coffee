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
        @mouseFreeze =
            enabled: true
            waitingTrigger: true

    toggleFreeze: (toggle) =>
        #console.log "Toggle freeze: " + toggle
        if(toggle is false)
            if(@mouseFreeze.waitingTrigger is false)
                @mouseFreeze.waitingTrigger = true
                console.log('Reset freeze trigger')
        if(toggle is true)
            if(@mouseFreeze.waitingTrigger)
                console.log('Toggle freeze')
                @mouseFreeze.waitingTrigger = false
                if(@mouseFreeze.enabled)
                    @mouseFreeze.enabled = false
                else
                    @mouseFreeze.enabled = true

    mouseMove: (position) =>
        if(@mouseFreeze.enabled)
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
            if(cmd.action == 'freeze')
                @toggleFreeze(true)
            if(cmd.action == 'reset')
                @toggleFreeze(false)
                #console.log('Reset freeze')

window.ActionController = ActionController
