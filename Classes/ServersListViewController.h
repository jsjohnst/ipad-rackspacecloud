//
//  ServersListViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerDetailViewController, ASICloudServersServer;

@interface ServersListViewController : UITableViewController {
	NSMutableArray *servers;
	ServerDetailViewController *serverDetailViewController;
}

@property (nonatomic, retain) ServerDetailViewController *serverDetailViewController;

- (void)loadServers;
- (void)loadServers:(BOOL)showSpinner;
- (void)refreshServer:(ASICloudServersServer *)server;

@end
