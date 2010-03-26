//
//  ContainerDetailViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/31/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ContainerDetailViewController.h"
#import "ASICloudFilesContainer.h"
#import "ASICloudFilesObjectRequest.h"
#import "ASICloudFilesObject.h"
#import <math.h>
#import "MMCommonLogEntry.h"


// TODO: don't forget delete functionality
// TODO: pinch gesture for traffic graph

// Segments
#define kFilesSegment 0
#define kLogsSegment 1
#define kTrafficSegment 2
#define kUserAgentsSegment 3

@implementation ContainerDetailViewController

@synthesize navigationBar, popoverController, detailItem;
@synthesize container;
@synthesize nameLabel, sizeLabel;
@synthesize cdnUrlTextField;
@synthesize ttlSlider;
@synthesize ttlLabel;
@synthesize nibLoadedLogEntryCell, logEntryTableView;
@synthesize segmentedControl;
@synthesize fileTableView;
@synthesize userAgentPieChartView;
@synthesize userAgentTableView;
@synthesize trafficTableView;
@synthesize filesSegmentView, logsSegmentView, trafficSegmentView, userAgentsSegmentView;
@synthesize trafficLineGraphView, trafficDataForGraph;

// Core Plot
@synthesize userAgentDataForChart;

#pragma mark -
#pragma mark Humanization

-(NSString *)humanizedBytes {	
	NSInteger b = container.bytes;
	NSString *result;	
	if (b >= 1024000000) {
		result = [NSString stringWithFormat:@"%.2f GB", b / 1024000000.0];
	} else if (b >= 1024000) {
		result = [NSString stringWithFormat:@"%.2f MB", b / 1024000.0];
	} else if (b >= 1024) {
		result = [NSString stringWithFormat:@"%.2f KB", b / 1024.0];
	} else {
		result = [NSString stringWithFormat:@"%i %@", container.bytes, @"bytes"];
	}
	return result;
}

-(NSString *)humanizedCount {
	NSString *noun = @"files";
	if (container.count == 1) {
		noun = @"file";
	}
	return [NSString stringWithFormat:@"%i %@", container.count, noun];
}

#pragma mark -
#pragma mark HTTP Response Handlers

#pragma mark Log Files

-(void)getLogFileRequestFinished:(ASICloudFilesObjectRequest *)request {
	//NSLog(@"Log file request: %i - %@", [request responseStatusCode], [request url]);
	ASICloudFilesObject	*object = [request unzippedObject];
	
	////NSLog(@"%@", object.data);
	
	NSString* string = [[NSString alloc] initWithData:object.data encoding:NSASCIIStringEncoding];
	NSArray *entries = [string componentsSeparatedByString:@"\r\n"];
	
	for (int i = 0; i < [entries count]; i++) {
		//NSString *entry = [entries objectAtIndex:i];
		MMCommonLogEntry *entry = [[MMCommonLogEntry alloc] initWithLogEntryText:[entries objectAtIndex:i]];
		
		[logEntries addObject:entry.fullLogEntry];

		// TODO: also count file downloads
		
		// keep a count of the user agents.  this might look weird, but it's 
		// Common Log Format, so don't worry about it :)
		// we're just keeping a count of the number of times each user agent string shows up
		// maybe later i'll get fancy and group multiple browser versions together
		//NSString *userAgent = [[entry componentsSeparatedByString:@"\""] objectAtIndex:5];
		//NSLog(@"User Agent: %@", entry.userAgent);
		//NSLog(@"Browser: %@", entry.browser);
		NSNumber *count = [NSNumber numberWithUnsignedInt:0];
		count = [userAgentCounts objectForKey:entry.browser];
		if (count != nil) {
			count = [NSNumber numberWithUnsignedInt:1 + [count unsignedIntValue]];
		} else {
			count = [NSNumber numberWithUnsignedInt:1];
		}
		[userAgentCounts setObject:count forKey:entry.browser];		
		
		//[entry release]; // TODO
	}
	
	[string release];
	
	sortedUserAgentCountKeys = [[NSArray alloc] initWithArray:[userAgentCounts keysSortedByValueUsingSelector:@selector(compare:)]];
	
	// sort user agents by count	
	[userAgentPieChart reloadData];
	[self.logEntryTableView reloadData];
}

-(void)getLogFileRequestFailed:(ASICloudFilesObjectRequest *)request {
	//NSLog(@"Log file request failed.");
}

