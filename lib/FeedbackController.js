"use strict";

Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

//
// Feedback Controller
//
// TODO: Cleanup
var adjustedConfidence = void 0;

var FeedbackController = function () {
    function FeedbackController(io) {
        _classCallCheck(this, FeedbackController);

        this.io = io;
        console.log("Feedback control ready");
    }

    _createClass(FeedbackController, [{
        key: "audioNotification",
        value: function audioNotification(clip) {
            console.log("Play audio: " + clip);
            return this.io.emit('play audio', { file: clip });
        }
    }, {
        key: "visualNotification",
        value: function visualNotification(domID, msg) {}
        //console.log "TODO: Visual notification: #{domID}, #{msg}"

    }, {
        key: "time",
        value: function time(elapsed) {}
        //console.log "TODO: Feedback time: #{elapsed}"

    }, {
        key: "handVisible",
        value: function handVisible(visible) {}
        //console.log "TODO: Hand visible: #{visible}"

    }, {
        key: "confidenceMeter",
        value: function confidenceMeter(confidence) {
            return adjustedConfidence = confidence * 100;
        }
    }]);

    return FeedbackController;
}();
//console.log "TODO: Show confidence: #{adjustedConfidence}"

exports.default = FeedbackController;