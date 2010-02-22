//
//  ServerDetailViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASICloudServersServer, ServersListViewController;

@interface ServerDetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
	
	UIPopoverController *popoverController;
	UINavigationBar *navigationBar;
	
	IBOutlet UITableView *tableView;

	IBOutlet UIView *noServersView;
	IBOutlet UIImageView *noServersImage;
	IBOutlet UILabel *noServersTitle;
	IBOutlet UILabel *noServersMessage;
	
	id detailItem;
	
	ASICloudServersServer *server;
	
	IBOutlet UIImageView *logoImageView;
	IBOutlet UIImageView *backgroundImageView;
	
	ServersListViewController *serversListViewController;
	
	NSTimer *progressTimer;
	UIProgressView *progressView;
	
	UIActionSheet *deleteServerActionSheet;
	UIActionSheet *publicIPActionSheet;
	UIActionSheet *privateIPActionSheet;
	
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *noServersView;
@property (nonatomic, retain) IBOutlet UIImageView *noServersImage;
@property (nonatomic, retain) IBOutlet UILabel *noServersTitle;
@property (nonatomic, retain) IBOutlet UILabel *noServersMessage;
@property (nonatomic, retain) ASICloudServersServer *server;

@property (nonatomic, retain) id detailItem;

@property (nonatomic, retain) IBOutlet UIImageView *logoImageView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, retain) ServersListViewController *serversListViewController;

-(void)addButtonPressed:(id)sender;
-(id)initWithNoServersView;
-(void)loadServer;


@end
