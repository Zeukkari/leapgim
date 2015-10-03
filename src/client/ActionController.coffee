#
# Action Controller
#
# Action controller's job is to recieve "leapgim frames" from the frame 
# controller. 
#
class ActionController
    constructor: ->
        @robot = require("robotjs")
    mouseMove: (handModel) =>
        screenSize = @robot.getScreenSize()
        console.log "Screen size: ", screenSize
        moveTo = 
            x: handModel.position.x * screenSize.width
            y: handModel.position.y * screenSize.height
        console.log "Move to: ", moveTo
        @robot.moveMouse(moveTo.x, moveTo.y)
    parseGestures: (handModel) =>
        console.log "handModel: ", handModel
        # Mouse Move test
        position = handModel.position

        # This conditional is hack to detect when no hand mode is present
        unless position.x is 0 and position.y is 0 and position.z is 0 
            @mouseMove(handModel)

module.exports = ActionController