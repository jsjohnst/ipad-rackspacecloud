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

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

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


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];

	ServerDetailViewController *vc = [[ServerDetailViewController alloc] initWithNibName:@"ServerDetailViewController" bundle:nil];
	vc.detailItem = @"Server Details";
	vc.server = [servers objectAtIndex:indexPath.row];
	
	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
	
    app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, vc, nil];
	app.splitViewController.delegate = vc;
	
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[servers release];
    [super dealloc];
}


@end

