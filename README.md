Steroids Echo plugin
====================

Sample Echo plugin for Steroids.js. Compatible with Cordova and [plugman](https://github.com/apache/cordova-plugman). Built upon the [Cordova Echo plugin example](http://cordova.apache.org/docs/en/3.0.0/guide_hybrid_plugins_index.md.html#Plugin%20Development%20Guide).

##Usage

Echoes back a text string sent to the native layer.

```
window.echo("echome", function(echoValue) {
    alert(echoValue == "echome"); // should alert true.
});
```