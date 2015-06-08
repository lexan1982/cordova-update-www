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
//  AppDelegate.m
//  kyabase
//
//  Created by Jay Van Vark on 7/20/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "VersionPluginDelegate.h"
#import "UartViewController.h"
#import "Reachability.h"
#import "SSZipArchive.h"
#import "UIDevice+IdentifierAddition.h"
#import "DDFileReader.h"
#import "AppDelegate.h"

//#ifdef CORDOVA_FRAMEWORK
    #import <Cordova/CDVPlugin.h>
    #import <Cordova/CDVURLProtocol.h>
//#else
//    #import "CDVPlugin.h"
//    #import "CDVURLProtocol.h"
//#endif

@interface NSObject (PrivateMethods)

- (void) startAnimation;
- (void) stopAnimation;

@end

@implementation VersionPluginDelegate


@synthesize window, viewController;


- (void) onDidBecomeActive
{
    /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Update"
                                                    message:@"Update Msg"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:@"Update"];*/
    //[alert show];
    [self checkNewVersion:nil];
}

- (void) addUrlHandleCount {
    
    urlHandleCount++;
}

- (id) init
{
	/** If you need to do any extra app-specific initialization, you can do it here
	 *  -jm
	 **/
	m_connection = nil;
	m_requestType = 0;
	m_data = [[NSMutableData alloc] init];
    haveAlert = NO;
    urlHandleCount = 0;

    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"_pullVersion"];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidBecomeActive)
                                                 //name:UIApplicationDidBecomeActiveNotification object:nil];;
  
  NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];
  NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"www"];
  NSLog(@"Source Path: %@\n Documents Path: %@ \n Folder Path: %@", sourcePath, documentsDirectory, folderPath);
  
    
  viewController = [[UartViewController alloc] init];
  BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:folderPath];
  if (success)
  {
    viewController.startFilePath = [folderPath stringByAppendingPathComponent:@"index.html"];
  }
  
  // 900 is 15 min...
  // check for a new version every 12 minutes and auto upload evals every 30 min...
  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkNewVersion:) userInfo:nil repeats:NO];
  [NSTimer scheduledTimerWithTimeInterval:(60.0*60.0) target:self selector:@selector(checkNewVersion:) userInfo:nil repeats:YES];
  
  //[NSTimer scheduledTimerWithTimeInterval:(30*60.0) target:self selector:@selector(uploadEvalsLooped:) userInfo:@"" repeats:YES];

  NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
  
    //if (FALSE) { // don't start off just pulling the base...
  
    // first check if it is already there...
    
  
       // [[NSFileManager defaultManager] removeItemAtPath:folderPath error:&error];
        
        //        if (error) {
        //            NSLog(@"Error description-%@ \n", [error localizedDescription]);
        //            NSLog(@"Error reason-%@", [error localizedFailureReason]);
        //        }
        
        //NSURLRequest *appReq = [NSURLRequest requestWithURL:[NSURL URLWithString:[folderPath stringByAppendingPathComponent:@"index.html"]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20.0];
        //[self.viewController.webView loadRequest:appReq];
        
  
    //}
    
    //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(pullDataFromWeb:) userInfo:@"" repeats:NO];
 
        
//    [CDVURLProtocol registerURLProtocol];
    
    return [super init];
}

