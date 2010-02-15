    //
//  AuthenticationViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "ASICloudFilesRequest.h"
#import "RackspaceCloudAppDelegate.h"
#import "ASICloudServersImageRequest.h"
#import "ASICloudServersFlavorRequest.h"
#import "UIViewController+SpinnerView.h"


// TODO: try to hide scroll bars

@implementation AuthenticationViewController

@synthesize smallSpinner, largeSpinner;
@synthesize smallAuthenticatingLabel, largeAuthenticatingLabel;
@synthesize usernameTextField, apiKeyTextField;

#pragma mark -
#pragma mark View Lifecycle


/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)viewWillAppear:(BOOL)animated {	
	[self loadSettings];
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Utilities

-(void)loadSettings {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	username = [defaults stringForKey:@"username_preference"];
	apiKey = [defaults stringForKey:@"api_key_preference"];
	
	if (username == nil) {
		username = @"";
		apiKey = @"";
		
		// settings haven't been created, so let's create them here
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"", @"username_preference",
									 @"", @"api_key_preference",
									 nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	self.usernameTextField.text = username;
	self.apiKeyTextField.text = apiKey;
}

-(void)hideSpinners {
	self.smallAuthenticatingLabel.hidden = YES;
	[self.smallSpinner stopAnimating];
}

#pragma mark -
#pragma mark Animations

-(void)transitionComplete {
	[self.view removeFromSuperview];
}

-(void)transitionToAppView {
	
	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
	app.splitViewController.view.alpha = 0.0;
	[app.window addSubview:app.splitViewController.view];
	//[app.window makeKeyAndVisible];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(transitionComplete)];
	//CGRect disappearFrame = self.view.frame;
	//disappearFrame.origin.x -= 768;
	self.view.alpha = 0.0;
	app.splitViewController.view.alpha = 1.0;
	
	//self.view.frame = disappearFrame;	
	[UIView commitAnimations];
	
}

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)flavorListRequestFinished:(ASICloudServersFlavorRequest *)request {
	NSLog(@"flavor list status: %i", [request responseStatusCode]);
	NSLog(@"%@", [request responseString]);
	[self hideSpinners];
	
	[ASICloudServersFlavorRequest setFlavors:[request flavors]];
	
	// we're done.  now let's get to the app
	[self transitionToAppView];
}

-(void)flavorListRequestFailed:(ASIHTTPRequest *)request {
	NSLog(@"List Flavors Failed");
	// TODO: show alert or try again
}

-(void)imageListRequestFinished:(ASICloudServersImageRequest *)request {
	NSLog(@"image list status: %i", [request responseStatusCode]);
	NSLog(@"%@", [request responseString]);
		
	[ASICloudServersImageRequest setImages:[request images]];
	
	self.smallAuthenticatingLabel.text = @"Loading server flavors...";
	
	ASICloudServersFlavorRequest *flavorRequest = [ASICloudServersFlavorRequest listRequest];
	[flavorRequest setDelegate:self];
	[flavorRequest setDidFinishSelector:@selector(flavorListRequestFinished:)];
	[flavorRequest setDidFailSelector:@selector(flavorListRequestFailed:)];
	[flavorRequest startAsynchronous];
}

-(void)imageListRequestFailed:(ASIHTTPRequest *)request {
	NSLog(@"List Images Failed");
	// TODO: show alert or try again
}

-(void)authenticationRequestFinished:(ASIHTTPRequest *)request {
	NSLog(@"auth response status: %i", [request responseStatusCode]);
	
	// TODO: handle error responses
	
	NSDictionary *responseHeaders = [request responseHeaders];
	[ASICloudFilesRequest setAuthToken:[responseHeaders objectForKey:@"X-Auth-Token"]];
	[ASICloudFilesRequest setStorageURL:[responseHeaders objectForKey:@"X-Storage-Url"]];
	[ASICloudFilesRequest setCdnManagementURL:[responseHeaders objectForKey:@"X-Cdn-Management-Url"]];
	[ASICloudFilesRequest setServerManagementURL:[responseHeaders objectForKey:@"X-Server-Management-Url"]];
	
	self.smallAuthenticatingLabel.text = @"Loading server images...";
	
	ASICloudServersImageRequest *imageRequest = [ASICloudServersImageRequest listRequest];
	[imageRequest setDelegate:self];
	[imageRequest setDidFinishSelector:@selector(imageListRequestFinished:)];
	[imageRequest setDidFailSelector:@selector(imageListRequestFailed:)];
	[imageRequest startAsynchronous];
}

-(void)authenticationRequestFailed:(ASIHTTPRequest *)request {

	[self hideSpinners];
	
	NSString *title = @"";
	NSString *message = @"";
	
	if ([request responseStatusCode] == 401) {
		title = @"Authentication Failure";
		message = @"Please check your User Name and API Key.";
	} else {
		title = @"Connection Failure";
		message = @"Please check your connection and try again.";
	}
	
	[self alert:title message:message];
	
}

#pragma mark -
#pragma mark Button Handlers

-(void)loginButtonPressed:(id)sender {
	
	// validate input
	username = self.usernameTextField.text;
	apiKey = self.apiKeyTextField.text;
	
	if ([username isEqualToString:@""] || [apiKey isEqualToString:@""]) {
		[self alert:@"Required Fields Missing" message:@"Please enter your Rackspace Cloud User Name and API Key."];
	} else {
		
		// save to defaults
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
		[defaults setObject:username forKey:@"username_preference"];
		[defaults setObject:apiKey forKey:@"api_key_preference"];
		
		self.smallAuthenticatingLabel.text = @"Authenticating...";
		
		// attempt to login
		self.smallAuthenticatingLabel.hidden = NO;
		[self.smallSpinner startAnimating];
		
		[ASICloudFilesRequest setUsername:username];
		[ASICloudFilesRequest setApiKey:apiKey];
		ASICloudFilesRequest *request = [ASICloudFilesRequest authenticationRequest];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(authenticationRequestFinished:)];
		[request setDidFailSelector:@selector(authenticationRequestFailed:)];
		[request startAsynchronous];
	}
	
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[smallSpinner release];
	[largeSpinner release];
	[smallAuthenticatingLabel release];
	[largeAuthenticatingLabel release];
	[usernameTextField release];
	[apiKeyTextField release];
    [super dealloc];
}


@end
