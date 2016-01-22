#
# Feedback Controller
#
# TODO: Cleanup
class FeedbackController
    constructor: (io) ->
        @io = io
        console.log "Feedback control ready"

    audioNotification: (clip) ->
        console.log "Play audio: #{clip}"
        @io.emit 'play audio',
            file: clip

    visualNotification: (domID, msg) ->
        #console.log "TODO: Visual notification: #{domID}, #{msg}"

    time: (elapsed) ->
        #console.log "TODO: Feedback time: #{elapsed}"

    handVisible: (visible) ->
        #console.log "TODO: Hand visible: #{visible}"

    confidenceMeter: (confidence) ->
        adjustedConfidence = confidence * 100
        #console.log "TODO: Show confidence: #{adjustedConfidence}"

module.exports = FeedbackController