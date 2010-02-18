//
//  ServersListViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ServersListViewController.h"
#import "RackspaceCloudAppDelegate.h"
#import "ServerDetailViewController.h"
#import "ASICloudServersServerRequest.h"
#import "ASICloudServersServer.h"
#import "ASICloudServersImage.h"
#import "UIViewController+SpinnerView.h"


@implementation ServersListViewController

@synthesize serverDetailViewController;

-(void)preselectServer {
	if ([servers count] == 0) {
		if (serverDetailViewController != nil) {
			[serverDetailViewController release];
		}
		serverDetailViewController = [[ServerDetailViewController alloc] initWithNoServersView];
		serverDetailViewController.serversListViewController = self;
		serverDetailViewController.detailItem = @"Server Details";
		RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
		app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, serverDetailViewController, nil];
		app.splitViewController.delegate = serverDetailViewController;			
	} else {
		if (serverDetailViewController != nil) {
			[serverDetailViewController release];
		}
		serverDetailViewController = [[ServerDetailViewController alloc] initWithNibName:@"ServerDetailViewController" bundle:nil];
		serverDetailViewController.serversListViewController = self;
		serverDetailViewController.detailItem = @"Server Details";
		serverDetailViewController.server = [servers objectAtIndex:0];
		RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
		app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, serverDetailViewController, nil];
		app.splitViewController.delegate = serverDetailViewController;
		
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
	}
}

#pragma mark -
#pragma mark HTTP Response Handlers

- (void)listServersFinished:(ASICloudServersServerRequest *)request {
	[self hideSpinnerView];
	NSLog(@"GET /servers: %i", [request responseStatusCode]);
	NSLog(@"%@", [request responseString]);
	if ([request responseStatusCode] == 200 || [request responseStatusCode] == 203) {
		
		[servers release];
		servers = [[NSMutableArray alloc] initWithArray:[request servers]];		
		[self.tableView reloadData];
		[self preselectServer];
	} else {
		// TODO: deal with it
	}
}

- (void)listServersFailed:(ASICloudServersServerRequest *)request {
	[self hideSpinnerView];
	NSLog(@"List Servers Failed");
}

- (void)loadServers {
	[self loadServers:YES];
}

- (void)loadServers:(BOOL)showSpinner {
	if (showSpinner) {
		[self showSpinnerView:@"Loading..."];
	}
	ASICloudFilesRequest *request = [ASICloudServersServerRequest listRequest];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(listServersFinished:)];
	[request setDidFailSelector:@selector(listServersFailed:)];
	[request startAsynchronous];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	serverDetailViewController = nil;
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadServers)];
	refreshButton.style = UIBarStyleBlackOpaque;
	refreshButton.enabled = YES;
	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
	
	self.navigationItem.title = @"Servers";
	servers = [[NSMutableArray alloc] init];
		
	[self loadServers];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [servers count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	ASICloudServersServer *server = [servers objectAtIndex:indexPath.row];
	cell.textLabel.text = server.name;
	cell.imageView.image = [ASICloudServersImage iconForImageId:server.imageId];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (serverDetailViewController != nil) {
		[serverDetailViewController release];
	}
	serverDetailViewController = [[ServerDetailViewController alloc] initWithNibName:@"ServerDetailViewController" bundle:nil];
	serverDetailViewController.serversListViewController = self;
	serverDetailViewController.detailItem = @"Server Details";
	serverDetailViewController.server = [servers objectAtIndex:indexPath.row];
	
	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
	
    app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, serverDetailViewController, nil];
	app.splitViewController.delegate = serverDetailViewController;
}

- (void)dealloc {
	[servers release];
	if (serverDetailViewController != nil) {
		[serverDetailViewController release];
	}
    [super dealloc];
}


@end

