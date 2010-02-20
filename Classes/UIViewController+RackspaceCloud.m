//
//  UIViewController+RackspaceCloud.m
//
//  Created by Michael Mayo on 2/19/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "UIViewController+RackspaceCloud.h"
#import "UIViewController+SpinnerView.h"
#import "ASICloudFilesRequest.h"


@implementation UIViewController (RackspaceCloud)

-(void)request:(ASICloudFilesRequest *)request behavior:(NSString *)behavior success:(SEL)success showSpinner:(BOOL)showSpinner {
    if (showSpinner) {
    	[self showSpinnerView];
    }
	[request setDelegate:self];
    request.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:behavior, NSStringFromSelector(success), [NSNumber numberWithBool:showSpinner], nil] forKeys:[NSArray arrayWithObjects:@"behavior", @"success", @"showSpinner", nil]];
	[request startAsynchronous];    
}

-(void)request:(ASICloudFilesRequest *)request behavior:(NSString *)behavior success:(SEL)success {
    [self request:request behavior:behavior success:success showSpinner:YES];
}

-(void)requestFinished:(ASICloudFilesRequest *)request {
    if ([[request.userInfo objectForKey:@"behavior"] boolValue]) {
    	[self hideSpinnerView];	
    }
	if ([request isSuccess]) {
        SEL selector = NSSelectorFromString([request.userInfo objectForKey:@"success"]);
        if ([self respondsToSelector:selector]) {
            NSMethodSignature *signature = [self methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:self];
            [invocation setSelector:selector];
            [invocation setArgument:&request atIndex:2]; // 0 and 1 are hidden/reserved
            [invocation invoke];
        }		
	} else {
        [self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:[request.userInfo objectForKey:@"behavior"]];
	}    
}

-(void)requestFailed:(ASICloudFilesRequest *)request {
	[self hideSpinnerView];	
    [self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:[request.userInfo objectForKey:@"behavior"]];
}


@end
