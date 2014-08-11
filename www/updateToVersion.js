var updateToVersion = function(str, callback) {
    cordova.exec(callback, function(err) {
        callback('error');
    }, "UpdateToVersion ", "echo", [str]);
};

module.exports = updateToVersion;
