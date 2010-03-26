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
#import "UIViewController+RackspaceCloud.h"
#import "MasterViewController.h"


@implementation ServersListViewController

@synthesize serverDetailViewController;

-(void)refreshServer:(ASICloudServersServer *)server {
    for (int i = 0; i < [servers count]; i++) {
        ASICloudServersServer *currentServer = [servers objectAtIndex:i];
        if (currentServer.serverId == server.serverId) {
            [servers replaceObjectAtIndex:i withObject:server];
            [self.tableView reloadData];            
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
            break;
        }
    }
}

-(void)preselectServer {
    RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
	if ([servers count] == 0) {
		if (serverDetailViewController != nil) {
			[serverDetailViewController release];
		}
		serverDetailViewController = [[ServerDetailViewController alloc] initWithNoServersView];
		serverDetailViewController.serversListViewController = self;
		serverDetailViewController.detailItem = @"Server Details";
		app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, serverDetailViewController, nil];
		//app.splitViewController.delegate = serverDetailViewController;
        [serverDetailViewController showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];
	} else {
		if (serverDetailViewController != nil) {
			[serverDetailViewController release];
		}
		serverDetailViewController = [[ServerDetailViewController alloc] initWithNibName:@"ServerDetailViewController" bundle:nil];
		serverDetailViewController.serversListViewController = self;
		serverDetailViewController.detailItem = @"Server Details";
		serverDetailViewController.server = [servers objectAtIndex:0];
		app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, serverDetailViewController, nil];
		//app.splitViewController.delegate = serverDetailViewController;
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        [serverDetailViewController showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];
	}
    
    
}

#pragma mark -
#pragma mark HTTP Response Handlers

- (void)listServersSuccess:(ASICloudServersServerRequest *)request {
	[self hideSpinnerView];
	[servers release];
	servers = [[NSMutableArray alloc] initWithArray:[request servers]];		
	[self.tableView reloadData];
	[self preselectServer];
}

- (void)loadServers {
	[self loadServers:YES];
}

- (void)loadServers:(BOOL)showSpinner {
	[self request:[ASICloudServersServerRequest listRequest] behavior:@"retrieving your servers" success:@selector(listServersSuccess:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	serverDetailViewController = nil;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadServers)];
	refreshButton.style = UIBarStyleBlackOpaque;
	refreshButton.enabled = YES;
	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
	
	self.navigationItem.title = @"Servers";
	servers = [[NSMutableArray alloc] init];
		
	[self loadServers];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.opaque = YES;
    [super viewWillAppear:animated];
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
	//app.splitViewController.delegate = serverDetailViewController;
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        // force the button to stay
        [serverDetailViewController showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];        
    }
    
}

- (void)dealloc {
	[servers release];
	if (serverDetailViewController != nil) {
		[serverDetailViewController release];
	}
    [super dealloc];
}


@end

