//
//  RackspaceCloudAppDelegate.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "RackspaceCloudAppDelegate.h"


#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AuthenticationViewController.h"


@implementation RackspaceCloudAppDelegate

@synthesize window, splitViewController, masterViewController, detailViewController, authenticationViewController;

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
	// TODO: sound effects for certain actions
	// TODO: ping api: http://apidoc.watchmouse.com/
	
    // Override point for customization after app launch    
	window.backgroundColor = [UIColor blackColor];
    
    masterViewController = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    
    detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
    masterViewController.detailViewController = detailViewController;
    
    splitViewController = [[UISplitViewController alloc] init];
    splitViewController.viewControllers = [NSArray arrayWithObjects:navigationController, detailViewController, nil];
	splitViewController.delegate = detailViewController;
    
	// put the auth view controller on top
	authenticationViewController = [[AuthenticationViewController alloc] initWithNibName:@"AuthenticationViewController" bundle:nil];
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

