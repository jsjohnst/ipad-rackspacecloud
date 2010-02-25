//
//  DetailViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    
    UIPopoverController *popoverController;
    UINavigationBar *navigationBar;
    
    id detailItem;

	IBOutlet UITableView *tableView;
	IBOutlet UITableViewCell *nibLoadedFeedItemCell;
    IBOutlet UITableViewCell *nibLoadedRSSEmptyCell;
	
	// this is the initial detail view.
	// since servers or files isn't selected when the app launches,
	// load data from feed://status.mosso.com/rss.xml to give the user
	// an update on the status of the rackspace cloud
	// pre-select a System Status row on the master view
	// also consider feed://twitter.com/statuses/user_timeline/6979812.rss
	
	NSMutableArray *feedItems;
	NSMutableArray *sitesFeedItems;
	NSMutableArray *serversFeedItems;
	NSMutableArray *filesFeedItems;
	
    NSUInteger requestCompletionCount;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, retain) id detailItem;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell *nibLoadedFeedItemCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *nibLoadedRSSEmptyCell;

@property (nonatomic, retain) NSMutableArray *feedItems;
@property (nonatomic, retain) NSMutableArray *sitesFeedItems;
@property (nonatomic, retain) NSMutableArray *serversFeedItems;
@property (nonatomic, retain) NSMutableArray *filesFeedItems;

@end
