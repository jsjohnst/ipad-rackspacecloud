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
#import "RSSTableViewDelegateAndDataSource.h"

@implementation DetailViewController

@synthesize navigationBar, popoverController, detailItem;
@synthesize tableView;
@synthesize tableViewDelegate;

#pragma mark -
#pragma mark Managing the popover controller

// When setting the detail item, update the view and dismiss the popover controller if it's showing.
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
	[NSTimer scheduledTimerWithTimeInterval:0.5 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];	
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	tableView.backgroundView = nil;
    
	self.tableViewDelegate = [[RSSTableViewDelegateAndDataSource alloc] initWithTableView:self.tableView];
	self.tableView.delegate = self.tableViewDelegate;
	self.tableView.dataSource = self.tableViewDelegate;
	
	// register for rotation events to keep the rss feed width correct
	[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(orientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];	
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    self.popoverController = nil;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [popoverController release];
    [navigationBar release];
    [detailItem release];	
	[tableView release];
	[tableViewDelegate release];
	[super dealloc];
}

@end
