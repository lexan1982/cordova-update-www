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
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Formatter;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.res.AssetManager;
import android.os.AsyncTask;
import android.util.Base64;
import android.util.Log;

/**
* This class exposes methods in Cordova that can be called from JavaScript.
*/
public class Version extends CordovaPlugin {
	 public static final int DIALOG_DOWNLOAD_PROGRESS = 0;
	 private String url;
	 private String remoteVersion;
	 private String remoteChecksum;
	 private String zipChecksum;
	 private Activity activity;
	 
	 private ProgressDialog mProgressDialog;
     private volatile boolean bulkEchoing;
     
     /**
     * Executes the request and returns PluginResult.
     *
     * @param action            The action to execute.
     * @param args              JSONArry of arguments for the plugin.
     * @param callbackContext   The callback context from which we were invoked.
     */
    @SuppressLint("NewApi") 
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("updateTo")) {
        	
        	//args ['0.22-234','http://uart.universityathlete.com/update/android/','0WE34DEYJRYBVXR4521DSFHTRHf44r4rCDVHERG']
 	        Log.d("uar2014", "..updateTo: " + args.toString());
 	        String[] params = args.getString(0).split(",");
        	 
 	        this.remoteVersion = params[0];
 	        this.url = params[1] + this.remoteVersion;
 	        this.remoteChecksum = params[2];
 	       
        	this.activity = this.cordova.getActivity();
        
        	Log.d("uar2014", "..remoteVersion: " + remoteVersion);
        	
        	updateToVersion();
        	
          // FIXME succes callback  
          //  callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, args.getString(0)));
        } else if(action.equals("echoAsync")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    callbackContext.sendPluginResult( new PluginResult(PluginResult.Status.OK, args.optString(0)));
                }
            });
        } else if(action.equals("echoArrayBuffer")) {
            String data = args.optString(0);
            byte[] rawData= Base64.decode(data, Base64.DEFAULT);
            callbackContext.sendPluginResult( new PluginResult(PluginResult.Status.OK, rawData));
        } else if(action.equals("echoArrayBufferAsync")) {
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    String data = args.optString(0);
                    byte[] rawData= Base64.decode(data, Base64.DEFAULT);
                    callbackContext.sendPluginResult( new PluginResult(PluginResult.Status.OK, rawData));
                }
            });
        } else if(action.equals("echoMultiPart")) {
            callbackContext.sendPluginResult( new PluginResult(PluginResult.Status.OK, args.getJSONObject(0)));
        } else if(action.equals("stopEchoBulk")) {
            bulkEchoing = false;
        } else if(action.equals("echoBulk")) {
            if (bulkEchoing) {
                return true;
            }
            final String payload = args.getString(0);
            final int delayMs = args.getInt(1);
            bulkEchoing = true;
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    while (bulkEchoing) {
                        try {
                            Thread.sleep(delayMs);
                        } catch (InterruptedException e) {}
                        PluginResult pr = new PluginResult(PluginResult.Status.OK, payload);
                        pr.setKeepCallback(true);
                        callbackContext.sendPluginResult(pr);
                    }
                    PluginResult pr = new PluginResult(PluginResult.Status.OK, payload);
                    callbackContext.sendPluginResult(pr);
                }
            });
        } else {
            return false;
        }
        return true;
    }
    
    /*@Override
    public void onResume(boolean multitasking) {
    	// TODO Auto-generated method stub
    	super.onResume(multitasking);    
    	 Log.d("uar2014", "..    onResume!!! ");    	
    
    }
    
    private boolean isWww = false;
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    	
    	 Log.d("uar2014", "..    CordovaInterface ");
    	 
    	 if(cordova.getActivity() != null && isWww == false){
    		 isWww = true;
    		 Log.d("uar2014", "..    getActivity ");
    		 ((CordovaActivity)cordova.getActivity()).loadUrl("file:///android_asset/www/index2.html");
    		 
    		 
    	 }
    	 else Log.d("uar2014", "..    null getActivity ");
    	 
    	 
    }
    */
     
    private void updateToVersion() {
		
    	activity.runOnUiThread(new Runnable() {

			@Override
			public void run() {
				 new DownloadFileAsync().execute(url);

			}
		});

	}
    
    class DownloadFileAsync extends AsyncTask<String, String, String> {
    	
    	@Override
    	protected void onPreExecute() {
    		super.onPreExecute();
    		mProgressDialog = new ProgressDialog(activity);
			mProgressDialog.setMessage("Downloading file..");
			mProgressDialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
			mProgressDialog.setCancelable(false);
			mProgressDialog.show();
    		
    		
    	}

    	@Override 
    	protected String doInBackground(String... aurl) {
    		int count;
    		
    	try {

	    	URL url = new URL(aurl[0]);
	    	URLConnection conexion = url.openConnection();
	    	conexion.connect();
	
	    	int lenghtOfFile = conexion.getContentLength();
	    	Log.d("uar2014", "Lenght of file: " + lenghtOfFile);
	    	mProgressDialog.setMax(lenghtOfFile/1024);
	    	InputStream input = new BufferedInputStream(url.openStream());	
	    	FileOutputStream output = activity.openFileOutput(String.format("%s.zip", remoteVersion), Context.MODE_PRIVATE);
	
	    	byte data[] = new byte[1024]; 
	     
	    	long total = 0;
	
	    		while ((count = input.read(data)) != -1) {
	    			total += count;
	    			publishProgress(""+(int)((total*100)/lenghtOfFile));
	    			output.write(data, 0, count);
	    		} 
	
	    		output.flush();
	    		output.close();
	    		input.close();
	    		
	    		
    		
    	} catch (Exception e) {}
    	
    	
    	return null;

    	}
    	protected void onProgressUpdate(String... progress) {
    	//	 Log.d("uar2014",progress[0]);
    		 mProgressDialog.setProgress(Integer.parseInt(progress[0]));
    	}

    	@Override
    	protected void onPostExecute(String unused) {
    		mProgressDialog.dismiss();
    		UnzipUtility unzipper = new UnzipUtility();
    		 try {

    			 String zipFile = String.format("%s/%s", activity.getFilesDir(), remoteVersion);			 			 			 			 
    			 
    			
    			 
    			 zipChecksum = getSHA1FromFileContent(zipFile + ".zip").toUpperCase();
    			
    			 Log.d("uar2014", "---------------getSHA1FromFileContent---------------------");	
    			 Log.d("uar2014", remoteChecksum);	
    			 Log.d("uar2014", zipChecksum);	
    			 
    			 
    			 if(zipChecksum != null && !zipChecksum.equals(remoteChecksum)){
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
    		 Log.d("uar2014",".. reloadAppFromZip");
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
	    	wwwFolder = f[0] ;
			
			for(int i = 0; i < f.length; i++){
				
				if(wwwFolder.lastModified() < f[i].lastModified()){			
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
	    	   if(line.contains(" version: '")){
	    		   
	    		   int start = line.indexOf("'");
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
	    	   if(line.contains(" version: '")){
	    		   
	    		   int start = line.indexOf("'");
	    		   int end = line.lastIndexOf("-");
	    		   
	    		   version = line.substring(start + 1, end);
	    		   
	    		   break;
	    	   }
	    	} 
	    	
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			Log.d("uar2014","Can't read from www/index.html");
			Log.d("uar2014",e.getMessage());
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
    	Log.d("uar2014","..showAlertDialogCheckSum");
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
}