-(void)logFileListRequestFinished:(ASICloudFilesObjectRequest *)request {
	//NSLog(@"Log files request: %i", [request responseStatusCode]);
	//containerLogFileObjects = [request objects];
	containerLogFileObjects = [[NSArray alloc] initWithArray:[request objects]];
	
	logEntries = [[NSMutableArray alloc] initWithCapacity:5];
	userAgentCounts = [[NSMutableDictionary alloc] init];
	//NSLog(@"Number of log files: %i", [containerLogFileObjects count]);
	//[self.logEntryTableView reloadData];
	
	// load up to 25 log files to view
	for (int i = 0; i < MIN(25, [containerLogFileObjects count]); i++) {
		ASICloudFilesObject *cfObj = [containerLogFileObjects objectAtIndex:i];
		ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest getObjectRequestWithContainer:@".CDN_ACCESS_LOGS" objectPath:cfObj.name];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(getLogFileRequestFinished:)];
		[request setDidFailSelector:@selector(getLogFileRequestFailed:)];
		[request startAsynchronous];
	}
}

-(void)logFileListRequestFailed:(ASIHTTPRequest *)request {
	//NSLog(@"Log files request failed.");
}

//+ (id)logFileListForCDNEnabledContainer:(NSString *)containerName

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
    
    barButtonItem.title = @"Servers";
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
#pragma mark Core Plot Setup

-(void) layoutUserAgentPieChart {
    // Create pieChart from theme
    userAgentPieChart = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	//CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
	CPTheme *theme = [CPTheme themeNamed:kCPPlainBlackTheme];
    [userAgentPieChart applyTheme:theme];
	
	// Customize the plain black theme to remove the white border
	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
	borderLineStyle.lineColor = [CPColor blackColor];
	borderLineStyle.lineWidth = 1.0;
	userAgentPieChart.plotArea.borderLineStyle = borderLineStyle;
	
	CPLayerHostingView *hostingView = self.userAgentPieChartView;
    hostingView.hostedLayer = userAgentPieChart;
    userAgentPieChart.plotArea.masksToBorder = NO;
	
    userAgentPieChart.paddingLeft = 20.0;
	userAgentPieChart.paddingTop = 20.0;
	userAgentPieChart.paddingRight = 20.0;
	userAgentPieChart.paddingBottom = 20.0;
	
	userAgentPieChart.axisSet = nil;
	
    // Add pie chart
    CPPieChart *piePlot = [[CPPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius = 130.0;
    piePlot.identifier = @"Pie Chart 1";
	piePlot.startAngle = M_PI_4;
	piePlot.sliceDirection = CPPieDirectionCounterClockwise;
    [userAgentPieChart addPlot:piePlot];
    [piePlot release];
	
	// Add some initial data
	NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:nil];
	self.userAgentDataForChart = contentArray;
	
#ifdef PERFORMANCE_TEST
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif
}

-(void) layoutTrafficLineGraph {
    // If you make sure your dates are calculated at noon, you shouldn't have to 
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate = [NSDate date]; //[NSDate dateWithNaturalLanguageString:@"12:00 Oct 29, 2009"];
    NSTimeInterval oneDay = 24 * 60 * 60;
	
    // Create graph from theme
    trafficGraph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPPlainBlackTheme];
	[trafficGraph applyTheme:theme];
	
	// Customize the plain black theme to remove the white border
	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
	borderLineStyle.lineColor = [CPColor blackColor];
	borderLineStyle.lineWidth = 1.0;
	trafficGraph.plotArea.borderLineStyle = borderLineStyle;
	
	self.trafficLineGraphView.hostedLayer = trafficGraph;
    
    // Setup scatter plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)trafficGraph.defaultPlotSpace;
    NSTimeInterval xLow = 0.0f;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(xLow) length:CPDecimalFromFloat(oneDay*5.0f)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(3.0)];
    
    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)trafficGraph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPDecimalFromFloat(oneDay);
    x.constantCoordinateValue = CPDecimalFromString(@"2");
    x.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTimeFormatter *timeFormatter = [[[CPTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;
	
    CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPDecimalFromString(@"0.5");
    y.minorTicksPerInterval = 5;
    y.constantCoordinateValue = CPDecimalFromFloat(oneDay);
	
    // Create a plot that uses the data source method
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Date Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 3.f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
    dataSourceLinePlot.dataSource = self;
    [trafficGraph addPlot:dataSourceLinePlot];
	
    // Add some data
	NSMutableArray *newData = [NSMutableArray array];
	NSUInteger i;
	for ( i = 0; i < 5; i++ ) {
		NSTimeInterval x = oneDay*i;
		id y = [NSDecimalNumber numberWithFloat:1.2*rand()/(float)RAND_MAX + 1.2];
		[newData addObject:
		 [NSDictionary dictionaryWithObjectsAndKeys:
		  [NSDecimalNumber numberWithFloat:x], [NSNumber numberWithInt:CPScatterPlotFieldX], 
		  y, [NSNumber numberWithInt:CPScatterPlotFieldY], 
		  nil]];
	}
	trafficDataForGraph = newData;
}


#pragma mark -
#pragma mark Segmented Control Handler

- (void)segmentedControlChanged:(id)sender {
	int index = self.segmentedControl.selectedSegmentIndex;
	
	if (index == kFilesSegment) {
		currentTableView = self.fileTableView;
	} else if (index == kLogsSegment) {
		currentTableView = self.logEntryTableView;
	} else if (index == kTrafficSegment) {
		currentTableView = self.trafficTableView;
	} else if (index == kUserAgentsSegment) {
		currentTableView = self.userAgentTableView;
	}
	
	self.filesSegmentView.hidden = (index != kFilesSegment);
	self.logsSegmentView.hidden = (index != kLogsSegment);
	self.trafficSegmentView.hidden = (index != kTrafficSegment);
	self.userAgentsSegmentView.hidden = (index != kUserAgentsSegment);

	[currentTableView reloadData];
}

#pragma mark -
#pragma mark Slider Handler

// - (void)setValue:(float)value animated:(BOOL)animated

- (void)ttlSliderMoved:(id)sender {
	NSUInteger ttl = (NSUInteger) self.ttlSlider.value;
	if (ttl == 1) {
		self.ttlLabel.text = @"1 Hour";
	} else {
		self.ttlLabel.text = [NSString stringWithFormat:@"%i Hours", ttl];
	}
	
	// TODO: set timer, and then make API call to update TTL
}

#pragma mark -
#pragma mark Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return NO;
}

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
	self.nameLabel.text = container.name;
	self.sizeLabel.text = [NSString stringWithFormat:@"%@, %@", [self humanizedCount], [self humanizedBytes]];
	//NSLog(@"CDN URL: %@", container.cdnURL);
	self.cdnUrlTextField.text = container.cdnURL;
	self.cdnUrlTextField.delegate = self;
	
	//if (container.cdnEnabled) {
		ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest logFileListForCDNEnabledContainer:self.container.name];
		containerLogFileObjects = nil;
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(logFileListRequestFinished:)];
		[request setDidFailSelector:@selector(logFileListRequestFailed:)];
		[request startAsynchronous];
	//}
	
	[self layoutUserAgentPieChart];
	[self layoutTrafficLineGraph];
	[self segmentedControlChanged:nil];
}

