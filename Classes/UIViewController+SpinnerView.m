//
//  UIViewController+SpinnerView.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "UIViewController+SpinnerView.h"
#import "SpinnerViewController.h"


@implementation UIViewController (SpinnerView)

#pragma mark -
#pragma mark Spinner View

-(void) showSpinnerView:(NSString *)text {
	SpinnerViewController *vc = [[SpinnerViewController alloc] initWithNibName:@"SpinnerViewController" bundle:nil];
	vc.view.center = self.view.center;
	vc.label.text = text;
	[self.view addSubview:vc.view];	
	[vc release];
}

-(void) showSpinnerView {
	[self showSpinnerView:@"Saving..."];
}

// actually removes all spinner views, but you shouldn't use more than one at a time anyway
-(void) hideSpinnerView {
	NSArray *subviews = self.view.subviews;
	// TODO: this might be dangerous!  investigate a better way!
	[[subviews lastObject] removeFromSuperview];
	/*
	for (int i = 0; i < [subviews count]; i++) {
		id subview = [subviews objectAtIndex:i];
		if ([subview class] == NSClassFromString(@"SpinnerViewController")) {
			[((UIView *)subview) removeFromSuperview];
		}
	}*/
}

#pragma mark -
#pragma mark Alert Helpers

-(void)alert:(NSString *)title message:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

// behavior would be something like "renaming your server"
-(void)alertForCloudServersResponseStatusCode:(NSUInteger)responseStatusCode behavior:(NSString *)behavior {
	NSString *title = @"Error";
	NSString *message = [NSString stringWithFormat:@"There was a problem %@.", behavior];
	NSString *explanation = @"";
	
	switch (responseStatusCode) {
		case 400:
			explanation = @"Please verify the validity of the data you entered.";
			break;
		default:
			break;
	}
	[self alert:title message:[NSString stringWithFormat:@"%@ %@", message, explanation]];
}

/*
 NSString *title = @"Error";
 NSString *errorMessage = @"There was a problem renaming your server.";
 switch ([request responseStatusCode]) {
 // in all:
 /// 500, 400, others possible: cloudServersFault
 /// 503: serviceUnavailable
 /// 401: unauthorized
 /// 413: overLimit
 
 // in some:
 // 415: badMediaType
 // 405: badMethod
 // 404: itemNotFound
 // 409: buildInProgress
 /// 503: serverCapacityUnavailable
 /// 409: backupOrResizeInProgress		
 // 403: resizeNotAllowed		
 // 501: notImplemented
 
 
 // 400: badRequest
 case 400: // cloudServersFault
 errorMessage = @"There was a problem with your request.  Please verify the validity of the data you entered.";
 break;
 case 500: // cloudServersFault
 errorMessage = @"There was a problem with your request.";
 break;
 case 503:
 errorMessage = @"Your server was not renamed because the service is currently unavailable.  Please try again later.";
 break;				
 case 401:
 title = @"Authentication Failure";
 errorMessage = @"Please check your User Name and API Key.";
 break;
 case 409:
 errorMessage = @"Your server cannot be renamed at the moment because it is currently building.";
 break;
 case 413:
 errorMessage = @"Your server cannot be renamed at the moment because you have exceeded your API rate limit.  Please try again later or contact support for a rate limit increase.";
 break;
 default:
 break;
 }
 [self alert:title message:errorMessage];
 
*/

@end
