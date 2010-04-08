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
#import "SettingsViewController.h"
#import "LogoutViewController.h"


@implementation MasterViewController

@synthesize detailViewController;
@synthesize splitViewController;
@synthesize rootPopoverBarButtonItem;
@synthesize popoverController;

#pragma mark -
#pragma mark Log out

- (void)logout {
    LogoutViewController *vc = [[LogoutViewController alloc] initWithNibName:@"LogoutViewController" bundle:nil];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

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
    
    hasPreselected = NO;
	self.navigationItem.title = @"Services";
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
    self.clearsSelectionOnViewWillAppear = NO;
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);

    [super viewDidLoad];	
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.opaque = YES;
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logout)] autorelease];

    [super viewWillAppear:animated];
}

- (void)preselect {
    ((DetailViewController *) detailViewController).detailItem = @"Rackspace Cloud System Status";
    RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];		
    app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, app.detailViewController, nil];
    app.splitViewController.delegate = self;
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    [((DetailViewController *)detailViewController).tableView reloadData];
    hasPreselected = YES;
    selectedIndex = 0;
}

- (void)viewDidAppear:(BOOL)animated {    
    [super viewDidAppear:animated];

    // preselect system status
    /**/
    if (!hasPreselected) {
        [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(preselect) userInfo:nil repeats:NO];	
        ((DetailViewController *)detailViewController).detailItem = @"Rackspace Cloud System Status";
        RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];		
        app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, app.detailViewController, nil];
        app.splitViewController.delegate = self;
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        [((DetailViewController *)detailViewController).tableView reloadData];
        hasPreselected = YES;
        selectedIndex = 0;
    }
    /* */
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
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
//        if (selectedIndex == 0) {
//            cell.selected = YES;
//        }
	} else if (indexPath.row == 1) {
		cell.textLabel.text = @"Cloud Servers";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if (indexPath.row == 2) {
		cell.textLabel.text = @"Cloud Files";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if (indexPath.row == 3) {
		cell.textLabel.text = @"Settings";
		cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.row == 4) {
		cell.textLabel.text = @"Log in as different user";
		cell.accessoryType = UITableViewCellAccessoryNone;
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
		RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];		
        if (detailViewController != nil) {
            [detailViewController release];
        }
        detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];

        app.splitViewController.viewControllers = [NSArray arrayWithObjects:[self.splitViewController.viewControllers objectAtIndex:0], detailViewController, nil];        
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            // force the button to stay
            [detailViewController showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];
        }        
        [popoverController dismissPopoverAnimated:YES];        
	} else if (indexPath.row == 1) {
		ServersListViewController *vc = [[ServersListViewController alloc] initWithNibName:@"ServersListViewController" bundle:nil];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	} else if (indexPath.row == 2) {
		ContainersListViewController *vc = [[ContainersListViewController alloc] initWithNibName:@"ContainersListViewController" bundle:nil];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	} else if (indexPath.row == 3) {
		RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];		
        if (detailViewController != nil) {
            [detailViewController release];
        }
//        detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        
        SettingsViewController *vc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
        detailViewController = vc;
        
        app.splitViewController.viewControllers = [NSArray arrayWithObjects:[self.splitViewController.viewControllers objectAtIndex:0], vc, nil];        
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            // force the button to stay
            //[vc showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];
        }        
        [popoverController dismissPopoverAnimated:YES];
    }
	
}

#pragma mark -
#pragma mark SplitViewController Delegate methods

- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc {	
    NSLog(@"splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc {	");
        
	barButtonItem.title = @"Services"; //self.navigationController.topViewController.navigationItem.title; //@"Button Title";

    self.popoverController = pc;
    
	self.rootPopoverBarButtonItem = barButtonItem;
	UIViewController <SubstitutableDetailViewController> *detailVC = [splitViewController.viewControllers objectAtIndex:1];
    [detailVC showRootPopoverButtonItem:self.rootPopoverBarButtonItem];
}

- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    NSLog(@"splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {");
    UIViewController <SubstitutableDetailViewController> *detailVC = [splitViewController.viewControllers objectAtIndex:1];
    [detailVC invalidateRootPopoverButtonItem:self.rootPopoverBarButtonItem];
    self.popoverController = nil;
    self.rootPopoverBarButtonItem = nil;
}

- (void)splitViewController:(UISplitViewController*)svc popoverController:(UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController {    
    NSLog(@"popover! %@, %@, %@", pc, aViewController, self.rootPopoverBarButtonItem);
    //[popoverController presentPopoverFromBarButtonItem:self.rootPopoverBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    
    [detailViewController release];
    
	self.rootPopoverBarButtonItem = nil;
	self.popoverController = nil;
	self.splitViewController = nil;
    
    [super dealloc];
}

@end
