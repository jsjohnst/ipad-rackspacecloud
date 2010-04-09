//
//  ServerDetailViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/28/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RackspaceCloudSplitViewDelegate.h"


@class ASICloudServersServer, ServersListViewController;

@interface ServerDetailViewController : RackspaceCloudSplitViewDelegate <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
	
	IBOutlet UITableView *tableView;
	IBOutlet UIView *noServersView;
	IBOutlet UIImageView *noServersImage;
	IBOutlet UILabel *noServersTitle;
	IBOutlet UILabel *noServersMessage;
	
	ASICloudServersServer *server;
	
	IBOutlet UIImageView *backgroundImageView;
	
	ServersListViewController *serversListViewController;
	
	NSTimer *progressTimer;
	UIProgressView *progressView;
	
	UIActionSheet *deleteServerActionSheet;
	UIActionSheet *publicIPActionSheet;
	UIActionSheet *privateIPActionSheet;
	
    BOOL showSpinner;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *noServersView;
@property (nonatomic, retain) IBOutlet UIImageView *noServersImage;
@property (nonatomic, retain) IBOutlet UILabel *noServersTitle;
@property (nonatomic, retain) IBOutlet UILabel *noServersMessage;
@property (nonatomic, retain) ASICloudServersServer *server;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) ServersListViewController *serversListViewController;

-(void)addButtonPressed:(id)sender;
-(id)initWithNoServersView;
-(void)loadServer;


@end
