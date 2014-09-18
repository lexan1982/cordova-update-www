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

#import <Cordova/CDV.h>
#import "VersionPluginDelegate.h"
#import "AppDelegate.h"

@interface Version : CDVPlugin {

    VersionPluginDelegate* dlg;
}

@end



@implementation Version

static bool firstCall = YES;

- (void)pluginInitialize
{
    if (firstCall) {
        
        dlg = [[VersionPluginDelegate alloc] init];
        firstCall = NO;
        
        AppDelegate* appDlg = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        appDlg.window.rootViewController = dlg.viewController;
    }
}

- (void)handleOpenURL:(NSNotification*)notification
{
    // override to handle urls sent to your app
    // register your url schemes in your App-Info.plist
    
    NSURL* urlParam = [notification object];
    
    if ([urlParam isKindOfClass:[NSURL class]]) {
        [dlg handleOpenURL:urlParam];
    }
}

- (void) updateToVersion: (CDVInvokedUrlCommand*)command
{
    NSArray* args = [command.arguments objectAtIndex:0];
 
    NSString* remoteVersion = [args objectAtIndex:0];
    NSString* url = [NSString stringWithFormat:@"%@%@", [args objectAtIndex:1], remoteVersion];
    NSString* remoteChecksum = [args objectAtIndex:2];
  
    [dlg pluginPullDataFromWeb:url];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"_pullVersion"];
    
}

- (void)echo:(CDVInvokedUrlCommand*)command
{
    id message = [command.arguments objectAtIndex:0];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)echoAsyncHelper:(NSArray*)args
{
    [self.commandDelegate sendPluginResult:[args objectAtIndex:0] callbackId:[args objectAtIndex:1]];
}

- (void)echoAsync:(CDVInvokedUrlCommand*)command
{
    id message = [command.arguments objectAtIndex:0];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];

    [self performSelector:@selector(echoAsyncHelper:) withObject:[NSArray arrayWithObjects:pluginResult, command.callbackId, nil] afterDelay:0];
}

- (void)echoArrayBuffer:(CDVInvokedUrlCommand*)command
{
    id message = [command.arguments objectAtIndex:0];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer:message];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)echoArrayBufferAsync:(CDVInvokedUrlCommand*)command
{
    id message = [command.arguments objectAtIndex:0];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer:message];

    [self performSelector:@selector(echoAsyncHelper:) withObject:[NSArray arrayWithObjects:pluginResult, command.callbackId, nil] afterDelay:0];
}

- (void)echoMultiPart:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsMultipart:command.arguments];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
