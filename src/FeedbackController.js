//
// Feedback Controller
//
// TODO: Cleanup
let adjustedConfidence;
class FeedbackController {
    constructor(io) {
        this.io = io;
        console.log("Feedback control ready");
    }

    audioNotification(clip) {
        console.log(`Play audio: ${clip}`);
        return this.io.emit('play audio',
            {file: clip});
    }

    visualNotification(domID, msg) {}
        //console.log "TODO: Visual notification: #{domID}, #{msg}"

    time(elapsed) {}
        //console.log "TODO: Feedback time: #{elapsed}"

    handVisible(visible) {}
        //console.log "TODO: Hand visible: #{visible}"

    confidenceMeter(confidence) {
        return adjustedConfidence = confidence * 100;
    }
}
        //console.log "TODO: Show confidence: #{adjustedConfidence}"

export default FeedbackController;