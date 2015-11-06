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

    visualNotification: (domID, msg) ->
        #console.info "Visual notification", domID, msg
        document.getElementById(domID)?.innerHTML = msg

    time: (elapsed) ->
        document.getElementById('timer').innerHTML = elapsed

    handVisible: (visible) ->
        document.getElementById('handVisible').innerHTML = visible

    confidenceMeter: (confidence) ->
        adjustedConfidence = confidence * 100
        meter = document.getElementById('meter')
        meter.value = adjustedConfidence


window.FeedbackController = FeedbackController
