var updateToVersion = function (str, callback) {

    console.log('..!! call plugin js: ' + str);

    cordova.exec(callback, function(err) {
        callback('error');
    }, "UpdateToVersion ", "echo", [str]);
};

module.exports = updateToVersion;
