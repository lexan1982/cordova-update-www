/*
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
 */

package com.ideaintech.app;

import java.io.File;
import java.util.Timer;
import java.util.TimerTask;

import org.apache.cordova.Config;
import org.apache.cordova.CordovaActivity;

import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import com.ideateam.plugin.Version;

public class UART extends CordovaActivity 
{
 	 Version versionHelper;
	 public long timestamp;
	
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        super.init();
        // Set by <content src="index.html" /> in config.xml
        //super.loadUrl(Config.getStartUrl());
        //super.loadUrl("file:///android_asset/www/index.html");
       
        Intent intent = getIntent();
        String  url = intent.getDataString();
        
        versionHelper = new Version();   	 
   	 	versionHelper.activity = (UAR2015)this.getActivity();
        
		if(url != null && url.contains("download")){
		
		    int index = url.lastIndexOf('/') + 1;
		    String version = url.substring(index, url.length());
		    
		    if(version != null)
		    	version = version.replace(".zip", "");
		    
		    
		    versionHelper.remoteVersion = version;
		    versionHelper.url = "http://uart.universityathlete.com/update/android2015/";
		    versionHelper.updateToVersion();
		    
		}else{	
	
	        File zipUpdateFile = loadFromWwwOrZip();
	        
	        if(zipUpdateFile != null)        	
	        	super.loadUrl(String.format("file:///%s/%s/index.html", getFilesDir(), zipUpdateFile.getName()) );
	        else 	
	            super.loadUrl(Config.getStartUrl());
			
		}
		
		checkForUpdates();
    }
    
    private File loadFromWwwOrZip() {
		// TODO Auto-generated method stub
    	 
    	File[] f = getFilesDir().listFiles();
    	    	
    	File wwwFolder = null;
    	
    	if(f != null && f.length > 0){
	    				
			for(int i = 0; i < f.length; i++){
				if(wwwFolder == null && !f[i].getName().equals("Documents"))
				{	wwwFolder = f[i] ;
					continue;
				}
				
				if(wwwFolder != null && wwwFolder.lastModified() < f[i].lastModified()){			
					wwwFolder = f[i];
				}
			}
    	}
		return wwwFolder; 
	} 
    
    private void checkForUpdates(){      	
    	updateData.run();
    	
    }    
   
    Handler handler = new Handler();
    
    private Runnable updateData = new Runnable(){
        public void run(){
        	
        	Log.d(TAG, "...tick");
        	versionHelper.checkForUpdates();	
        	
            handler.postDelayed(updateData, 1000 * 60 * 60);
        }
    };
    
    AlertDialog dialog;
    public void showConfirmDialogForUpdate(String updateNote, String currentVersion, String remoteVersion)
    {
    
    	Builder builder = new AlertDialog.Builder(this)
        .setIcon(this.getApplicationContext().getResources().getDrawable(this.getApplicationContext().getResources().getIdentifier("icon", "drawable", this.getApplicationContext().getPackageName())))
        .setTitle("Update Available");
    	
    	if(currentVersion == null){
    		
    		builder.setMessage(updateNote).setPositiveButton("OK", new DialogInterface.OnClickListener()
			{
			    @Override
			    public void onClick(DialogInterface dialog, int which) {
			        	//startDownload(baseUrl + remoteVersion);
			        	
				}
	
		    });
    		
    	}else{
    		builder.setMessage(String.format("%s\nCurrent version: %s\nUpdate to: %s", updateNote, currentVersion, remoteVersion))
    		.setPositiveButton("Update Now", new DialogInterface.OnClickListener()
			{
			        @Override
			        public void onClick(DialogInterface dialog, int which) {
			        	//startDownload(baseUrl + remoteVersion);
			        				        	
			        	versionHelper.url = "http://uart.universityathlete.com/update/android2015/";
			        	versionHelper.syncBeforeUpdate();	
				}
	
		    })
		    .setNegativeButton("Cancel", null);    		
    	}
    	
    	if(dialog == null || !dialog.isShowing())
    		dialog = builder.show();
    	  		    
    }
}
