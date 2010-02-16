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
	} else {
		// TODO: deal with it
	}
}

- (void)listServersFailed:(ASICloudServersServerRequest *)request {
	[self hideSpinnerView];
	NSLog(@"List Servers Failed");
}

- (void)loadServers {
	[self showSpinnerView:@"Loading..."];
	ASICloudFilesRequest *request = [ASICloudServersServerRequest listRequest];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(listServersFinished:)];
	[request setDidFailSelector:@selector(listServersFailed:)];
	[request startAsynchronous];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadServers)];
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
	ServerDetailViewController *vc = [[ServerDetailViewController alloc] initWithNibName:@"ServerDetailViewController" bundle:nil];
	vc.detailItem = @"Server Details";
	vc.server = [servers objectAtIndex:indexPath.row];
	
	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
	
    app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, vc, nil];
	app.splitViewController.delegate = vc;
}

- (void)dealloc {
	[servers release];
    [super dealloc];
}


@end

