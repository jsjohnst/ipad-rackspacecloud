//
//  MasterViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubstitutableDetailViewController.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <UISplitViewControllerDelegate> {
    DetailViewController *detailViewController;

	UISplitViewController *splitViewController;	
	UIPopoverController *popoverController;
	UIBarButtonItem *rootPopoverBarButtonItem;
    BOOL hasPreselected;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@property(nonatomic, assign) IBOutlet UISplitViewController *splitViewController;
@property(nonatomic, assign) UIPopoverController *popoverController;
@property(nonatomic, assign) UIBarButtonItem *rootPopoverBarButtonItem;

@end
