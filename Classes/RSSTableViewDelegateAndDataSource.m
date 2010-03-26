//
//  RSSTableViewDelegateAndDataSource.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/6/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "RSSTableViewDelegateAndDataSource.h"
#import "ASIHTTPRequest.h"
#import "RSSParser.h"
#import "AtomParser.h"
#import "FeedItem.h"

// Feed Item Cell Tags
#define kDateTag 1
#define kTitleTag 2
#define kBodyTag 3
#define kAuthorTag 4

static UIImage *usFlag = nil;
static UIImage *ukFlag = nil;

@implementation RSSTableViewDelegateAndDataSource

@synthesize feedItems, sitesFeedItems, serversFeedItems, filesFeedItems;
@synthesize nibLoadedFeedItemCell, nibLoadedRSSEmptyCell;
@synthesize tableView;

#pragma mark -
#pragma mark Initialization

+(void)initialize {
	usFlag = [[UIImage imageNamed:@"usflag.png"] retain];
	ukFlag = [[UIImage imageNamed:@"ukflag.png"] retain];
}

-(id)initWithTableView:(UITableView *)aTableView {
    if ((self = [super init])) {
        // Custom initialization

		rssRequestCompletionCount = 0;
		self.tableView = aTableView;
		self.tableView.backgroundView = nil; // clear background
		[self loadRSSFeeds];
    }
    return self;	
}

#pragma mark -
#pragma mark Utilities

- (BOOL)allRSSRequestsFailed {
    return [self.feedItems count] == 0 && rssRequestCompletionCount == 3;
}

- (NSString *)dateToString:(NSDate *)date {
	NSString *result = @"";
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterLongStyle];	
	result = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	return result;
}

#pragma mark -
#pragma mark HTTP Requests

- (void)appendFeedItems:(NSMutableArray *)newFeedItems {
	if (self.feedItems == nil) {
		self.feedItems = [[NSMutableArray alloc] initWithCapacity:[newFeedItems count]];
	}	
	[self.feedItems addObjectsFromArray:newFeedItems];
	[self.feedItems sortUsingSelector:@selector(compare:)];
	[self.tableView reloadData];
}

- (void)serversStatusRequestFinished:(ASIHTTPRequest *)request {
    rssRequestCompletionCount++;
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[request responseData]];
	RSSParser *rssParser = [[RSSParser alloc] init];
	xmlParser.delegate = rssParser;
	if ([xmlParser parse]) {
		self.serversFeedItems = rssParser.feedItems;
		[self appendFeedItems:rssParser.feedItems];
	}
	
	////NSLog(@"Servers Feed Item Count: %i", [self.serversFeedItems count]);
	
	[rssParser release];
	[xmlParser release];
	[self.tableView reloadData];
}

- (void)serversStatusRequestFailed:(ASIHTTPRequest *)request {
    rssRequestCompletionCount++;
    [self.tableView reloadData];
}

- (void)filesStatusRequestFinished:(ASIHTTPRequest *)request {
    rssRequestCompletionCount++;
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[request responseData]];
	RSSParser *rssParser = [[RSSParser alloc] init];
	xmlParser.delegate = rssParser;
	if ([xmlParser parse]) {
		self.filesFeedItems = rssParser.feedItems;
		[self appendFeedItems:rssParser.feedItems];
	}	
	
	////NSLog(@"Files Feed Item Count: %i", [self.filesFeedItems count]);
	
	[rssParser release];
	[xmlParser release];
	[self.tableView reloadData];
}

- (void)filesStatusRequestFailed:(ASIHTTPRequest *)request {
    rssRequestCompletionCount++;
    [self.tableView reloadData];
}

- (void)sitesStatusRequestFinished:(ASIHTTPRequest *)request {
    rssRequestCompletionCount++;
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[request responseData]];
	AtomParser *atomParser = [[AtomParser alloc] init];
	xmlParser.delegate = atomParser;
	if ([xmlParser parse]) {
		self.sitesFeedItems = atomParser.feedItems;
		[self appendFeedItems:atomParser.feedItems];
	}
	
	////NSLog(@"Sites Feed Item Count: %i", [self.sitesFeedItems count]);
	
	[atomParser release];
	[xmlParser release];	
	[self.tableView reloadData];
}

- (void)sitesStatusRequestFailed:(ASIHTTPRequest *)request {
    rssRequestCompletionCount++;
    [self.tableView reloadData];
}

- (void)loadFeedWithURL:(NSString *)feedUrl didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector {
	NSURL *url = [NSURL URLWithString:feedUrl];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request setDidFinishSelector:didFinishSelector];
	[request setDidFailSelector:didFailSelector];
	[request startAsynchronous];
	
}

