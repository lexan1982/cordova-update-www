cordova-update-www
==================

Replace content of "WWW" folder at the Cordova project

==================

Add new property <b>updateToVersion</b> to the <b>window</b> object.

<pre>
window.updateToVersion = function(str, callback) {
    cordova.exec(callback, function(err) {
        callback('error');
    }, "Echo", "echo", [str]);
};
</pre>

To use it call method with two parametrs. 
  
<b>params:</b> <br/>
 <i>str</i>      - version to download<br/>
 <i>callback</i> - response function  <br/>