#pragma UIApplicationDelegate implementation

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{    
    NSURL* url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    NSString* invokeString = nil;
    
    if (url && [url isKindOfClass:[NSURL class]]) {
        invokeString = [url absoluteString];
		NSLog(@"kyabase launchOptions = %@", url);
    }    
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
    self.window.autoresizesSubviews = YES;
    
    CGRect viewBounds = [[UIScreen mainScreen] applicationFrame];
    
//    self.viewController.useSplashScreen = NO;
    self.viewController.wwwFolderName = @"www";
    self.viewController.startPage = @"index.html";
//    self.viewController.invokeString = invokeString;
    self.viewController.view.frame = viewBounds;

    //now here - add my stuff on top...
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"myViewContainer"
                                                 owner:self options:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"_pullVersion"];
    myLoginContainer = [nib objectAtIndex:0];
    myLoginContainer.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    myLoginContainer.frame = window.frame;
    NSLog(@"view frame %@", NSStringFromCGRect(window.frame));
    [self.viewController.view addSubview:myLoginContainer];
    myLoginContainer.alpha = 0.0;

    // for now - don't need it...
    myLoginContainer.hidden = YES;

    
    // check whether the current orientation is supported: if it is, keep it, rather than forcing a rotation
    BOOL forceStartupRotation = YES;
    UIDeviceOrientation curDevOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationUnknown == curDevOrientation) {
        // UIDevice isn't firing orientation notifications yetвЂ¦ go look at the status bar
        curDevOrientation = (UIDeviceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    }
    
//    if (UIDeviceOrientationIsValidInterfaceOrientation(curDevOrientation)) {
//        for (NSNumber *orient in self.viewController.supportedOrientations) {
//            if ([orient intValue] == curDevOrientation) {
//                forceStartupRotation = NO;
//                break;
//            }
//        }
//    } 
//    
//    if (forceStartupRotation) {
//        NSLog(@"supportedOrientations: %@", self.viewController.supportedOrientations);
//        // The first item in the supportedOrientations array is the start orientation (guaranteed to be at least Portrait)
//        UIInterfaceOrientation newOrient = [[self.viewController.supportedOrientations objectAtIndex:0] intValue];
//        NSLog(@"AppDelegate forcing status bar to: %d from: %d", newOrient, curDevOrientation);
//        [[UIApplication sharedApplication] setStatusBarOrientation:newOrient];
//    }
    
    [self.window addSubview:self.viewController.view];
    CGRect result = [[UIScreen mainScreen] bounds];

	UIImage* image;
    
    NSLog(@"screen %@",NSStringFromCGRect(result));
    if (result.size.height==568) {
        image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default-568h@2x" ofType:@"png"]];
    } else if (result.size.height==1024) {
        image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default-Portrait" ofType:@"png"]];
    } else {
        image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default@2x" ofType:@"png"]];
    }
	imageView = [[UIImageView alloc] initWithImage:image];
//	[image release];

    imageView.tag = 1;
    [imageView setFrame:result];
	[window addSubview:imageView];
//	[imageView release];

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(splashFront:) userInfo:@"" repeats:NO];
    
    [[UIApplication sharedApplication] 
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge)];

    NSDictionary* userInfo = [launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    NSString *alertMsg = @"";
    
    if( [apsInfo objectForKey:@"alert"] != NULL)
    {
        alertMsg = [apsInfo objectForKey:@"alert"]; 
    }
    
        
    if (![alertMsg isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Announcement"
                                                        message:alertMsg
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
//        [alert release];
    }
	
	// Clear application badge when app launches
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  
    return YES;
}

-(void)splashFront:(NSNotification *)aNotification {
    [window bringSubviewToFront:[window viewWithTag:1]];
}

-(void)removeSplash:(NSNotification *)aNotification {
    myLoginContainer.alpha = 1.0;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	imageView.alpha = 0.0;
	[UIView commitAnimations];

    // for now - don't need it...
    myLoginContainer.hidden = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkAlreadyLoggedIn:) userInfo:@"" repeats:NO];
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(pushviewBack:) userInfo:nil repeats:NO];
}

-(void)pushviewBack:(NSNotification *)aNotification {
	[window bringSubviewToFront:viewController.view];
}

