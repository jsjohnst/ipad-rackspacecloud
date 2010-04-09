//
//  ResizeServerViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ResizeServerViewController.h"
#import "ASICloudServersFlavor.h"
#import "ASICloudServersFlavorRequest.h"
#import "ASICloudServersServer.h"
#import "ASICloudServersServerRequest.h"
#import "UIViewController+SpinnerView.h"
#import "ServerDetailViewController.h"


@implementation ResizeServerViewController

@synthesize serverDetailViewController;

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)resizeRequestFinished:(ASICloudServersServerRequest *)request {
	[self hideSpinnerView];
	if ([request isSuccess]) {
		[self.serverDetailViewController loadServer];
		[self dismissModalViewControllerAnimated:YES];
	} else {
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"resizing your server"];
	}
}

-(void)resizeRequestFailed:(ASICloudServersServerRequest *)request {
	[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"resizing your server"];
}


#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender {
	[self showSpinnerView];
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest resizeServerRequest:self.serverDetailViewController.server.serverId flavorId:selectedFlavorId];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(resizeRequestFinished:)];
	[request setDidFailSelector:@selector(resizeRequestFailed:)];
	[request startAsynchronous];	
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	selectedFlavorId = self.serverDetailViewController.server.flavorId;
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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[ASICloudServersFlavorRequest flavors] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Choose a Size";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"Resizes will be charged or credited a prorated amount based upon the difference in cost and the number of days remaining in your billing cycle. Backups are only available for 256 MB, 512 MB, 1 GB and 2 GB Cloud Server sizes. If you choose 4096 MB or greater, any existing backups will be removed.";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	ASICloudServersFlavor *flavor = [[ASICloudServersFlavorRequest flavors] objectAtIndex:indexPath.row];
	cell.textLabel.text = flavor.name;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%iMB RAM, %iGB Disk", flavor.ram, flavor.disk];
	
	if (flavor.flavorId == selectedFlavorId) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    return cell;
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	selectedFlavorId = ((ASICloudServersFlavor *)[[ASICloudServersFlavorRequest flavors] objectAtIndex:indexPath.row]).flavorId;
	[tableView reloadData];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[serverDetailViewController release];
    [super dealloc];
}


@end

