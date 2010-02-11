//
//  MasterViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ServersListViewController.h"
#import "ContainersListViewController.h"
#import "RackspaceCloudAppDelegate.h"


@implementation MasterViewController

@synthesize detailViewController;


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


#pragma mark -
#pragma mark Size for popover
// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}


#pragma mark -
#pragma mark View lifecycle


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.title = @"Services";
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
    [super viewDidLoad];	
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
/*
- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}
 */

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"CellIdentifier";
	
	// Dequeue or create a cell of the appropriate type.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	
    // Get the object to display and set the value in the cell.
	if (indexPath.row == 0) {
		cell.textLabel.text = @"System Status";
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else if (indexPath.row == 1) {
		cell.textLabel.text = @"Cloud Servers";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.textLabel.text = @"Cloud Files";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     When a row is selected, set the detail view controller's detail item to the item associated with the selected row.
     */
	
	if (indexPath.row == 0) {
		detailViewController.detailItem = @"Rackspace Cloud System Status";
		RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];		
		app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, app.detailViewController, nil];
		app.splitViewController.delegate = app.detailViewController;
	} else if (indexPath.row == 1) {
		ServersListViewController *vc = [[ServersListViewController alloc] initWithNibName:@"ServersListViewController" bundle:nil];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	} else if (indexPath.row == 2) {
		ContainersListViewController *vc = [[ContainersListViewController alloc] initWithNibName:@"ContainersListViewController" bundle:nil];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	}
	
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    
    [detailViewController release];
    [super dealloc];
}

@end