// this happens while we are running ( in the background, or from within our own app )
// only valid if kyabase-Info.plist specifies a protocol to handle
- (BOOL) handleOpenURL:(NSURL*)url
{
    if (!url) { 
        return NO; 
    }
 
    NSLog(@"%@",[url description]);
    
    // if I have incoming info - start the recording and set the title to the data...
    NSString *mytempURL = [url absoluteString];
    NSString *myHost = [url host];
    if ([myHost isEqualToString:@"savedata"]) {         // example uar://savedata/filename/data
        NSArray *myurlparts = [mytempURL pathComponents];
        NSString *myfilename = [myurlparts objectAtIndex:2];
        NSString *mydata = [myurlparts objectAtIndex:3];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *myLocalFile = [documentsDirectory stringByAppendingPathComponent:myfilename];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:myLocalFile])
        {
            [mydata writeToFile:myLocalFile atomically:YES];
        }
        else
        {
            NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:myLocalFile];
            [myHandle seekToEndOfFile];
            [myHandle writeData:[mydata dataUsingEncoding:NSUTF8StringEncoding]];
            [myHandle closeFile];
        }
        
        return YES;
    }
    if ([myHost isEqualToString:@"senddata"]) {         // example uar://senddata/filename
        NSArray *myurlparts = [mytempURL pathComponents];
        NSString *myfilename = [myurlparts objectAtIndex:2];
        [self sendEmailWithFile:myfilename];
        return YES;
    }
    if ([myHost isEqualToString:@"checkinet"]) {
//        NSArray *myurlparts = [mytempURL pathComponents];
        [self checkNewVersion:nil];
        return YES;
    }
    if ([myHost isEqualToString:@"forcedown"]) {
        NSArray *myurlparts = [mytempURL pathComponents];
        NSString *versionName = [myurlparts objectAtIndex:2];
        [[NSUserDefaults standardUserDefaults] setObject:versionName forKey:@"_pullVersion"];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(uploadEvalsLooped:) userInfo:@"" repeats:NO];
        NSString *jsReturn = [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"phonegap_upload_evals();"];
        return YES;
    }
    if ([myHost isEqualToString:@"download"]) {
        //[self startAnimation];

        NSArray *myurlparts = [mytempURL pathComponents];
        NSString *versionName = [myurlparts objectAtIndex:2];
        [[NSUserDefaults standardUserDefaults] setObject:versionName forKey:@"_pullVersion"];
          [self pullDataFromWeb:versionName];
        //[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(pullDataFromTimer:) userInfo:nil repeats:NO];
        //NSString *jsReturn = [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"phonegap_upload_evals();"];
        return YES;
    }
    
	// calls into javascript global function 'handleOpenURL'
    //NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
    //[self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];
    
    // all plugins will get the notification, and their handlers will be called 
    //[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    
    return YES;    
}

-(void)sendEmailWithFile:(NSString*)myFile {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myLocalFile = [documentsDirectory stringByAppendingPathComponent:myFile];
    
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    
    mailController.mailComposeDelegate = self;
    [mailController setSubject:@"UAR Saved Log"];
    [mailController setMessageBody:@"This is the log from the UAR application...." isHTML:NO];
    
    NSData *myData = [NSData dataWithContentsOfFile:myLocalFile];
    [mailController addAttachmentData:myData mimeType:@"application/octet-stream" fileName:myFile];
    
    [self.viewController presentModalViewController:mailController animated:YES];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(actionSheet.tag == 101) {	// Exit
		if(buttonIndex == 1) {
            NSString* curVersionFile = [[NSUserDefaults standardUserDefaults] stringForKey:@"_currentVersionFile"];
			NSLog(@"User wants to update to %@", curVersionFile);
            [self.viewController startAnimation];

            jsAlive = NO;
            [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"UART.system.Helper.echo();"];
            
            
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkIsJSHanged:) userInfo:nil repeats:NO];
            
            //[[NSUserDefaults standardUserDefaults] setObject:curVersionFile forKey:@"_pullVersion"];
            
            // as a safety valve - setup a timer to pull this as well...
            // look for uar://upload-evals/finished - should really be a handshake...
            //[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(pullDataFromTimer:) userInfo:nil repeats:NO];
		} else {
            haveAlert = NO;
        }
    }else if (actionSheet.tag == 99){//Error update
        [self.viewController stopAnimation];
    }
}

