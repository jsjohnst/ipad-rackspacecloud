//
//  DetailViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RackspaceCloudSplitViewDelegate.h"

@class RSSTableViewDelegateAndDataSource;

@interface DetailViewController : RackspaceCloudSplitViewDelegate {
	IBOutlet UITableView *tableView;	
	RSSTableViewDelegateAndDataSource *tableViewDelegate;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) RSSTableViewDelegateAndDataSource *tableViewDelegate;

@end
