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
//  MainViewController.h
//  kyabase
//
//  Created by Jay Van Vark on 7/20/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "AppDelegate.h"
#import "UartViewController.h"


@implementation UartViewController

@synthesize activityIndicator;

- (void) startAnimation
{
    aCnt++;
    if (!self.activityIndicator) {
        //        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(window.bounds.size.width / 2 - 36, window.bounds.size.height / 2 - 36, 72, 72)];
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(5, 3, 36, 36)];
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.activityIndicator.hidesWhenStopped = YES;
        self.activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                   UIViewAutoresizingFlexibleRightMargin |
                                                   UIViewAutoresizingFlexibleTopMargin |
                                                   UIViewAutoresizingFlexibleBottomMargin);
        [self.view addSubview: self.activityIndicator];
        NSLog(@" activity is at %@", NSStringFromCGRect(self.activityIndicator.frame));
    }
    
    int updMsgWidth = 205;
    int updMsgFont = 18;
    int updMsgHeight = 50;

    UIDevice* thisDevice = [UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        updMsgWidth = 270;
        updMsgFont = 24;
        updMsgHeight = 70;
    }
    
    
    CGRect viewBounds = [[UIScreen mainScreen] applicationFrame];
    updMsgView = [[UIView alloc] initWithFrame:CGRectMake(0.5*viewBounds.size.width - updMsgWidth/2, 0.5*viewBounds.size.height - updMsgHeight/2, updMsgWidth, updMsgHeight)];
    
    [updMsgView setBackgroundColor:[UIColor clearColor]];
    updMsgView.tag = 102;
    UILabel* chLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, updMsgWidth, updMsgHeight)];
    [chLbl setText:@"Please wait while your\napplication is updated..."];
    [chLbl setBackgroundColor:[UIColor clearColor]];
    [chLbl setTextColor:[UIColor blackColor]];
    [chLbl setFont:[UIFont boldSystemFontOfSize:updMsgFont]];
    chLbl.lineBreakMode = NSLineBreakByWordWrapping;
    chLbl.numberOfLines = 0;
    [updMsgView addSubview:chLbl];
    
    
    [self.activityIndicator startAnimating];
    self.webView.userInteractionEnabled = NO;
    self.webView.alpha = 0.2;
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = YES;
    [self.view addSubview:updMsgView];

}


/* show the user that loading activity has stopped */

- (void) stopAnimation
{
    if (updMsgView) {
        
        [updMsgView removeFromSuperview];
        updMsgView = nil;
  
    }
    
    UIView* updView = [self.view viewWithTag:102];
    
    if (updView) {
        
        [updView removeFromSuperview];
    }
    
    [self.activityIndicator stopAnimating];
    self.webView.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    self.webView.alpha = 1.0;
    UIApplication *application = [UIApplication sharedApplication];
    application.networkActivityIndicatorVisible = NO;
    //self.activityIndicator = nil;
    
    aCnt--;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        updMsgView = nil;
        aCnt = 0;
      
    }
    return self;
}

- (void) didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    
    [super viewDidLoad];
     /*if (self.startFilePath.length > 0)
  {
    [self.webView stopLoading];      
    NSURLRequest *appReq = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.startFilePath] cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20.0];
    [self.webView loadRequest:appReq];
  }
   */
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
//    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (BOOL)shouldAutorotate {
    
//    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
	return (TRUE);
}


-(NSInteger)supportedInterfaceOrientations:(UIWindow *)window{
    
    //    UIInterfaceOrientationMaskLandscape;
    //    24
    //
    //    UIInterfaceOrientationMaskLandscapeLeft;
    //    16
    //
    //    UIInterfaceOrientationMaskLandscapeRight;
    //    8
    //
    //    UIInterfaceOrientationMaskPortrait;
    //    2
    
    
    //    return UIInterfaceOrientationMaskLandscape;
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft |
                   UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown);;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Set the main view to utilize the entire application frame space of the device.
    // Change this to suit your view's UI footprint needs in your application.
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
    
    [super viewWillAppear:animated];
}

/* Comment out the block below to over-ride */
/*
- (CDVCordovaView*) newCordovaViewWithFrame:(CGRect)bounds
{
    return[super newCordovaViewWithFrame:bounds];
}
*/

/* Comment out the block below to over-ride */
/*
#pragma CDVCommandDelegate implementation

- (id) getCommandInstance:(NSString*)className
{
	return [super getCommandInstance:className];
}

- (BOOL) execute:(CDVInvokedUrlCommand*)command
{
	return [super execute:command];
}

- (NSString*) pathForResource:(NSString*)resourcepath;
{
	return [super pathForResource:resourcepath];
}
 
- (void) registerPlugin:(CDVPlugin*)plugin withClassName:(NSString*)className
{
    return [super registerPlugin:plugin withClassName:className];
}
*/