- (void) setJSAlive
{
    jsAlive = YES;
}

- (void) checkIsJSHanged: (NSTimer*) timer
{
    NSLog(@"checkIsJSHanged");
    
    if (!jsAlive) {
        
        NSString* url = [self prepareDownloadPath];
        
        AppDelegate* appDlg = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        
        if (appDlg.window.rootViewController != self.viewController) {
            
            appDlg.window.rootViewController = self.viewController;
            
            [self pluginPullDataFromWeb:url];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"_pullVersion"];
        }

    }
}

- (void) pluginStartSynch
{
       [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"UART.system.Helper.syncBeforeUpdate();"];
}

- (void) uploadEvalsLooped:(NSTimer*)timer {
//    if ( [[Reachability reachabilityWithHostName:@"uar1.universityathlete.com"] isReachable] ) {
    return;
    
    if ( [[Reachability reachabilityWithHostName:@"uar1.universityathlete.com"] isReachable] ) {
        
        NSString *jsReturn = [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"phonegap_upload_evals();"];
    }
}

- (void) checkAlreadyLoggedIn:(NSTimer*)timer {
    NSString *my_sgready = [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"cfg.cpid"];
    if ([my_sgready intValue]>0) {
        self.viewController.webView.hidden = NO;
        [self.viewController stopAnimation];
        //[splashCheckTimer invalidate];
        //splashCheckTimer = nil;
        myLoginContainer.hidden = YES;
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveSplash" object:self];
    }
}

- (IBAction)doLogin:(id)sender {
    NSLog(@"pressed login button");
    //myLoginContainer.hidden = YES;
    [username_field resignFirstResponder];
    [password_field resignFirstResponder];
    
//    if ( [[Reachability reachabilityWithHostName:@"uar1.universityathlete.com"] isReachable] ) {
    if ( [[Reachability reachabilityWithHostName:@"uar1.universityathlete.com"] isReachable] ) {
        NSString* myLogin = [NSString stringWithFormat:@"phonegap_login('%@', '%@');",username_field.text, password_field.text];
        NSLog(@"Login script: %@",myLogin);
        NSString *myloginResult = [self.viewController.webView stringByEvaluatingJavaScriptFromString:myLogin];
        NSLog(@"Login result: %@",myloginResult);
        if ([myloginResult isEqualToString:@"y"]) {
            NSString *my_sgready = [self.viewController.webView stringByEvaluatingJavaScriptFromString:@"cfg.cpid"];
            if ([my_sgready intValue]>0) {
                self.viewController.webView.hidden = NO;
                [self.viewController stopAnimation];
                //[splashCheckTimer invalidate];
                //splashCheckTimer = nil;
                myLoginContainer.hidden = YES;
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveSplash" object:self];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Login Failed" message:
                                  @"Your username and password were not recognized."
                                  delegate:self cancelButtonTitle:@"Cancel"
                                  otherButtonTitles: nil];
            alert.tag = 100;
            [alert show];
//            [alert release];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Network" message:
                              @"You need to be connected to the internet to do this..."
                              delegate:self cancelButtonTitle:@"Cancel"
                              otherButtonTitles: nil];
        alert.tag = 100;
        [alert show];
//        [alert release];
    }
}

