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

package com.ideateam.plugin;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.net.URLConnection;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Formatter;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.res.AssetManager;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Environment;
import android.os.Handler;
import android.os.StrictMode;
import android.util.Log;

import com.ideaintech.app.UAR2015;

/**
* This class exposes methods in Cordova that can be called from JavaScript.
*/
public class Version extends CordovaPlugin {
	 public static final int DIALOG_DOWNLOAD_PROGRESS = 0;
	 public String url = "http://uart.universityathlete.com/update/android2015/";
	 public String remoteVersion;
	 public String urlVersion;
	 public String currentVersion;
	 private String remoteChecksum;
	 private String updateChecksum;
	 private String updateNote;
	 private String zipChecksum;
	 public UAR2015 activity;
	 final private String TAG = "CordovaPlugin";
	 private CallbackContext callbackContext;
	 
	 private ProgressDialog mProgressDialog;

     
     /**
     * Executes the request and returns PluginResult.
     *
     * @param action            The action to execute.
     * @param args              JSONArry of arguments for the plugin.
     * @param callbackContext   The callback context from which we were invoked.
     */
    @SuppressLint("NewApi") 
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    	this.callbackContext = callbackContext;
    	if (action.equals("updateTo")) {
    		remoteVersion = updateChecksum = updateNote = null; 
        	//args ['0.22-234','http://domain/update/android/','0WE34DEYJRYBVXR4521DSFHTRHf44r4rCDVHERG']
 	       
    			
    		getRemoteVersion();
    		
        	this.activity = (UAR2015)this.cordova.getActivity();
         
        	if(remoteVersion == null)
        		return false;
        	else			
        		updateToVersion("");
        	
          // FIXME succes callback  
          //  callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, args.getString(0)));
        }else if (action.equals("echo")) {
        	this.activity = (UAR2015)this.cordova.getActivity();
        	//if we get response try sync, else - build is not work
        	if(System.currentTimeMillis() - activity.timestamp < 1000){       
        		
        		activity.sendJavascript("UART.system.Helper.syncBeforeUpdate()");   
        		
        	}else{
        		updateToVersion("");
        	}
        }
        else if (action.equals("isUpdate")) {
        	remoteVersion = updateChecksum = updateNote = null; 
        	getRemoteVersion();
        	getVersion(false);
        }
        else if (action.equals("writeToFile")) {
        	this.activity = (UAR2015)this.cordova.getActivity();
        	JSONObject obj = new JSONObject(args.getString(0));
    		
        	final String fileName = obj.getString("fileName");
        	final String msg = obj.getString("msg");
        	
        	if(fileName != null && fileName.length() > 0 && msg != null && msg.length() > 0){
        		
        		cordova.getThreadPool().execute(new Runnable() {
        			  public void run() {
        				  writeLocaleToFile(fileName, msg);         	
        			     }
        		});
        		return true;     
        	}
        	
        }
        else {
            return false; 
        }
        return true;
    }
    
	@Override
	public void onResume(boolean multitasking) {
		// TODO Auto-generated method stub
		super.onResume(multitasking);
		
		getVersion(true);
		
	}
	DownloadFileAsync myTask;
	Boolean isCanceled = false;
	
    public void updateToVersion(String urlV) {	
    	
    	Log.d(TAG, "..! url Scheme: " + urlV);
    	
    	if(urlV != ""){
    		remoteVersion = urlV;
    	}
    	
    	activity.runOnUiThread(new Runnable() {

			@Override
			public void run() { 
				myTask = new DownloadFileAsync();
				myTask.execute(url, remoteVersion );
			}
		});

	}
    
    void CancelHandelr(){
    	myTask.cancel(false);
    	callbackContext.success("db imported");
    	callbackContext.sendPluginResult( new PluginResult(PluginResult.Status.ERROR, "Canceled"));
    }
    
    class DownloadFileAsync extends AsyncTask<String, String, String> {
    	
    	@Override
    	protected void onPreExecute() {
    		super.onPreExecute();
    		isCanceled = false;
    		mProgressDialog = new ProgressDialog(activity);
			mProgressDialog.setMessage("Downloading file...");
			mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
			mProgressDialog.setCancelable(false);			
			mProgressDialog.setButton(DialogInterface.BUTTON_NEGATIVE, "Cancel", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					// TODO Auto-generated method stub
					Log.d(TAG, "!!! Cancel dialog");
					isCanceled = true;
					mProgressDialog.dismiss();	
					CancelHandelr();
				}
			} );
			mProgressDialog.show();
    		
    	}

    	@Override 
    	protected String doInBackground(String... aurl) {
    		int count;
    		
    	try {
    		
    		if(isCanceled == true){
    			CancelHandelr();
    			return null;
    		}
    		
	    	URL url = new URL(aurl[0]  + aurl[1]);
	    	
	    	Log.d(TAG, "..! url Scheme url: " + url);
	    	
	    	URLConnection conexion = url.openConnection();
	    	
	    	conexion.connect();
	
	    	int lenghtOfFile = conexion.getContentLength();
	    
	    	if(lenghtOfFile > 0)
	    		mProgressDialog.setMax(lenghtOfFile/1024);
	    	
	    	InputStream input = new BufferedInputStream(url.openStream());	
	    	FileOutputStream output = activity.openFileOutput(String.format("%s.zip", remoteVersion), Context.MODE_PRIVATE);
	
	    	byte data[] = new byte[1024]; 
	     
	    	long total = 0;
	
	    		while ((count = input.read(data)) != -1) {
	    			total += count;
	    			publishProgress(""+(int)(total / 1024));
	    			output.write(data, 0, count);
	    		} 
	
	    		output.flush();
	    		output.close();
	    		input.close();
	    		
	    		
    		
    	}
    	catch (Exception e) {}
    	
    	
    	return null;

    	}
    	protected void onProgressUpdate(String... progress) {
   
    		 mProgressDialog.setProgress(Integer.parseInt(progress[0]));
    	}

    	@Override
    	protected void onPostExecute(String unused) {
    		mProgressDialog.dismiss();
    		
    		if(isCanceled == true){
    			CancelHandelr();
    			return;
    		}
    			
    		
    		
    		UnzipUtility unzipper = new UnzipUtility();
    		 try {

    			 String zipFile = String.format("%s/%s", activity.getFilesDir(), remoteVersion);			 			 			 			 
    			 
    			 zipChecksum = getSHA1FromFileContent(zipFile + ".zip").toUpperCase();
    			
    			 if(zipChecksum != null && remoteChecksum !=null && !zipChecksum.equals(remoteChecksum)){
    				 showAlertDialogCheckSum();
    				 File f = new File(zipFile + ".zip");		         
    		         f.delete();
    		         zipChecksum = null;
    				 return;
    				
    			 }
    			 
    			 unzipper.unzip(zipFile + ".zip", zipFile );
    	         File f = new File(zipFile + ".zip");
    	         
    	         reloadAppFromZip(remoteVersion);
    	         
    	         //f.delete();
    	         
    	         File[] all = activity.getFilesDir().listFiles();
    	         for(int i = 0; i < all.length; i++){
    	        	 boolean isDeleted = false;
    	        	 
    	        	 if(!all[i].getName().equals(remoteVersion))
    	        		 isDeleted = DeleteRecursive(all[i]);
    	        	
    	        	 
    	         }
    	         
    	     } catch (Exception ex) {
    	         // some errors occurred
    	         ex.printStackTrace();
    	     }
    	}

    	 private void reloadAppFromZip(String version) {
    			// TODO Auto-generated method stub
    	
    		 ((CordovaActivity)activity).loadUrl(String.format("file:///%s/%s/index.html", activity.getFilesDir(), version) );
    		}
    	
    	 private boolean DeleteRecursive(File fileOrDirectory) {
    			
    		    if (fileOrDirectory.isDirectory()) 
    		        for (File child : fileOrDirectory.listFiles())
    		            DeleteRecursive(child);

    		    return fileOrDirectory.delete();
    		}
    }
    public class UnzipUtility {
        /**
         * Size of the buffer to read/write data
         */
        private static final int BUFFER_SIZE = 4096;
        /**
         * Extracts a zip file specified by the zipFilePath to a directory specified by
         * destDirectory (will be created if does not exists)
         * @param zipFilePath
         * @param destDirectory
         * @throws IOException
         */
        public void unzip(String zipFilePath, String destDirectory) throws IOException {
            File destDir = new File(destDirectory);
            if (!destDir.exists()) {
                destDir.mkdir();
            }
            ZipInputStream zipIn = new ZipInputStream(new FileInputStream(zipFilePath));
            ZipEntry entry = zipIn.getNextEntry();
            // iterates over entries in the zip file
            while (entry != null) {
                String filePath = destDirectory + File.separator + entry.getName();
                if (!entry.isDirectory()) {
                    // if the entry is a file, extracts it
                    extractFile(zipIn, filePath);
                } else {
                    // if the entry is a directory, make the directory
                    File dir = new File(filePath);
                    dir.mkdir();
                }
                zipIn.closeEntry();
                entry = zipIn.getNextEntry();
            }
            zipIn.close();
        }
        /**
         * Extracts a zip entry (file entry)
         * @param zipIn
         * @param filePath
         * @throws IOException
         */
        private void extractFile(ZipInputStream zipIn, String filePath) throws IOException {
            BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(filePath));
            byte[] bytesIn = new byte[BUFFER_SIZE];
            int read = 0;
            while ((read = zipIn.read(bytesIn)) != -1) {
                bos.write(bytesIn, 0, read);
            }
            bos.close();
        }
    }
    
    private File loadFromWwwOrZip() {
		// TODO Auto-generated method stub
    	 
    	File[] f = activity.getFilesDir().listFiles();
    	    	
    	File wwwFolder = null;
    	
    	if(f != null && f.length > 0){
	    				
			for(int i = 0; i < f.length; i++){
				if(wwwFolder == null && !f[i].getName().equals("Documents")  && !f[i].getName().equals("rList") && f[i].getName().length() < 10)
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
    
    private String getCurrentVersionZip(File wwwFolder){
    	String version = null;
    			
		File indexFile = new File(wwwFolder.getAbsoluteFile() + "/index.html");
				
		try {
			FileInputStream fin = new FileInputStream (wwwFolder.getAbsoluteFile()+"/index.html");				
			BufferedReader r = new BufferedReader(new InputStreamReader(fin));
			
			String line;
			while ((line = r.readLine()) != null) {
		    	   if(line.indexOf("src=\"app.js?") != -1){
		    		   int start = line.indexOf("?");
		    		   int end = line.lastIndexOf("-");
		    		   
		    		   version = line.substring(start + 1, end);
		    		   	    		   	    		   
		    		   break; 
		    	   }
		    	} 
	         
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		//	BufferedReader r = new BufferedReader(new InputStreamReader(openFileInput(wwwFolder.getName()+"/index.html") ));
		catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return version;
    }
    private String getCurrentVersionWWW(){
    	AssetManager am = activity.getAssets();
    	InputStream reader = null;    	
    	String version = "";
		
    	//Get version from APK's assets folder
    	//zip with updates not founded 
    	
    	
    	try {
			reader = am.open("www/index.html");
			BufferedReader r = new BufferedReader(new InputStreamReader(reader));
	    	
			String line;
	    	while ((line = r.readLine()) != null) {
	    	   if(line.indexOf("src=\"app.js?") != -1){
	    		   int start = line.indexOf("?");
	    		   int end = line.lastIndexOf("-");
	    		   
	    		   version = line.substring(start + 1, end);
	    		   	    		   	    		   
	    		   break; 
	    	   }
	    	} 
	    	
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally{
			if (reader != null) {
		          try {
		            reader.close();
		          } catch (IOException e) {
		            e.printStackTrace();
		          }
		        }			
		
    	}
        	
		 return version;
    }
 
    
    public static String getSHA1FromFileContent(String filename)
            throws NoSuchAlgorithmException, IOException {

        final MessageDigest messageDigest = MessageDigest.getInstance("SHA-1");

        InputStream is = new BufferedInputStream(new FileInputStream(filename));
        final byte[] buffer = new byte[1024];

        for (int read = 0; (read = is.read(buffer)) != -1;) {
            messageDigest.update(buffer, 0, read);
        }

        is.close();

        // Convert the byte to hex format
        Formatter formatter = new Formatter();

        for (final byte b : messageDigest.digest()) {
            formatter.format("%02x", b);
        }

        String res = formatter.toString();

        formatter.close();

        return res;
    }
    private void showAlertDialogCheckSum()
    {
    
    	new AlertDialog.Builder(activity)
        .setTitle("Checksum does not match")
        .setMessage(String.format("Waiting for SHA-1: %s\nGet Zip with SHA-1: %s", remoteChecksum, zipChecksum))
        .setPositiveButton("Ok", new DialogInterface.OnClickListener()
    {
        @Override
        public void onClick(DialogInterface dialog, int which) {
        	//startDownload(baseUrl + remoteVersion);
        }

    })
    //.setNegativeButton("Cancel", null)
    .show();
    }

	public void checkForUpdates(){
		
		Handler handler = new Handler();
		handler.postDelayed(new Runnable() {
		   @Override
		   public void run() {
			   //activity.sendJavascript("UART.system.Helper.fromNative()");
			   getVersion(true);			   
		   }
		 }, 10000);
				
	}
	
	public void getVersion(Boolean isBackground){
		
		if(isOnline())
        {   	
    		
    		File zipUpdateFile = loadFromWwwOrZip();
    		
        	if(zipUpdateFile != null)
        		currentVersion = getCurrentVersionZip(zipUpdateFile);
        	else
        		currentVersion = getCurrentVersionWWW();
        		        
	        getRemoteVersion();   	        
						
			if(remoteVersion != null && !currentVersion.equals(remoteVersion)){
					
			   
			    ((UAR2015) activity).showConfirmDialogForUpdate(updateNote, currentVersion, remoteVersion);
			}else if(!isBackground){
				if(remoteVersion != null)
					((UAR2015) activity).showConfirmDialogForUpdate("You have latest app version", null, null);
				else 
					((UAR2015) activity).showConfirmDialogForUpdate("Can not get remote version", null, null);
			}
			
        }
        else
        {
     
        }
	}
	
	public boolean isOnline() { 
		
		if(this.activity ==  null)
			this.activity = (UAR2015)this.cordova.getActivity();
		
        ConnectivityManager cm =
            (ConnectivityManager) activity.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo netInfo = cm.getActiveNetworkInfo();
        if (netInfo != null && netInfo.isConnectedOrConnecting()) {
            return true;
        }
        return false;
	}
	 private void getRemoteVersion() {
	    	
	        try {
	            StrictMode.ThreadPolicy policy = new StrictMode.
	              ThreadPolicy.Builder().permitAll().build();
	            StrictMode.setThreadPolicy(policy); 
	            URL url = new URL(this.url +"version.txt");

	            HttpURLConnection con = (HttpURLConnection) url
	              .openConnection();

	            readRemoteVersion(con.getInputStream());

	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	      
	    }   
	 private String readRemoteVersion(InputStream in) {
	      BufferedReader reader = null;
	      String version = "";
	      try {
	    	String line = "";
	        reader = new BufferedReader(new InputStreamReader(in));
	        
	        while ((line = reader.readLine()) != null) {
	        	version += line; 
	        }
	       
	       version = version.replace("|",";");
	       String[] arr =  version.split(";");
	     
	       if(arr.length == 3 || arr.length == 4) //fix for not free WiFi
	       {
	    	    remoteVersion  = arr[0];
	       		updateChecksum = arr[2].toUpperCase();
	       		updateNote 	  = arr[3];
	       }
	         
	      } catch (IOException e) {
	        e.printStackTrace();
	      } finally {
	        if (reader != null) {
	          try {
	            reader.close();
	          } catch (IOException e) {
	            e.printStackTrace();
	          }
	        }
	      }
	      return version;
	    } 
	  
	 public void syncBeforeUpdate(){
		 activity.timestamp = System.currentTimeMillis();
		 activity.sendJavascript("UART.system.Helper.echo()");
		 
	 }
	 
	 public void writeLocaleToFile(String fileName, String msg){
		
	        try {
	        	String path = Environment.getExternalStorageDirectory().getAbsolutePath() +"/UAR2015/" + fileName;
	        	
	        	 
	        	 File file = new File(path);
	        	 
	        	 if(!file.exists()){
	        		 File f = new File(Environment.getExternalStorageDirectory().getAbsolutePath() +"/UAR2015/");
	        		 f.mkdirs();
	        		 file.createNewFile();
	        		 
	        	 }
	        	 
	        	 BufferedWriter buf = new BufferedWriter(new FileWriter(file, true)); 
	             buf.append(msg);
	             buf.newLine();
	             buf.close();
	            // callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, "writed to file"));
	             Log.d(TAG, "..callBackPlugin");
	             activity.sendJavascript("UART.system.Helper.callBackPlugin('ok')");   
	             
	        } catch (IOException e) {
	            Log.d(TAG, e.getMessage());
	        }
		 
	 }

}
