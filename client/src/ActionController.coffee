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
    mouseButton: (down, button) =>

        if(@mouseState.button != down)
            if(down == 'down')
                feedback.audioNotification 'asset/audio/mousedown.ogg'
            else
                feedback.audioNotification 'asset/audio/mouseup.ogg'
            @mouseState.button = down
            @robot.mouseToggle down, button

        # Extra mouse up
        if(down == 'up')
            @robot.mouseToggle down, button

    executeAction: (action) =>
        console.log "Execute action: ", action
        cmd = @actions[action]
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