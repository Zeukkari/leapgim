#
# Feedback Controller
#
# TODO: Cleanup
class FeedbackController
    constructor: (io) ->
        console.log "io: ", io
        @io = io
        console.log "Feedback control ready"

    audioNotification: (clip) ->
        console.log "Play audio: #{clip}"
        @io.emit 'new message',
            message: "Howling333!"
            username: "Legion"
        @io.emit 'play audio',
            file: clip

        #audio = new Audio(clip)
        #audio.play()

    visualNotification: (domID, msg) ->
        #console.log "TODO: Visual notification: #{domID}, #{msg}"
        #console.info "Visual notification", domID, msg
        #document.getElementById(domID)?.innerHTML = msg

    time: (elapsed) ->
        #console.log "TODO: Feedback time: #{elapsed}"
        #document.getElementById('timer').innerHTML = elapsed

    handVisible: (visible) ->
        #console.log "TODO: Hand visible: #{visible}"
        #document.getElementById('handVisible').innerHTML = visible

    confidenceMeter: (confidence) ->
        adjustedConfidence = confidence * 100
        #console.log "TODO: Show confidence: #{adjustedConfidence}"
        #meter = document.getElementById('meter')
        #meter.value = adjustedConfidence

module.exports = FeedbackController