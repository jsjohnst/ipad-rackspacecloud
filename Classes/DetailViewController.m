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

static UIImage *usFlag = nil;
static UIImage *ukFlag = nil;


@implementation DetailViewController

@synthesize navigationBar, popoverController, detailItem;
@synthesize sitesFeedItems, serversFeedItems, filesFeedItems;
@synthesize tableView, nibLoadedFeedItemCell, nibLoadedRSSEmptyCell;
@synthesize feedItems;

+(void)initialize {
	usFlag = [[UIImage imageNamed:@"usflag.png"] retain];
	ukFlag = [[UIImage imageNamed:@"ukflag.png"] retain];
}

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

- (void)orientationDidChange:(NSNotification *)notification {
	// reload the table view to correct UILabel widths
	// TODO: make this only call when the rss view is present
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];	
}

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
	[self loadFeedWithURL:@"feed://xxxstatus.rackspacecloud.com/cloudservers/rss.xml" didFinishSelector:@selector(serversStatusRequestFinished:) didFailSelector:@selector(serversStatusRequestFailed:)];
	[self loadFeedWithURL:@"feed://xxxstatus.clouddrive.com/?feed=rss2" didFinishSelector:@selector(filesStatusRequestFinished:) didFailSelector:@selector(filesStatusRequestFailed:)];
	[self loadFeedWithURL:@"feed://xxxstatus.mosso.com/rss.xml" didFinishSelector:@selector(sitesStatusRequestFinished:) didFailSelector:@selector(sitesStatusRequestFailed:)];
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
    requestCompletionCount++;
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[request responseData]];
	RSSParser *rssParser = [[RSSParser alloc] init];
	xmlParser.delegate = rssParser;
	if ([xmlParser parse]) {
		self.serversFeedItems = rssParser.feedItems;
		[self appendFeedItems:rssParser.feedItems];
	}
	
	//NSLog(@"Servers Feed Item Count: %i", [self.serversFeedItems count]);
	
	[rssParser release];
	[xmlParser release];
	[self.tableView reloadData];
}

- (void)serversStatusRequestFailed:(ASIHTTPRequest *)request {
    requestCompletionCount++;
	// TODO: reloadData with nibLoadedRSSEmptyCell if all fail
}

- (void)filesStatusRequestFinished:(ASIHTTPRequest *)request {
    requestCompletionCount++;
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[request responseData]];
	RSSParser *rssParser = [[RSSParser alloc] init];
	xmlParser.delegate = rssParser;
	if ([xmlParser parse]) {
		self.filesFeedItems = rssParser.feedItems;
		[self appendFeedItems:rssParser.feedItems];
	}	
	
	//NSLog(@"Files Feed Item Count: %i", [self.filesFeedItems count]);
	
	[rssParser release];
	[xmlParser release];
	[self.tableView reloadData];
}

- (void)filesStatusRequestFailed:(ASIHTTPRequest *)request {
    requestCompletionCount++;
	// TODO: reloadData with nibLoadedRSSEmptyCell if all fail
}

- (void)sitesStatusRequestFinished:(ASIHTTPRequest *)request {
    requestCompletionCount++;
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[request responseData]];
	AtomParser *atomParser = [[AtomParser alloc] init];
	xmlParser.delegate = atomParser;
	if ([xmlParser parse]) {
		self.sitesFeedItems = atomParser.feedItems;
		[self appendFeedItems:atomParser.feedItems];
	}
	
	//NSLog(@"Sites Feed Item Count: %i", [self.sitesFeedItems count]);
	
	[atomParser release];
	[xmlParser release];	
	[self.tableView reloadData];
}

- (void)sitesStatusRequestFailed:(ASIHTTPRequest *)request {
    requestCompletionCount++;
	// TODO: reloadData with nibLoadedRSSEmptyCell if all fail
}


#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	tableView.backgroundView = nil;
    requestCompletionCount = 0;
    
	// register for rotation events to keep the rss feed width correct
	[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(orientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];	
	[self loadRSSFeeds];
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
}

- (BOOL)allRSSRequestsFailed {
    return [self.feedItems count] == 0 && requestCompletionCount == 3;
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
    NSLog(@"String size height = %f", stringSize.height);
    return stringSize.height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// make the background transparent here.  won't work in cellForRowAtIndexPath
    cell.backgroundColor = [UIColor clearColor];
	
	// adjust label widths for orientation
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

- (UITableViewCell *)tableView:(UITableView *)aTableView supportCellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"SupportCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
		[[NSBundle mainBundle] loadNibNamed:@"RSSEmptyCell" owner:self options:NULL]; 
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
    [nibLoadedRSSEmptyCell release];
	
	[sitesFeedItems release];
	[serversFeedItems release];
	[filesFeedItems release];
	[feedItems release];
	[super dealloc];
    self = nil; // to prevent ASIHttpRequest from calling a deallocated delegate
}

@end
