//
//  DetailViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RackspaceCloudSplitViewDelegate.h"

@class RSSTableViewDelegateAndDataSource;

@interface DetailViewController : RackspaceCloudSplitViewDelegate <SubstitutableDetailViewController> {
//@interface DetailViewController : UIViewController <SubstitutableDetailViewController> {
    
	IBOutlet UITableView *tableView;	
	RSSTableViewDelegateAndDataSource *tableViewDelegate;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) RSSTableViewDelegateAndDataSource *tableViewDelegate;

@end
