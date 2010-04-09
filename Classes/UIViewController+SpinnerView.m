//
//  UIViewController+SpinnerView.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/10/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "UIViewController+SpinnerView.h"
#import "SpinnerViewController.h"

#define kSpinnerTag 777

@implementation UIViewController (SpinnerView)

#pragma mark -
#pragma mark Spinner View

-(void)showSpinnerView:(NSString *)text {
	SpinnerViewController *vc = [[SpinnerViewController alloc] initWithNibName:@"SpinnerViewController" bundle:nil];
	CGPoint center = self.view.center;
	CGPoint offset = CGPointZero;
	@try {
		UIScrollView *scrollView = (UIScrollView *) self.view;
		offset = scrollView.contentOffset;
	}
	@catch (NSException * e) {
		// do nothing if this fails
	}
	
	center.y = center.y / 3; // move it up a bit
	
	center.y = center.y + offset.y;
	
	vc.view.center = center;
	vc.label.text = text;
	vc.view.tag = kSpinnerTag;
	[self.view addSubview:vc.view];
    self.view.userInteractionEnabled = NO;
	[vc release];
}

-(void) showSpinnerView {
	[self showSpinnerView:@"Please wait..."];
}

-(void)hideSpinnerView {
    self.view.userInteractionEnabled = YES;
	UIView *spinner = [self.view viewWithTag:kSpinnerTag];
	if (spinner != nil) {
		[spinner removeFromSuperview];
	}
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
		case 0:
			title = @"Connection Failure";
			explanation = @"Please check your Internet connection and try again.";
			break;
		case 400:
			explanation = @"Please verify the validity of the data you entered.";
			break;
//		case 500: // cloudServersFault
//			errorMessage = @"There was a problem with your request.";
//			break;
		case 503:
			explanation = @"The service is currently unavailable.  Please try again later.";
			break;				
		case 401:
			title = @"Authentication Failure";
			explanation = @"Please check your User Name and API Key.";
			break;
		case 409:
			explanation = @"The server is currently being built.  Please try again later.";
			break;
		case 413:
			explanation = @"You have exceeded your API rate limit.  Please try again later or contact support for a rate limit increase.";
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


}
[self alert:title message:errorMessage];
 
*/

@end