// here are the native routines that can be called...
- (void) checkNewVersion:(NSTimer*)timer {
    // testing code to access files...
    
    // NSURL *url = [[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"];
    //[self.viewController.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    //В NSLog(@"url address: %@", url);
    
    NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *original = [appLibraryFolder stringByAppendingPathComponent:@"WebKit/LocalStorage/file__0"];
    NSArray *dirContents = [[NSFileManager defaultManager]
                            directoryContentsAtPath:original];
    NSLog(@"my dir %@", [dirContents description]);
    
    
    // if we have connectivity -- check the version compared the web report...
    //    if ( [[Reachability reachabilityWithHostName:@"uar1.universityathlete.com"] isReachable] && !haveAlert) {
    if ( [[Reachability reachabilityWithHostName:@"www.google.com"] isReachable] && !haveAlert) {
        
        //NSString *stringURL = @"http://uar1.universityathlete.com/ios2013/version.txt";
        //NSString *stringURL = @"http://tsvb.touchstat.com/update/ios/tablet/version.html";
        NSString *stringURL = @"http://uart.universityathlete.com/update/ios2015/tablet/version.txt";
        
        CGRect viewBounds = [[UIScreen mainScreen] applicationFrame];
        /*__block UIView* chView = [[UIView alloc] initWithFrame:CGRectMake(0, viewBounds.size.height - 50, 100, 50)];
        [chView setBackgroundColor:[UIColor grayColor]];
        __block UILabel* chLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
        [chLbl setText:@"Checking Version"];
        [chLbl setBackgroundColor:[UIColor clearColor]];
        [chLbl setTextColor:[UIColor yellowColor]];
        [chLbl setFont:[UIFont systemFontOfSize:10]];
        [chView addSubview:chLbl];
        
        [viewController.view addSubview:chView];
        */
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
        [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            NSString *curVersionStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *localVersionStr;
            
            //[chView removeFromSuperview];

            NSArray *myVersionParts = [curVersionStr componentsSeparatedByString:@"|"];
            NSLog(@"myVersionParts: %@", myVersionParts);
            
            NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"www"];
            
            NSString *bundleFilePath = [[NSBundle mainBundle] pathForResource:@"www/index" ofType:@"html"];
            
            BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:folderPath];
            NSString* indexHtmlFilePath;
            
            if (success) {
                
                indexHtmlFilePath = [folderPath stringByAppendingPathComponent:@"index.html"];
            }
            else {
                
                indexHtmlFilePath = bundleFilePath;
            }
            
            DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:indexHtmlFilePath];
            NSString * line = nil;
            while ((line = [reader readLine])) {
                
                if ([line rangeOfString:@"src=\"cordova.js?"].location != NSNotFound) {
                    NSArray *verParts = [[[line componentsSeparatedByString:@"?"] objectAtIndex:1] componentsSeparatedByString:@"-"];
                    
                    localVersionStr = [NSString stringWithFormat:@"%@-%@", [verParts objectAtIndex:0], [verParts objectAtIndex:1]];
                    break;
                }
            }

            if ( ![localVersionStr isEqualToString:[myVersionParts objectAtIndex:0]] ) {
                [[NSUserDefaults standardUserDefaults] setObject:localVersionStr forKey:@"_currentRevision"];
                NSLog(@"We should ask the user to download a new version");
                
                newVersion = [myVersionParts objectAtIndex:0];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Update Available" message:
                                      [NSString stringWithFormat:@"%@ \nCurrent version: %@\nUpdate to: %@",[myVersionParts objectAtIndex:2], localVersionStr, [myVersionParts objectAtIndex:0] ]
                                      delegate:self cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Update Now", nil];
                
                haveAlert = YES;
                NSString* curVersionFile = [myVersionParts objectAtIndex:1];
                [[NSUserDefaults standardUserDefaults] setObject:curVersionFile forKey:@"_currentVersionFile"];
                alert.tag = 101;
                [alert show];
                //            [alert release];
            }
            else {
                
                newVersion = nil;
            }
        }];
        
    }    
}

- (void) pullDataFromTimer:(NSTimer*)timer {
    NSString* curVersionFile = [[NSUserDefaults standardUserDefaults] stringForKey:@"_pullVersion"];
    if ([curVersionFile length]>0) {
        [self pullDataFromWeb:curVersionFile];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"_pullVersion"];
    }
}

