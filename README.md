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

This is a plugin implementation of the <b>UpdateTo Version</b> function which can download zip from url and replace <b>www</b> folder at the Cordova project.

------------------------
<b>Installation for Android</b> 

1. Execute in CordovaCLI:
  <pre>cordova create myApp com.name.product MyAPP</pre>
  <pre>cordova pllatform add android </pre>
  <pre>cordova plugin add https://github.com/lexan1982/cordova-update-www</pre>
2. Go to the folder <b>platforms\android\src\com\ideateam\app</b>
3. Rename <b>MyActivity.java</b> to <b>MyAPP.java</b>
4. Open <b>MyAPP.java</b> and change class name from <b>MyActivity</b> to <b>MyAPP</b>
   <pre>public class MyAPP extends CordovaActivity{
           ...
    } </pre>
  
  
------------------------
<b>Installation for iOS</b> 
  
  Move file <b>MainViewController.m</b> to the directory <b>platforms\ios\ you-package-name \Classes</b>

----------------------
Call function <b>cordova.version</b> from js code with params:

  <pre>cordova.version(callback, error, updateTo);</pre>
  
  <i>callback</i> - success function<br/>
  <i>error</i> - error function<br/>
  <i>updateTo</i> - //"zipFileName, url, zipHash" ("'0.22-234', 'http://domain/update/android/',     
                                                        '0WE34DEYJRYBVXR4521DSFHTRHf44r4rCDVHERG'")
 	      
  
  <a href="http://cordova.apache.org/docs/en/3.5.0/guide_hybrid_plugins_index.md.html#Plugin%20Development%20Guide">Cordova docs</a>
