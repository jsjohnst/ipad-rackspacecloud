//
//  RackspaceCloudAppDelegate.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "RackspaceCloudAppDelegate.h"


#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AuthenticationViewController.h"


@implementation RackspaceCloudAppDelegate

@synthesize window, splitViewController, masterViewController, detailViewController, authenticationViewController;

// TODO: error screen for when server/container list requests fail

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
														 NSUserDomainMask,
														 YES);
	NSString *basePath = nil;
	if([paths count] > 0) {
		basePath = [paths objectAtIndex:0];
	}
	return basePath;
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// TODO: tweet cdn link to file, use bit.ly
	// TODO: UIWebView for Ping IP address?  make it 785px wide to fit justping.com properly
	
    // Override point for customization after app launch    
	// window.backgroundColor = [UIColor blackColor];

    authenticationViewController = [[AuthenticationViewController alloc] initWithNibName:@"AuthenticationViewController" bundle:nil];

    
    masterViewController = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    
    detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
    
    
    //masterViewController.detailViewController = detailViewController;

    
    splitViewController = [[UISplitViewController alloc] init];
    splitViewController.viewControllers = [NSArray arrayWithObjects:navigationController, detailViewController, nil];
    //splitViewController.viewControllers = [NSArray arrayWithObjects:navigationController, authenticationViewController, nil];
	
    // TODO: hope this works
    //splitViewController.delegate = detailViewController;
    
    masterViewController.splitViewController = splitViewController;
    
    splitViewController.delegate = masterViewController;
    
    
    
    // TODO: this may not work
//	[window addSubview:splitViewController.view];
//    //[splitViewController.view sendSubviewToBack:<#(UIView *)view#>
	//[window addSubview:splitViewController.view];

    
	// put the auth view controller on top
	[window addSubview:authenticationViewController.view];

    [window makeKeyAndVisible];
	
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [splitViewController release];
	[authenticationViewController release];
    [window release];
    [super dealloc];
}


@end

