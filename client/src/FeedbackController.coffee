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

    time: (elapsed) ->
        document.getElementById('timer').innerHTML = elapsed

    handVisible: (visible) ->
        document.getElementById('handVisible').innerHTML = visible

    confidenceMeter: (confidence) ->
        adjustedConfidence = confidence * 100
        meter = document.getElementById('meter')
        meter.value = adjustedConfidence


window.FeedbackController = FeedbackController