- (void)loadRSSFeeds {
	[self loadFeedWithURL:@"feed://status.rackspacecloud.com/cloudservers/rss.xml" didFinishSelector:@selector(serversStatusRequestFinished:) didFailSelector:@selector(serversStatusRequestFailed:)];
	[self loadFeedWithURL:@"feed://status.clouddrive.com/?feed=rss2" didFinishSelector:@selector(filesStatusRequestFinished:) didFailSelector:@selector(filesStatusRequestFailed:)];
	[self loadFeedWithURL:@"feed://status.mosso.com/rss.xml" didFinishSelector:@selector(sitesStatusRequestFinished:) didFailSelector:@selector(sitesStatusRequestFailed:)];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else {
        if ([self allRSSRequestsFailed]) {
            return 1; // the empty RSS cell
        } else {
        	return [self.feedItems count]; 
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Contact Rackspace Cloud Support";
	} else {
		return @"Rackspace Cloud System Status";
	}
}

+ (CGFloat) findLabelHeight:(NSString*) text font:(UIFont *)font label:(UILabel *)label {
    CGSize textLabelSize = CGSizeMake(label.frame.size.width, 9000.0f);
    CGSize stringSize = [text sizeWithFont:font constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeWordWrap];
    ////NSLog(@"String size height = %f", stringSize.height);
    return stringSize.height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// make the background transparent here.  won't work in cellForRowAtIndexPath
    cell.backgroundColor = [UIColor clearColor];
	// cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
	
	
	// TODO: fix this in both rss views
	// cell.imageView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
	// cell.backgroundView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
	
	// adjust label widths for orientation
	NSArray *labels = [NSArray arrayWithObjects:[cell viewWithTag:kDateTag], 
					   [cell viewWithTag:kTitleTag], [cell viewWithTag:kBodyTag], [cell viewWithTag:kAuthorTag], nil];
	
	// label should be 40 pixels less than the cell width for both orientations
	for (int i = 0; i < [labels count]; i++) {
		UILabel *label = (UILabel *) [labels objectAtIndex:i];
		CGRect rect = label.frame;
		rect.size.width = cell.frame.size.width - 40 - 64;
		////NSLog(@"width: %f", rect.size.width);
		label.frame = rect;		
	}
	
}

- (UITableViewCell *)tableView:(UITableView *)aTableView supportCellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"SupportCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
    if (indexPath.row == 0) {
    	cell.textLabel.text = @"1-877-934-0407";
        cell.imageView.image = usFlag;
    } else {
    	cell.textLabel.text = @"0800-083-3012";
        cell.imageView.image = ukFlag;
    }
    
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)aTableView emptyRSSCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyRSSCell"];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"LoginRSSEmptyCell" owner:self options:NULL]; 
		cell = nibLoadedRSSEmptyCell;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView rssCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedItemCell"];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"FeedItemCell" owner:self options:NULL]; 
		cell = nibLoadedFeedItemCell;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	// show newest first
	FeedItem *item = [self.feedItems objectAtIndex:[self.feedItems count] - 1 - indexPath.row];
	
	UILabel *dateLabel = (UILabel *) [cell viewWithTag:kDateTag];
	dateLabel.text = [self dateToString:item.pubDate];
	
	UILabel *titleLabel = (UILabel *) [cell viewWithTag:kTitleTag];
	titleLabel.text = item.title;
	
	UILabel *bodyLabel = (UILabel *) [cell viewWithTag:kBodyTag];
	bodyLabel.text = item.content;
	
	UILabel *authorLabel = (UILabel *) [cell viewWithTag:kAuthorTag];
	authorLabel.text = [NSString stringWithFormat:@"Posted by %@", item.creator];
	
	// set the height of the title label to fit the size of the string
	CGFloat originalTitleHeight = titleLabel.frame.size.height;	
	CGFloat titleHeight = [[self class] findLabelHeight:item.title font:titleLabel.font label:titleLabel];
	
	CGRect titleRect = titleLabel.frame;
	titleRect.size.height = titleHeight;
	titleLabel.frame = titleRect;
	
	CGFloat originalBodyHeight = bodyLabel.frame.size.height;
	CGFloat bodyHeight = [[self class] findLabelHeight:item.content font:bodyLabel.font label:bodyLabel];
	
	CGRect subtitleRect = bodyLabel.frame;
	subtitleRect.origin.y += titleHeight - originalTitleHeight;
	subtitleRect.size.height = bodyHeight;
	bodyLabel.frame = subtitleRect;
	
	CGRect authorRect = authorLabel.frame;
	authorRect.origin.y += titleHeight - originalTitleHeight;
	authorRect.origin.y += bodyHeight - originalBodyHeight;
	authorLabel.frame = authorRect;
	
	CGRect cellRect = cell.frame;
	cellRect.size.height += titleHeight - originalTitleHeight;
	cellRect.size.height += bodyHeight - originalBodyHeight;
	cell.frame = cellRect;
	
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	////NSLog(@"feed item count = %i", [self.feedItems count]);
	
	
    tableView.backgroundView = nil; // clear background
    if (indexPath.section == 0) {
        return [self tableView:aTableView supportCellForRowAtIndexPath:indexPath];
    } else {
        if ([self allRSSRequestsFailed]) {
            return [self tableView:aTableView emptyRSSCellForRowAtIndexPath:indexPath];
        } else {
            return [self tableView:aTableView rssCellForRowAtIndexPath:indexPath];
        }
    }    
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// might be slower to make the extra cellForRowAtIndexPath call, but it's flexible and DRY
	//return 700.0;
	return ((UITableViewCell *)[self tableView:aTableView cellForRowAtIndexPath:indexPath]).frame.size.height;
}

#pragma mark -
#pragma mark Memory Management

-(void)dealloc {
	[feedItems release];
	[sitesFeedItems release];
	[serversFeedItems release];
	[filesFeedItems release];
	[nibLoadedFeedItemCell release];
	[nibLoadedRSSEmptyCell release];
	[tableView release];
	[super dealloc];
}

@end
