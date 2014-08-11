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
Call function <b>cordova.version</b> from js code with params:

  <pre>cordova.version(callback, error, updateTo);</pre>
  
  <i>callback</i> - success function<br/>
  <i>error</i> - error function<br/>
  <i>updateTo</i> - url to the zip. (It will be download and extract to the www folder)<br/> 
  
  <a href="http://cordova.apache.org/docs/en/3.5.0/guide_hybrid_plugins_index.md.html#Plugin%20Development%20Guide">Cordova docs</a>
