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

    # TODO
    mouseStatus: (elem, status) ->
        document.getElementById(elem).innerHTML = status

window.FeedbackController = FeedbackController
