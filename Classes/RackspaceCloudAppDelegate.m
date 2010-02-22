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
#import "NSString+Rubyisms.h"


@implementation RackspaceCloudAppDelegate

@synthesize window, splitViewController, masterViewController, detailViewController, authenticationViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// TODO: link to phone support somewhere
	// TODO: tweet cdn link to file, use bit.ly
	
	
    // Override point for customization after app launch    
	window.backgroundColor = [UIColor blackColor];
    
    masterViewController = [[MasterViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    
    detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
    masterViewController.detailViewController = detailViewController;
    
    splitViewController = [[UISplitViewController alloc] init];
    splitViewController.viewControllers = [NSArray arrayWithObjects:navigationController, detailViewController, nil];
	splitViewController.delegate = detailViewController;
    
    // Add the split view controller's view to the window and display.
    //[window addSubview:splitViewController.view];
	//splitViewController.view.alpha = 0.0;
    
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

