//
//  ServersListViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/28/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerDetailViewController, ASICloudServersServer;

@interface ServersListViewController : UITableViewController <UISplitViewControllerDelegate> {
	NSMutableArray *servers;
	ServerDetailViewController *serverDetailViewController;
    
    // split view
	UISplitViewController *splitViewController;	
	UIPopoverController *popoverController;
	UIBarButtonItem *rootPopoverBarButtonItem;
    
}

@property (nonatomic, retain) ServerDetailViewController *serverDetailViewController;

// split view
@property(nonatomic, assign) IBOutlet UISplitViewController *splitViewController;
@property(nonatomic, assign) UIPopoverController *popoverController;
@property(nonatomic, assign) UIBarButtonItem *rootPopoverBarButtonItem;

- (void)loadServers;
- (void)loadServers:(BOOL)showSpinner;
- (void)refreshServer:(ASICloudServersServer *)server;

@end