#pragma UIWebDelegate implementation

- (void) webViewDidFinishLoad:(UIWebView*) theWebView 
{
     // only valid if ___PROJECTNAME__-Info.plist specifies a protocol to handle
    /* if (self.invokeString)
     {
        // this is passed before the deviceready event is fired, so you can access it in js when you receive deviceready
        NSString* jsString = [NSString stringWithFormat:@"var invokeString = \"%@\";", self.invokeString];
        [theWebView stringByEvaluatingJavaScriptFromString:jsString];
     }*/
     
     // Black base color for background matches the native apps
     theWebView.backgroundColor = [UIColor blackColor];
    
    // here -- clear cache if we have a new download...
    // UART.app.getController('ToolsController').clearVersionFilesCache();
    NSString* isAppReload = [[NSUserDefaults standardUserDefaults] stringForKey:@"_isAppReload"];
    if ([isAppReload isEqualToString:@"T"]) {
        NSString* jsString = [NSString stringWithFormat:@"UART.app.getController('ToolsController').clearVersionFilesCache();"];
//        NSString *jsReturn = [theWebView stringByEvaluatingJavaScriptFromString:jsString];
//        NSLog(@"jsReturn (clear cache) : %@", jsReturn);
        [[NSUserDefaults standardUserDefaults] setObject:@"F" forKey:@"_isAppReload"];
    }
    
   /* [NSTimer scheduledTimerWithTimeInterval:2.5 target:[[UIApplication sharedApplication] delegate] selector:@selector(removeSplash:) userInfo:nil repeats:NO];*/
    
        //[self stopAnimation];
    
	return [super webViewDidFinishLoad:theWebView];
}

- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
    // here -- clear cache if we have a new download...
    // UART.app.getController('ToolsController').clearVersionFilesCache();
    NSString* isAppReload = [[NSUserDefaults standardUserDefaults] stringForKey:@"_isAppReload"];
    if ([isAppReload isEqualToString:@"T"]) {
        NSString* jsString = [NSString stringWithFormat:@"UART.app.getController('ToolsController').clearVersionFilesCache();"];
        NSString *jsReturn = [theWebView stringByEvaluatingJavaScriptFromString:jsString];
        NSLog(@"jsReturn (clear cache) : %@", jsReturn);
        [[NSUserDefaults standardUserDefaults] setObject:@"F" forKey:@"_isAppReload"];
    }
    
    [self stopAnimation];
	return [super webView:theWebView didFailLoadWithError:error];
}

/* Comment out the block below to over-ride */


- (void) webViewDidStartLoad:(UIWebView*)theWebView 
{
    //[self startAnimation];
	return [super webViewDidStartLoad:theWebView];
}
/*
- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error 
{
	return [super webView:theWebView didFailLoadWithError:error];
}

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
	return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}
*/

/*-(void)sendEmailWithFile:(NSString*)myFile {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myLocalFile = [documentsDirectory stringByAppendingPathComponent:myFile];
    
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    
    mailController.mailComposeDelegate = self;
    [mailController setSubject:@"UAR Saved Log"];
    [mailController setMessageBody:@"This is the log from the UAR application...." isHTML:NO];
    
    NSData *myData = [NSData dataWithContentsOfFile:myLocalFile];
    [mailController addAttachmentData:myData mimeType:@"application/octet-stream" fileName:myFile];
    
    [self presentModalViewController:mailController animated:YES];
}*/

-(void)sendEmailWithFile:(NSString*)myFile {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *myLocalFile = [documentsDirectory stringByAppendingPathComponent:myFile];
    
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    
    mailController.mailComposeDelegate = self;
    [mailController setSubject:@"UAR2014 Saved Log"];
    [mailController setToRecipients:[NSArray arrayWithObject:@"info@universityathlete.com"]];
    [mailController setMessageBody:@"This is the log from the UAR2014 application...." isHTML:NO];
    
    NSData *myData = [NSData dataWithContentsOfFile:myLocalFile];
    [mailController addAttachmentData:myData mimeType:@"application/octet-stream" fileName:myFile];
    
    [self presentModalViewController:mailController animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Result: canceled");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Result: saved");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Result: sent");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Result: failed");
			break;
		default:
			NSLog(@"Result: not sent");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


-(BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
      
	return [ super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType ];
    //return YES;
}

@end
