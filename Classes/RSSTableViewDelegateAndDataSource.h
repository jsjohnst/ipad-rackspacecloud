//
//  RSSTableViewDelegateAndDataSource.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/6/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RSSTableViewDelegateAndDataSource : NSObject <UITableViewDelegate, UITableViewDataSource> {

	// data
	NSMutableArray *feedItems;
	NSMutableArray *sitesFeedItems;
	NSMutableArray *serversFeedItems;
	NSMutableArray *filesFeedItems;
	
    NSUInteger rssRequestCompletionCount;
	
	// ui
	IBOutlet UITableViewCell *nibLoadedFeedItemCell;
    IBOutlet UITableViewCell *nibLoadedRSSEmptyCell;
	
	IBOutlet UITableView *tableView;
	
}

@property (nonatomic, retain) NSMutableArray *feedItems;
@property (nonatomic, retain) NSMutableArray *sitesFeedItems;
@property (nonatomic, retain) NSMutableArray *serversFeedItems;
@property (nonatomic, retain) NSMutableArray *filesFeedItems;

@property (nonatomic, retain) IBOutlet UITableViewCell *nibLoadedFeedItemCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *nibLoadedRSSEmptyCell;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

-(id)initWithTableView:(UITableView *)tableView;
- (void)loadRSSFeeds;

@end
