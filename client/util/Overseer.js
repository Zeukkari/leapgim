var path = './lib';
var fs = require('fs');

var terminate = function() {
	require('nw.gui').App.closeAllWindows();
}

fs.watch('./lib', terminate);
fs.watch('./index.html', terminate);
fs.watch('./etc/config.yml', terminate);
