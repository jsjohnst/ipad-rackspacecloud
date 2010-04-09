    //
//  CloudServersActionViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/11/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "CloudServersActionViewController.h"
#import "ServerDetailViewController.h"
#import "ASICloudServersServerRequest.h"
#import "UIViewController+SpinnerView.h"
#import "ASICloudServersServer.h"


@implementation CloudServersActionViewController

@synthesize serverDetailViewController;

#pragma mark -
#pragma mark HTTP Request Helpers

-(void)startCloudServerRequest:(ASICloudServersServerRequest *)request {
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(cloudServerRequestFinished:)];
	[request setDidFailSelector:@selector(cloudServerRequestFinished:)];
	[request startAsynchronous];
}

-(void)startCloudServerRequest:(ASICloudServersServerRequest *)request finishSelector:(SEL)finishSelector failSelector:(SEL)failSelector {
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(cloudServerRequestFinished:)];
	[request setDidFailSelector:@selector(cloudServerRequestFinished:)];	
	request.userInfo = [NSDictionary dictionaryWithObject:NSStringFromSelector(finishSelector) forKey:@"finishSelector"];
	
	[request startAsynchronous];
}


#pragma mark -
#pragma mark HTTP Response Handlers

-(void)cloudServerRequestFinished:(ASICloudServersServerRequest *)request successSelector:(SEL)successSelector {
	//NSLog(@"Rename Response: %i - %@", [request responseStatusCode], [request responseString]);
	[self hideSpinnerView];
	
	if ([request isSuccess]) {
		// call the success selector if it exists
		NSString *finishSelectorString = [request.userInfo objectForKey:@"finishSelector"];
		if (finishSelectorString) {
			SEL finishSelector = NSSelectorFromString(finishSelectorString);
			if ([[request delegate] respondsToSelector:finishSelector]) {
				[[request delegate] performSelector:finishSelector withObject:request];
			}		
		}
		
		[self dismissModalViewControllerAnimated:YES];
	} else {
		
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
	}
}

-(void)cloudServerRequestFailed:(ASICloudServersServerRequest *)request {
	//NSLog(@"Request Failed: %@", [request url]);
	[self hideSpinnerView];
	NSString *title = @"Connection Failure";
	NSString *errorMessage = @"Please check your connection and try again.";
	[self alert:title message:errorMessage];
}


#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[serverDetailViewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark View Delegate

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


@end
