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

#import "CDVNotification.h"
#import "NSDictionary+Extensions.h"

@implementation CDVNotification

- (void)showDialogWithMessage:(NSString*)message title:(NSString*)title buttons:(NSArray*)buttons callbackId:(NSString*)callbackId
{
    
    NSUInteger count = [buttons count];
#ifdef __IPHONE_8_0
    if (NSClassFromString(@"UIAlertController")) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.3) {
            
            CGRect alertFrame = [UIScreen mainScreen].applicationFrame;
            
            if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                // swap the values for the app frame since it is now in landscape
                CGFloat temp = alertFrame.size.width;
                alertFrame.size.width = alertFrame.size.height;
                alertFrame.size.height = temp;
            }
            
            alertController.view.frame =  alertFrame;
        }
        
        for (int n = 0; n < count; n++) {
            
            UIAlertAction* action = [UIAlertAction actionWithTitle:[buttons objectAtIndex:n] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                     {
                                         CDVPluginResult* result;
                                         
                                         result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)(n  + 1)];
                                         
                                         
                                         [self.commandDelegate sendPluginResult:result callbackId:callbackId];
                                         
                                     }];
            [alertController addAction:action];
            
        }
        
        
        [self.viewController presentViewController:alertController animated:YES completion:nil];
        
    } else {
#endif
        CDVAlertView* alertView = [[CDVAlertView alloc]
                                   initWithTitle:title
                                   message:message
                                   delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:nil];
        
        alertView.callbackId = callbackId;
        
        
        for (int n = 0; n < count; n++) {
            [alertView addButtonWithTitle:[buttons objectAtIndex:n]];
        }
        
        [alertView show];
#ifdef __IPHONE_8_0
    }
#endif
    
}

- (void)alert:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSArray* arguments = command.arguments;
    NSUInteger argc = [arguments count];
    
    NSString* message = argc > 0 ? [arguments objectAtIndex:0] : nil;
    NSString* title = argc > 1 ? [arguments objectAtIndex:1] : nil;
    NSString* buttons = argc > 2 ? [arguments objectAtIndex:2] : nil;
    
    if (!title) {
        title = NSLocalizedString(@"Alert", @"Alert");
    }
    if (!buttons) {
        buttons = NSLocalizedString(@"OK", @"OK");
    }
    
    [self showDialogWithMessage:message title:title buttons:@[buttons] callbackId:callbackId];
}

- (void)confirm:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = command.callbackId;
    NSArray* arguments = command.arguments;
    NSUInteger argc = [arguments count];
    
    NSString* message = argc > 0 ? [arguments objectAtIndex:0] : nil;
    NSString* title = argc > 1 ? [arguments objectAtIndex:1] : nil;
    NSString* buttons = argc > 2 ? [arguments objectAtIndex:2] : nil;
    
    if (!title) {
        title = NSLocalizedString(@"Confirm", @"Confirm");
    }
    if (!buttons) {
        buttons = NSLocalizedString(@"OK,Cancel", @"OK,Cancel");
    }
    
    NSArray* labels = [buttons componentsSeparatedByString:@","];
    
    [self showDialogWithMessage:message title:title buttons:labels callbackId:callbackId];
}

/**
 Callback invoked when an alert dialog's buttons are clicked.
 Passes the index + label back to JS
 */
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CDVAlertView* cdvAlertView = (CDVAlertView*)alertView;
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)(++buttonIndex)];
    
    [self.commandDelegate sendPluginResult:result callbackId:cdvAlertView.callbackId];
}

- (void)vibrate:(CDVInvokedUrlCommand*)command
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end

@implementation CDVAlertView

@synthesize callbackId;

@end
