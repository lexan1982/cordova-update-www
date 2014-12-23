<!--
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#  KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
-->

cordova-update-www
------------------------

Get current and remote version in the native code.
  1. Current version get from file index.html parse script src
<code><script type="text/javascript" src="app.js?0.22-544-gd096e48"></script></code>
  2. Remote version get from server in this format (new version and note)
<code>0.22-537|0.22-537|This version contains feature updates</code>

If the versions do not equal show native dialog with:
<code>
title:    "Update Available"
note:     "This version contains feature updates"
current:  "Current version: 0.22-535"
remote:   "Update to: 0.22-537"

buttons: "Update Now"  "Cancel"

</code>

If user tap "Update Now" we must first of all Sync evals to the server and only then update version.

And in this step maybe: 
  1. builds is OK and we need Sync
  2. build is broken and we cann't call JS method
  
So we do test request to the JS 
<code> 
  activity.sendJavascript("UART.system.Helper.echo()");
</code>

this is method do callback to the native
<code>
   cordova.version(null, null, 'echo')
</code>

and if we get response during 1 second we call JS from native to do Sync

<code> 
  activity.sendJavascript("UART.system.Helper.syncBeforeUpdate()");
</code>

after Sync was completed JS will call native 
<code>
  cordova.version(null, null, 'updateTo');
</code>

and download zip with new version
  





This is a plugin implementation of the <b>UpdateTo Version</b> function which can download zip from url and replace <b>www</b> folder at the Cordova project. Also it add url scheme to you APP and then we can start APP from another with zip to download as param -  <b>href="myapp://download/version007.zip"</b>

------------------------
<b>Installation for Android</b> 

1. Execute in CordovaCLI:
  <pre>cordova create myApp com.name.product MyAPP</pre>
  <pre>cordova pllatform add android </pre>
  <pre>cordova plugin add https://github.com/lexan1982/cordova-update-www --variable URL_SCHEME=MyAPP</pre>
2. Go to the folder <b>platforms\android\src\com\ideateam\app</b>
3. Rename <b>VersionMyApp.java</b> to <b>Version.java</b>
4. Open <b>MyAPP.java</b> and change class name from <b>Activity</b> to <b>MyAPP</b>
   <pre>public class MyAPP extends CordovaActivity{
           ...
    } </pre>
  
  
------------------------
<b>Installation for iOS</b> 
  
  Move file <b>MainViewController.m</b> from <b>platforms\ios\ you-package-name \ Plugins\com.ideateam.plugin.version</b> to the directory <b>platforms\ios\ you-package-name \Classes</b>

----------------------
Call function <b>cordova.version</b> from js code with params:

  <pre>cordova.version(callback, error, 'isUpdate');</pre>
  
  <i>callback</i> - success function<br/>
  <i>error</i> - error function<br/>
  <i>action</i>
 	      
  
  <a href="http://cordova.apache.org/docs/en/3.5.0/guide_hybrid_plugins_index.md.html#Plugin%20Development%20Guide">Cordova docs</a>
  
  <a href="myapp://download/0.22-777.zip">MyApp</a>
