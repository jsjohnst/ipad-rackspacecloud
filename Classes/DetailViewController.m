//
//  DetailViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "MasterViewController.h"
#import "ASIHTTPRequest.h"
#import "RSSParser.h"
#import "AtomParser.h"
#import "FeedItem.h"

// Feed Item Cell Tags
#define kDateTag 1
#define kTitleTag 2
#define kBodyTag 3
#define kAuthorTag 4

@implementation DetailViewController

@synthesize navigationBar, popoverController, detailItem;
@synthesize sitesFeedItems, serversFeedItems, filesFeedItems;
@synthesize tableView, nibLoadedFeedItemCell;
@synthesize feedItems;

#pragma mark -
#pragma mark Date Formatting

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
#pragma mark Managing the popover controller

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
        
        // Update the view.
        navigationBar.topItem.title = [detailItem description];
    }

    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Services";
    [navigationBar.topItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    [navigationBar.topItem setLeftBarButtonItem:nil animated:YES];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark RSS

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
	// feed://status.clouddrive.com/?feed=rss2
	// feed://status.mosso.com/rss.xml
}

#pragma mark -
#pragma mark HTTP Response Handlers

- (void)appendFeedItems:(NSMutableArray *)newFeedItems {
	if (self.feedItems == nil) {
		self.feedItems = [[NSMutableArray alloc] initWithCapacity:[newFeedItems count]];
	}	
	[self.feedItems addObjectsFromArray:newFeedItems];
	[self.feedItems sortUsingSelector:@selector(compare:)];
}

- (void)serversStatusRequestFinished:(ASIHTTPRequest *)request {
	//NSLog(@"Servers Status Request: %i", [request responseStatusCode]);		
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[request responseData]];
	RSSParser *rssParser = [[RSSParser alloc] init];
	xmlParser.delegate = rssParser;
	if ([xmlParser parse]) {
		self.serversFeedItems = rssParser.feedItems;
		[self appendFeedItems:rssParser.feedItems];
	}
	
	NSLog(@"Servers Feed Item Count: %i", [self.serversFeedItems count]);
	
	[rssParser release];
	[xmlParser release];
	[self.tableView reloadData];
}

- (void)serversStatusRequestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Servers Status Request FAIL");
}

- (void)filesStatusRequestFinished:(ASIHTTPRequest *)request {
	//NSLog(@"Files Status Request: %i", [request responseStatusCode]);		
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[request responseData]];
	RSSParser *rssParser = [[RSSParser alloc] init];
	xmlParser.delegate = rssParser;
	if ([xmlParser parse]) {
		self.filesFeedItems = rssParser.feedItems;
		[self appendFeedItems:rssParser.feedItems];
	}	
	
	NSLog(@"Files Feed Item Count: %i", [self.filesFeedItems count]);
	
	[rssParser release];
	[xmlParser release];
	[self.tableView reloadData];
}

- (void)filesStatusRequestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Files Status Request FAIL");
}

- (void)sitesStatusRequestFinished:(ASIHTTPRequest *)request {
	//NSLog(@"Sites Status Request: %i", [request responseStatusCode]);		
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[request responseData]];
	AtomParser *atomParser = [[AtomParser alloc] init];
	xmlParser.delegate = atomParser;
	if ([xmlParser parse]) {
		self.sitesFeedItems = atomParser.feedItems;
		[self appendFeedItems:atomParser.feedItems];
	}
	
	NSLog(@"Sites Feed Item Count: %i", [self.sitesFeedItems count]);
	
	[atomParser release];
	[xmlParser release];	
	[self.tableView reloadData];
}

- (void)sitesStatusRequestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Sites Status Request FAIL");
}


#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	tableView.backgroundView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];	
	[self loadRSSFeeds];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return [self.feedItems count];
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Cloud Sites";
	} else if (section == 1) {
		return @"Cloud Servers";
	} else {
		return @"Cloud Files";
	}
}
*/

+ (CGFloat) findLabelHeight:(NSString*) text font:(UIFont *)font label:(UILabel *)label {
    CGSize textLabelSize = CGSizeMake(label.frame.size.width, 9000.0f); 
    CGSize stringSize = [text sizeWithFont:font constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeWordWrap];
    return stringSize.height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// make the background transparent here.  won't work in cellForRowAtIndexPath
    cell.backgroundColor = [UIColor clearColor];
	
	// adjust label widths for orientation
	// TODO: this works when it's called, but we need a good place to call reloadData to fire this off
	NSArray *labels = [NSArray arrayWithObjects:[cell viewWithTag:kDateTag], 
					   [cell viewWithTag:kTitleTag], [cell viewWithTag:kBodyTag], [cell viewWithTag:kAuthorTag], nil];

	// label should be 40 pixels less than the cell width for both orientations
	for (int i = 0; i < [labels count]; i++) {
		UILabel *label = (UILabel *) [labels objectAtIndex:i];
		CGRect rect = label.frame;
		rect.size.width = cell.frame.size.width - 40;
		//NSLog(@"width: %f", rect.size.width);
		label.frame = rect;		
	}
	
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
	dateLabel.text = [self dateToString:item.pubDate]; //[item.pubDate description];
	
	UILabel *titleLabel = (UILabel *) [cell viewWithTag:kTitleTag];
	titleLabel.text = item.title;
	
	UILabel *bodyLabel = (UILabel *) [cell viewWithTag:kBodyTag];
	bodyLabel.text = item.content; // item.description;
	
	UILabel *authorLabel = (UILabel *) [cell viewWithTag:kAuthorTag];
	authorLabel.text = [NSString stringWithFormat:@"Posted by %@", item.creator];
	
	// set the height of the title label to fit the size of the string
	CGFloat originalTitleHeight = titleLabel.frame.size.height;	
	CGFloat titleHeight = [[self class] findLabelHeight:item.title font:titleLabel.font label:titleLabel];
	
	CGRect titleRect = titleLabel.frame;
	titleRect.size.height = titleHeight;
	titleLabel.frame = titleRect;
	
	CGFloat originalBodyHeight = bodyLabel.frame.size.height;
	CGFloat bodyHeight = 500.0; //[[self class] findLabelHeight:item.description font:bodyLabel.font label:bodyLabel];
	
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

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// might be slower to make the extra cellForRowAtIndexPath call, but it's flexible and DRY
	return 700.0;
	//return ((UITableViewCell *)[self tableView:aTableView cellForRowAtIndexPath:indexPath]).frame.size.height;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     When a row is selected, set the detail view controller's detail item to the item associated with the selected row.
     */
    //detailViewController.detailItem = [NSString stringWithFormat:@"Row %d", indexPath.row];
}



#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [popoverController release];
    [navigationBar release];
    
    [detailItem release];
	
	[tableView release];
	[nibLoadedFeedItemCell release];
	
	[sitesFeedItems release];
	[serversFeedItems release];
	[filesFeedItems release];
	[feedItems release];
	[super dealloc];
}

@end
