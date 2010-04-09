//
//  DetailViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "MasterViewController.h"
#import "ASIHTTPRequest.h"
#import "RSSParser.h"
#import "AtomParser.h"
#import "FeedItem.h"
#import "RSSTableViewDelegateAndDataSource.h"

@implementation DetailViewController

@synthesize tableView;
@synthesize tableViewDelegate;

#pragma mark -
#pragma mark Rotation support

- (void)orientationDidChange:(NSNotification *)notification {
	// reload the table view to correct UILabel widths
	[NSTimer scheduledTimerWithTimeInterval:0.25 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];	
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark View lifecycle

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

#pragma mark -
#pragma mark Defined in SubstitutableDetailViewController protocol
/*
- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem 
{
	[navigationBar.topItem setLeftBarButtonItem:barButtonItem animated:NO];
}

- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem
{
	[navigationBar.topItem setLeftBarButtonItem:nil animated:NO];
}
*/

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[tableView release];
	[tableViewDelegate release];
	[super dealloc];
}

@end
