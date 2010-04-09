//
//  MasterViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubstitutableDetailViewController.h"

@class DetailViewController, SubstitutableDetailViewController;

@interface MasterViewController : UITableViewController <UISplitViewControllerDelegate> {
    UIViewController<SubstitutableDetailViewController> *detailViewController;
	UISplitViewController *splitViewController;	
	UIPopoverController *popoverController;
	UIBarButtonItem *rootPopoverBarButtonItem;
    BOOL hasPreselected;
    NSInteger selectedIndex;
}

@property (nonatomic, retain) IBOutlet UIViewController<SubstitutableDetailViewController> *detailViewController;

@property(nonatomic, assign) IBOutlet UISplitViewController *splitViewController;
@property(nonatomic, assign) UIPopoverController *popoverController;
@property(nonatomic, assign) UIBarButtonItem *rootPopoverBarButtonItem;

@end
