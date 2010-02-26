    //
//  AuthenticationViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "ASICloudFilesRequest.h"
#import "RackspaceCloudAppDelegate.h"
#import "ASICloudServersImageRequest.h"
#import "ASICloudServersFlavorRequest.h"
#import "UIViewController+SpinnerView.h"
#import "FeedItem.h"
#import "AtomParser.h"
#import "RSSParser.h"

// Feed Item Cell Tags
#define kDateTag 1
#define kTitleTag 2
#define kBodyTag 3
#define kAuthorTag 4

static UIImage *usFlag = nil;
static UIImage *ukFlag = nil;

@implementation AuthenticationViewController

@synthesize smallSpinner, largeSpinner;
@synthesize smallAuthenticatingLabel, largeAuthenticatingLabel;
@synthesize usernameTextField, apiKeyTextField;

@synthesize statusButton, statusScrollView;
@synthesize statusView;
@synthesize statusToolbar;
@synthesize tableView;

@synthesize feedItems, sitesFeedItems, serversFeedItems, filesFeedItems;
@synthesize nibLoadedFeedItemCell, nibLoadedRSSEmptyCell;

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
#pragma mark HTTP Requests

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

-(void)loadFlavors {
	ASICloudServersFlavorRequest *flavorRequest = [ASICloudServersFlavorRequest listRequest];
	[flavorRequest setDelegate:self];
	[flavorRequest setDidFinishSelector:@selector(flavorListRequestFinished:)];
	[flavorRequest setDidFailSelector:@selector(flavorListRequestFailed:)];
	[flavorRequest startAsynchronous];
}

-(void)loadImages {
	ASICloudServersImageRequest *imageRequest = [ASICloudServersImageRequest listRequest];
	[imageRequest setDelegate:self];
	[imageRequest setDidFinishSelector:@selector(imageListRequestFinished:)];
	[imageRequest setDidFailSelector:@selector(imageListRequestFailed:)];
	[imageRequest startAsynchronous];
}



#pragma mark -
#pragma mark View Lifecycle


/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// we'll try up to three times to load flavors and images
	imageLoadAttempts = 0;
	flavorLoadAttempts = 0;
    rssRequestCompletionCount = 0;

	
	//statusToolbar
	CGAffineTransform transform = self.statusToolbar.transform;
	self.statusToolbar.transform = CGAffineTransformRotate(transform, 4.71238898); //1.57079633);
	//CGContextRotateCTM(myContext, radians(–45.));
	
	statusView.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundView = nil; // clear background
}

- (BOOL)allRSSRequestsFailed {
    return [self.feedItems count] == 0 && rssRequestCompletionCount == 3;
}


- (void)viewWillAppear:(BOOL)animated {	
	[self loadSettings];
	[self loadRSSFeeds];
	[super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Utilities

-(void)loadSettings {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	username = [defaults stringForKey:@"username_preference"];
	apiKey = [defaults stringForKey:@"api_key_preference"];
	
	if (username == nil) {
		username = @"";
		apiKey = @"";
		
		// settings haven't been created, so let's create them here
		NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"", @"username_preference",
									 @"", @"api_key_preference",
									 nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	self.usernameTextField.text = username;
	self.apiKeyTextField.text = apiKey;
}

-(void)hideSpinners {
	self.smallAuthenticatingLabel.text = @"";
	self.smallAuthenticatingLabel.hidden = YES;
	[self.smallSpinner stopAnimating];
}

#pragma mark -
#pragma mark Animations

-(void)transitionComplete {
	[self.view removeFromSuperview];
}

-(void)transitionToAppView {
	
	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
	app.splitViewController.view.alpha = 0.0;
	[app.window addSubview:app.splitViewController.view];
	//[app.window makeKeyAndVisible];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(transitionComplete)];
	//CGRect disappearFrame = self.view.frame;
	//disappearFrame.origin.x -= 768;
	self.view.alpha = 0.0;
	app.splitViewController.view.alpha = 1.0;
	
	//self.view.frame = disappearFrame;	
	[UIView commitAnimations];
	
}

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)flavorListRequestFinished:(ASICloudServersFlavorRequest *)request {
	[self hideSpinners];	
	[ASICloudServersFlavorRequest setFlavors:[request flavors]];
	
	// we're done.  now let's get to the app
	[self transitionToAppView];
}

-(void)flavorListRequestFailed:(ASIHTTPRequest *)request {
	flavorLoadAttempts++;
	if (flavorLoadAttempts < 3) {
		// try again
		[self loadFlavors];
	} else {
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"loading server flavors"];
		[self hideSpinners];
	}
}

-(void)imageListRequestFinished:(ASICloudServersImageRequest *)request {
	[ASICloudServersImageRequest setImages:[request images]];
	self.smallAuthenticatingLabel.text = @"Loading server flavors...";
	[self loadFlavors];
}

-(void)imageListRequestFailed:(ASIHTTPRequest *)request {
	imageLoadAttempts++;
	if (imageLoadAttempts < 3) {
		// try again
		[self loadImages];
	} else {
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"loading server images"];
		[self hideSpinners];
	}
	
}