- (void) pullDataFromWeb:(NSString*) srcFile {
    [self.viewController startAnimation];
    // after we get this down -- clear the cache...
    [[NSUserDefaults standardUserDefaults] setObject:@"T" forKey:@"_isAppReload"];
    
	[m_data setData:nil];
	//NSString *stringURL = [NSString stringWithFormat:@"http://uar1.universityathlete.com/ios2013/%@",srcFile];
    NSLog(@"srcFile %@", srcFile);

    NSString *stringURL = [NSString stringWithFormat:@"http://uart.universityathlete.com/update/ios2015/tablet/%@",srcFile];
    //NSString *stringURL = [NSString stringWithFormat:@"http://192.168.0.109/%@",srcFile];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //    NSURL  *url = [NSURL URLWithString:stringURL];
	[request setURL:[NSURL URLWithString:stringURL]];
    //NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    m_requestType = 1;      // our primary request...
    if (urlHandleCount < 2) {
    
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            [self handleNewWebData:data];
            
        }];
    }
    
	//m_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (NSString*) prepareDownloadPath
{
    NSString* stringURL = [NSString stringWithFormat:@"http://uart.universityathlete.com/update/ios2015/tablet/%@.zip", newVersion];
    
    return stringURL;
}

- (void) pluginPullDataFromWeb:(NSString*) srcFile {
    
    [self.viewController startAnimation];
    // after we get this down -- clear the cache...
    [[NSUserDefaults standardUserDefaults] setObject:@"T" forKey:@"_isAppReload"];
    
	[m_data setData:nil];
    NSLog(@"srcFile %@", srcFile);
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
	[request setURL:[NSURL URLWithString:srcFile]];
    //[request setTimeoutInterval:10];
	m_requestType = 1;      // our primary request...
	//m_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
       
        if (error != nil) {
    
            printf("error = %s\n", [[error description] UTF8String]);
            NSLog(@"connection - download fail!");
            
            NSString *errormsg = [NSString stringWithFormat:@"%s",[[error description] UTF8String]];
            [self.viewController stopAnimation];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NoConnectionNotification" object:self];
            
        }
        else {
        
            [self handleNewWebData:data];
        }
        
    }];
   
}

#pragma mark URL CONNECTION DELEGATE
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	assert(m_connection == connection);
	
	if(data == nil)
		return;
    [m_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	assert(m_connection == connection);
//	[m_connection release];
	m_connection = nil;
	printf("error = %s\n", [[error description] UTF8String]);
    NSLog(@"connection - download fail!");
	
	NSString *errormsg = [NSString stringWithFormat:@"%s",[[error description] UTF8String]];
    [self.viewController stopAnimation];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NoConnectionNotification" object:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Connection finished loading...");
	if(m_requestType == 1)
	{
        [self handleNewWebData:m_data];
	}
}

-(void)handleNewWebData: (NSData*) data {
    if ( data )
    {
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        
        NSLog(@"Have data and extracting zip...");
        NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"new.zip"];
        
        NSLog(@"filePaths %@", filePath);
        
        [data writeToFile:filePath atomically:YES];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(unzipNew:) userInfo:@"" repeats:NO];
    }else{
        NSLog(@"No data loaded");
        [self unzipNew:@""];
    }
//    [self stopAnimation];
    haveAlert = NO;
}