#pragma mark -
#pragma mark Table Views

#pragma mark Files

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInFilesSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView fileCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// transparent background.  TODO: put this in a better place
	aTableView.backgroundView = nil;
	aTableView.backgroundColor = [UIColor clearColor];
	
	UITableView *tableView = self.logEntryTableView;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogEntryCell"];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"LogEntryCell" owner:self options:NULL]; 
		cell = nibLoadedLogEntryCell;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}


#pragma mark Logs

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInLogsSection:(NSInteger)section {
	if (containerLogFileObjects != nil) {
		return [logEntries count];
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)aTableView logCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// transparent background.  TODO: put this in a better place
	aTableView.backgroundView = nil;
	aTableView.backgroundColor = [UIColor clearColor];
	
	UITableView *tableView = self.logEntryTableView;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogEntryCell"];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"LogEntryCell" owner:self options:NULL]; 
		cell = nibLoadedLogEntryCell;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	UILabel *label = (UILabel *)[cell viewWithTag:1];
	label.text = [logEntries objectAtIndex:indexPath.row];
	
    return cell;
}


#pragma mark Traffic

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInTrafficSection:(NSInteger)section {
	return 7;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView trafficCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// transparent background.  TODO: put this in a better place
	aTableView.backgroundView = nil;
	aTableView.backgroundColor = [UIColor clearColor];
	
	UITableView *tableView = self.logEntryTableView;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogEntryCell"];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"LogEntryCell" owner:self options:NULL]; 
		cell = nibLoadedLogEntryCell;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}