-(void)authenticationRequestFinished:(ASICloudFilesRequest *)request {
	if ([request isSuccess]) {
		NSDictionary *responseHeaders = [request responseHeaders];
		[ASICloudFilesRequest setAuthToken:[responseHeaders objectForKey:@"X-Auth-Token"]];
		[ASICloudFilesRequest setStorageURL:[responseHeaders objectForKey:@"X-Storage-Url"]];
		[ASICloudFilesRequest setCdnManagementURL:[responseHeaders objectForKey:@"X-Cdn-Management-Url"]];
		[ASICloudFilesRequest setServerManagementURL:[responseHeaders objectForKey:@"X-Server-Management-Url"]];	
		self.smallAuthenticatingLabel.text = @"Loading server images...";
		[self loadImages];
	} else {
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"authenticating"];
		[self hideSpinners];
	}	
}

-(void)authenticationRequestFailed:(ASIHTTPRequest *)request {

	[self hideSpinners];
	
	NSString *title = @"";
	NSString *message = @"";
	
	if ([request responseStatusCode] == 401) {
		title = @"Authentication Failure";
		message = @"Please check your User Name and API Key.";
	} else {
		title = @"Connection Failure";
		message = @"Please check your connection and try again.";
	}
	
	[self alert:title message:message];
	self.smallAuthenticatingLabel.text = @"";
	
}

- (void)appendFeedItems:(NSMutableArray *)newFeedItems {
	if (self.feedItems == nil) {
		self.feedItems = [[NSMutableArray alloc] initWithCapacity:[newFeedItems count]];
	}	
	[self.feedItems addObjectsFromArray:newFeedItems];
	[self.feedItems sortUsingSelector:@selector(compare:)];
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
	
	//NSLog(@"Servers Feed Item Count: %i", [self.serversFeedItems count]);
	
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
	
	//NSLog(@"Files Feed Item Count: %i", [self.filesFeedItems count]);
	
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
	
	//NSLog(@"Sites Feed Item Count: %i", [self.sitesFeedItems count]);
	
	[atomParser release];
	[xmlParser release];	
	[self.tableView reloadData];
}

- (void)sitesStatusRequestFailed:(ASIHTTPRequest *)request {
    rssRequestCompletionCount++;
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Button Handlers

-(void)loginButtonPressed:(id)sender {
	
	// validate input
	username = self.usernameTextField.text;
	apiKey = self.apiKeyTextField.text;
	
	if ([username isEqualToString:@""] || [apiKey isEqualToString:@""]) {
		[self alert:@"Required Fields Missing" message:@"Please enter your Rackspace Cloud User Name and API Key."];
	} else {
		
		// save to defaults
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
		[defaults setObject:username forKey:@"username_preference"];
		[defaults setObject:apiKey forKey:@"api_key_preference"];
		
		self.smallAuthenticatingLabel.text = @"Authenticating...";
		
		// attempt to login
		self.smallAuthenticatingLabel.hidden = NO;
		[self.smallSpinner startAnimating];
		
		[ASICloudFilesRequest setUsername:username];
		[ASICloudFilesRequest setApiKey:apiKey];
		ASICloudFilesRequest *request = [ASICloudFilesRequest authenticationRequest];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(authenticationRequestFinished:)];
		[request setDidFailSelector:@selector(authenticationRequestFailed:)];
		[request startAsynchronous];
	}
	
}


#pragma mark -
#pragma mark System Status Support

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {	
	for (UITouch *touch in touches) {
		CGPoint newPosition = [touch locationInView:self.statusView];		
		if (newPosition.x >= 0) {
			dragging = YES;
			if (CGRectContainsPoint(self.statusView.frame, newPosition)) {
				startPosition = newPosition;
				break; // only care about the first touch
			}
		}
	}	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (dragging) {
		for (UITouch *touch in touches) {
			CGPoint windowPosition = [touch locationInView:self.view];
			CGRect rect = self.statusView.frame;
			float newX = rect.origin.x - (rect.origin.x - windowPosition.x);
			
			if (newX >= 270.0 && newX <= 980.0) {
				rect.origin.x = newX;
				startPosition = windowPosition;
				self.statusView.frame = rect;
			}
			break; // only care about the first touch
		}		
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGRect rect = self.statusView.frame;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelegate:self];
	if (statusViewExpanded) {
		if (rect.origin.x > 300.0) {
			rect.origin.x = 980.0;
			statusViewExpanded = NO;
		} else {
			rect.origin.x = 270.0;
			statusViewExpanded = YES;
		}
	} else {
		if (rect.origin.x < 889.0) {
			rect.origin.x = 270.0;
			statusViewExpanded = YES;
		} else {
			rect.origin.x = 980.0;
			statusViewExpanded = NO;
		}
	}
	self.statusView.frame = rect;
	dragging = NO;
	[UIView commitAnimations];
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
    //NSLog(@"String size height = %f", stringSize.height);
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
#pragma mark Memory Management

- (void)dealloc {
	[smallSpinner release];
	[largeSpinner release];
	[smallAuthenticatingLabel release];
	[largeAuthenticatingLabel release];
	[usernameTextField release];
	[apiKeyTextField release];
	
	[statusButton release];
	[statusScrollView release];
	[statusView release];
	[statusToolbar release];
	[tableView release];
	
	[feedItems release];
	[sitesFeedItems release];
	[serversFeedItems release];
	[filesFeedItems release];
	
	[nibLoadedFeedItemCell release];
    [nibLoadedRSSEmptyCell release];
	
    [super dealloc];

}


@end
