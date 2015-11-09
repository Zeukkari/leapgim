#
# Feedback Controller
#

class FeedbackController
    constructor: (config) ->
        @config = config #Unused..
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

if(window)
    window.FeedbackController = FeedbackController
