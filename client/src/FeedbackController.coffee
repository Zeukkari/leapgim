#
# Feedback Controller
#
# Relies visual and auditory feedback to the user.
#

config = window.config

class FeedbackController
    constructor: ->
        console.log "Feedback control ready"

    audioNotification: (clip) ->
        audio = new Audio(clip)
        audio.play()

    visualNotification: (title, options, clip) =>
        if options.icon then options.icon = 'asset/image/touch-gesture-icons/PNG/128/' + options.icon
        console.log options.icon
        new Notification(title, options)
        if clip then @audioNotification clip

    mouseStatus: (elem, status) ->
        document.getElementById(elem).innerHTML = status

window.FeedbackController = FeedbackController