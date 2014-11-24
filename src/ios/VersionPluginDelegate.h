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

//
//  AppDelegate.h
//  kyabase
//
//  Created by Jay Van Vark on 7/20/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

//#ifdef CORDOVA_FRAMEWORK
    #import <Cordova/CDVViewController.h>
//#else
//    #import "CDVViewController.h"
//#endif

@class UartViewController;

@interface VersionPluginDelegate : NSObject {
	IBOutlet UIImageView *imageView;
	NSURLConnection* m_connection;
	NSMutableData* m_data;
	int m_requestType;
	IBOutlet UITextField* username_field;
	IBOutlet UITextField* password_field;
    UILabel* myLoginContainer;
    BOOL    haveAlert;

	IBOutlet UIActivityIndicatorView *activityIndicator;
}

// invoke string is passed to your app on launch, this is only valid if you 
// edit kyabase-Info.plist to add a protocol
// a simple tutorial can be found here : 
// http://iphonedevelopertips.com/cocoa/launching-your-own-application-via-a-custom-url-scheme.html

@property (nonatomic, retain) IBOutlet UIWindow* window;
@property (nonatomic, retain) IBOutlet UartViewController* viewController;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

-(void)removeSplash:(NSNotification *)aNotification;
-(void)pushviewBack:(NSNotification *)aNotification;

- (void) DoMoveWWW;
- (void) pullDataFromWeb:(NSString*) srcFile;
- (void) pluginPullDataFromWeb:(NSString*) srcFile;
- (BOOL) handleOpenURL:(NSURL*)url;

- (void) unzipNew:(NSString*) srcFile;
- (IBAction) timerCheckWebLoadedMethod:(NSTimer*)timer;
- (void) pullDataFromTimer:(NSTimer*)timer;
- (void) checkNewVersion:(NSTimer*)timer;
- (void)sendEmailWithFile:(NSString*)myFile;

@end

