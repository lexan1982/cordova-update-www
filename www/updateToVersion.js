var updateToVersion = function(str, callback) {
    cordova.exec(callback, function(err) {
        callback('error');
    }, "Echo", "echo", [str]);
};

module.exports = updateToVersion;
