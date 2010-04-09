//
//  ContainersListViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/31/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ContainersListViewController.h"
#import "ContainerRootViewController.h"
#import "RackspaceCloudAppDelegate.h"
#import "ASICloudFilesRequest.h"
#import "ASICloudFilesContainerRequest.h"
#import "ASICloudFilesContainer.h"
#import "ASICloudFilesCDNRequest.h"
#import "UIViewController+RackspaceCloud.h"
#import "UIViewController+SpinnerView.h"
#import "MasterViewController.h"
#import "ContainerViewController.h"

@implementation ContainersListViewController

@synthesize containerViewController;

-(void)preselectContainer {
    
	if ([containers count] == 0) {
        ContainerViewController *vc = [[ContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
		
		RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:app.masterViewController];
        [navigationController pushViewController:self animated:NO];
		app.splitViewController.viewControllers = [NSArray arrayWithObjects:navigationController, vc, nil];
        [vc showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];
	} else {
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];

        if (containerViewController != nil) {
            [containerViewController release];
        }
        containerViewController = [[ContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
        containerViewController.container = [containers objectAtIndex:0];
        [containerViewController loadFiles];
        RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];		
        app.splitViewController.viewControllers = [NSArray arrayWithObjects:[app.splitViewController.viewControllers objectAtIndex:0], containerViewController, nil];
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            // force the button to stay
            [containerViewController showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];        
        }
        
        
        /*
        ContainerViewController *vc = [[ContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
		vc.container = [containers objectAtIndex:0];
		
		RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:app.masterViewController];
        [navigationController pushViewController:self animated:NO];
		app.splitViewController.viewControllers = [NSArray arrayWithObjects:navigationController, vc, nil];
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        [vc showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];
        */
    }
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.opaque = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.opaque = YES;
    [super viewWillAppear:animated];
}


#pragma mark -
#pragma mark HTTP Request Handlers

- (void)listCDNContainersSuccess:(ASICloudFilesCDNRequest *)request {
	NSArray *cdnContainers = [request containers];	
	[containersDict release];
	containersDict = [[NSMutableDictionary alloc] initWithCapacity:[containers count]];
	
	// load up the dict so we can match containers to cdnContainers in O(n) time
	for (int i = 0; i < [containers count]; i++) {
		ASICloudFilesContainer *container = [containers objectAtIndex:i];
		[containersDict setObject:container forKey:container.name];
	}
	
	for (int i = 0; i < [cdnContainers count]; i++) {
		ASICloudFilesContainer *cdnContainer = [cdnContainers objectAtIndex:i];
		ASICloudFilesContainer *container = [containersDict objectForKey:cdnContainer.name];
        //NSLog(@"%@ - CDN Enabled: %@", container.name, container.cdnEnabled ? @"YES" : @"NO");
		container.cdnEnabled = cdnContainer.cdnEnabled;
		container.cdnURL = cdnContainer.cdnURL;
		container.ttl = cdnContainer.ttl;
		container.logRetention = cdnContainer.logRetention;
		container.referrerACL = cdnContainer.referrerACL;
		container.useragentACL = cdnContainer.useragentACL;			
	}
	
	[self preselectContainer];
}

- (void)listContainersSuccess:(ASICloudFilesContainerRequest *)request {
	[self hideSpinnerView];
	[containers release];
	containers = [[NSMutableArray alloc] initWithArray:[request containers]];
	//containers = [[NSMutableArray alloc] initWithCapacity:0]; // TODO: remove!!!  this is for testing
	
	[self request:[ASICloudFilesCDNRequest listRequest] behavior:@"retrieving your CDN containers" success:@selector(listCDNContainersSuccess:) showSpinner:NO];
	[self.tableView reloadData];
}

- (void)loadContainers {
	[self loadContainers:YES];
}

- (void)loadContainers:(BOOL)showSpinner {
	[self request:[ASICloudFilesContainerRequest listRequest] behavior:@"retrieving your containers" success:@selector(listContainersSuccess:)];
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.opaque = YES;

	self.navigationItem.title = @"Containers";
	containers = [[NSMutableArray alloc] init];
	containersDict = [[NSMutableDictionary alloc] init];
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadContainers)];
	refreshButton.style = UIBarStyleBlackOpaque;
	refreshButton.enabled = YES;
	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
	
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self loadContainers];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [containers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	ASICloudFilesContainer *container = [containers objectAtIndex:indexPath.row];	
	cell.textLabel.text = container.name;
    
    return cell;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContainerDetailViewController *vc = [[ContainerDetailViewController alloc] initWithNibName:@"ContainerDetailViewController" bundle:nil];
	vc.detailItem = @"Container Details";	
	vc.container = [containers objectAtIndex:indexPath.row];
	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];    
	app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, vc, nil];
	//app.splitViewController.delegate = vc;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContainerViewController *vc = [[ContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];    
	app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, vc, nil];
}
*/

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (containerRootViewController != nil) {
		[containerRootViewController release];
	}
	containerRootViewController = [[ContainerRootViewController alloc] initWithNibName:@"ContainerRootViewController" bundle:nil];
	//containerRootViewController.serversListViewController = self;
	containerRootViewController.detailItem = @"Container Details";
	containerRootViewController.container = [containers objectAtIndex:indexPath.row];
	
	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];	
    app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, containerRootViewController, nil];
	//app.splitViewController.delegate = containerRootViewController;
}
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (containerViewController != nil) {
		[containerViewController release];
	}
    containerViewController = [[ContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
    containerViewController.container = [containers objectAtIndex:indexPath.row];
    [containerViewController loadFiles];
    RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];		
    app.splitViewController.viewControllers = [NSArray arrayWithObjects:[app.splitViewController.viewControllers objectAtIndex:0], containerViewController, nil];
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        // force the button to stay
        [containerViewController showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];        
    }
    
    [app.masterViewController.popoverController dismissPopoverAnimated:YES];
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath2:(NSIndexPath *)indexPath {

    // TODO: ContainerViewController here
	ContainerRootViewController *vc = [[ContainerRootViewController alloc] initWithNibName:@"ContainerRootViewController" bundle:nil];

	// TODO: subclass the navigationController and override shouldRotate
    //ContainerNavigationController *navigationController = [[ContainerNavigationController alloc] initWithRootViewController:vc];
	vc.navigationBar = navigationController.navigationBar;
	
	//ContainerDetailViewController *vc = [[ContainerDetailViewController alloc] initWithNibName:@"ContainerDetailViewController" bundle:nil];
	vc.detailItem = @"Container Details";	
	vc.container = [containers objectAtIndex:indexPath.row];
    vc.navigationController = navigationController;
	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
    
	app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, navigationController, nil];
    //app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, vc, nil];
	//app.splitViewController.delegate = vc;
	
	// TODO: release vc and navcontroller
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    //NSLog(@"container list shouldAutorotateToInterfaceOrientation");
    return YES;
}

#pragma mark -
#pragma mark Size for popover
// The size the view should be when presented in a popover.
- (CGSize)contentSizeForViewInPopoverView {
    return CGSizeMake(320.0, 600.0);
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[containers release];
	[containersDict release];
    [containerViewController release];
    [super dealloc];
}

@end