- (void) unzipNew:(NSString*) srcFile {
    NSError *error;
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"new.zip"];
    NSString  *destination = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"new"];
    
    BOOL unzipWorked = [SSZipArchive unzipFileAtPath:filePath toDestination:destination];
    
    if (!unzipWorked) {
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Update Error" message:
                              [NSString stringWithFormat:@"Can't download app update. Please check internet connection and try again."]
                              delegate:self cancelButtonTitle:@"Cancel"
                              otherButtonTitles:nil];
        
        alert.tag = 99;
        [alert show];
        //[alert release];
    }else{
        
        // now name the old www to
        //NSString* curRevision = [[NSUserDefaults standardUserDefaults] stringForKey:@"_currentRevision"];
        NSString  *curWWW = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"www"];
        //NSString  *previousWWW = [NSString stringWithFormat:@"%@/%@", documentsDirectory,curRevision];
        [[NSFileManager defaultManager] removeItemAtPath:curWWW error:&error];
        
        
        if ([[NSFileManager defaultManager] copyItemAtPath:destination toPath:curWWW error:&error] != YES) {
            NSLog(@"Unable to move file: %@", [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Problem" message:
                                  [NSString stringWithFormat:@"Unable to move new file in: %@", [error localizedDescription]]
                                  delegate:self cancelButtonTitle:@"Cancel"
                                  otherButtonTitles:nil];
            
            alert.tag = 99;
            [alert show];
            //[alert release];
        }
        
    }
    
    // do a little cleanup here...
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:destination error:&error];
    
    
    NSString* documentWWW = [documentsDirectory stringByAppendingPathComponent:@"www"];
    NSLog(@"startPage: %@", documentWWW);
    
    BOOL success;
    success = [[NSFileManager defaultManager] fileExistsAtPath:documentWWW];
    if (success) {
        
        [self performSelector:@selector(reloadWebView:) withObject:documentWWW];
        
    }
    
    urlHandleCount = 0;
}

- (void) reloadWebView:(id) path {
    
    
    NSURLRequest *appReq = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"index.html"]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    
    [self.viewController.webView loadRequest:appReq];
    [self.viewController stopAnimation];
}


/**
 * Fetch and Format Device Token and Register Important Information to Remote Server
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	
#if !TARGET_IPHONE_SIMULATOR
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	NSString *appBundle = [[[[NSBundle mainBundle] bundleIdentifier] componentsSeparatedByString:@"."] objectAtIndex:2];
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = (rntypes & UIRemoteNotificationTypeBadge) ? @"enabled" : @"disabled";
	NSString *pushAlert = (rntypes & UIRemoteNotificationTypeAlert) ? @"enabled" : @"disabled";
	NSString *pushSound = (rntypes & UIRemoteNotificationTypeSound) ? @"enabled" : @"disabled";	
	
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = [dev uniqueDeviceIdentifier];
	NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
	
	// Prepare the Device Token for Registration (remove spaces and < >)
	NSString *deviceToken = [[[[devToken description] 
                               stringByReplacingOccurrencesOfString:@"<"withString:@""] 
                              stringByReplacingOccurrencesOfString:@">" withString:@""] 
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	// Build URL String for Registration
	// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
	// !!! SAMPLE: "secure.awesomeapp.com"
	NSString *host = @"www.ddsapp.com";
	
	// !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED 
	// !!! ( MUST START WITH / AND END WITH ? ). 
	// !!! SAMPLE: "/path/to/apns.php?"
	NSString *urlString = [NSString stringWithFormat:@"/push_service/apns.php?task=%@&appbundle=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", @"register", appBundle, appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
	
	// Register the Device Data
	// !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSLog(@"Register URL: %@", url);
	NSLog(@"Return Data: %@", returnData);
	
#endif
}

/**
 * Failed to Register for Remote Notifications
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	
#if !TARGET_IPHONE_SIMULATOR
	
	NSLog(@"Error in registration. Error: %@", error);
	
#endif
}

/**
 * Remote Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	
#if !TARGET_IPHONE_SIMULATOR
    
	NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
	
	NSString *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
    
    UIAlertView *alertview = [[UIAlertView alloc]
                          initWithTitle: @"Announcement"
                          message: alert
                          delegate: nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alertview show];
    //[alertview release];
    
	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
	application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
	
#endif
}

/* 
 * --------------------------------------------------------------------------------------------------------------
 *  END APNS CODE 
 * --------------------------------------------------------------------------------------------------------------
 */


- (void) dealloc
{
//	[super dealloc];
}

@end