#pragma mark User Agents

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInUserAgentsSection:(NSInteger)section {
	return [userAgentCounts count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView userAgentCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// transparent background.  TODO: put this in a better place
	aTableView.backgroundView = nil;
	aTableView.backgroundColor = [UIColor clearColor];
	
	UITableView *tableView = self.logEntryTableView;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogEntryCell"];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"LogEntryCell" owner:self options:NULL]; 
		cell = nibLoadedLogEntryCell;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	UILabel *label = (UILabel *)[cell viewWithTag:1];
	NSString *key = [sortedUserAgentCountKeys objectAtIndex:[sortedUserAgentCountKeys count] - indexPath.row - 1];
	NSNumber *value = [userAgentCounts objectForKey:key];
	label.text = [NSString stringWithFormat:@"%u - %@", [value unsignedIntValue], key];
	
    return cell;
}


#pragma mark Dispatch and Utilities

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	if (aTableView == self.fileTableView) {
		return [self tableView:aTableView numberOfRowsInFilesSection:section];
	} else if (aTableView == self.logEntryTableView) {
		return [self tableView:aTableView numberOfRowsInLogsSection:section];
	} else if (aTableView == self.trafficTableView) {
		return [self tableView:aTableView numberOfRowsInTrafficSection:section];
	} else if (aTableView == self.userAgentTableView) {
		return [self tableView:aTableView numberOfRowsInUserAgentsSection:section];
	} else {
		return 0;
	}
}

+ (CGFloat) findLabelHeight:(NSString*) text font:(UIFont *)font label:(UILabel *)label {
    CGSize textLabelSize = CGSizeMake(label.frame.size.width, 9000.0f); 
    CGSize stringSize = [text sizeWithFont:font constrainedToSize:textLabelSize lineBreakMode:UILineBreakModeWordWrap];
    return stringSize.height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	// make the background transparent here.  won't work in cellForRowAtIndexPath
    cell.backgroundColor = [UIColor clearColor];
	
	// adjust label widths for orientation
	/*
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
	*/
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (aTableView == self.fileTableView) {
		return [self tableView:aTableView fileCellForRowAtIndexPath:indexPath];
	} else if (aTableView == self.logEntryTableView) {
		return [self tableView:aTableView logCellForRowAtIndexPath:indexPath];
	} else if (aTableView == self.trafficTableView) {
		return [self tableView:aTableView trafficCellForRowAtIndexPath:indexPath];
	} else if (aTableView == self.userAgentTableView) {
		return [self tableView:aTableView userAgentCellForRowAtIndexPath:indexPath];
	} else {
		return nil;
	}	
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// might be slower to make the extra cellForRowAtIndexPath call, but it's flexible and DRY
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
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {	
	NSArray *keys = sortedUserAgentCountKeys;
	[userAgentDataForChart removeAllObjects];
	for (int i = 0; i < [keys count]; i++) {
		[userAgentDataForChart addObject:[userAgentCounts objectForKey:[keys objectAtIndex:[keys count] - i - 1]]];
	}
    return [self.userAgentDataForChart count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	if ( index >= [self.userAgentDataForChart count] ) return nil;
	
	if ( fieldEnum == CPPieChartFieldSliceWidth ) {
		return [self.userAgentDataForChart objectAtIndex:index];
	} else {
		return [NSNumber numberWithInt:index];
	}
}

/*-(CPFill *)sliceFillForPieChart:(CPPieChart *)pieChart recordIndex:(NSUInteger)index; 
 {
 return nil;
 }*/


#pragma mark -
#pragma mark Memory Management

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


- (void)dealloc {
	[container release];
	[nameLabel release];
	[sizeLabel release];
	[cdnUrlTextField release];
	[ttlSlider release];
	[ttlLabel release];
	[nibLoadedLogEntryCell release];
	[logEntryTableView release];
	[segmentedControl release];
	[fileTableView release];
	[userAgentDataForChart release];
	[userAgentPieChartView release];
	[userAgentTableView release];
	[trafficLineGraphView release];
	[trafficDataForGraph release];
	if (containerLogFileObjects != nil) {
		[containerLogFileObjects release];
	}
	if (userAgentCounts != nil) {
		[userAgentCounts release];
	}
	if (sortedUserAgentCountKeys != nil) {
		[sortedUserAgentCountKeys release];
	}
	[filesSegmentView release];
	[logsSegmentView release];
	[trafficSegmentView release];
	[userAgentsSegmentView release];
	[trafficTableView release];
    [super dealloc];
}


@end
