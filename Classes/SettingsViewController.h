//
//  SettingsViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RackspaceCloudSplitViewDelegate.h"


@interface SettingsViewController : RackspaceCloudSplitViewDelegate {
	IBOutlet UITableView *tableView;
	NSUserDefaults *defaults;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
