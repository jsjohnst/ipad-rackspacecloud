//
//  ContainersListViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/31/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ContainersListViewController.h"
#import "ContainerDetailViewController.h"
#import "ContainerRootViewController.h"
#import "RackspaceCloudAppDelegate.h"
#import "ASICloudFilesRequest.h"
#import "ASICloudFilesContainerRequest.h"
#import "ASICloudFilesContainer.h"
#import "ASICloudFilesCDNRequest.h"
#import "UIViewController+RackspaceCloud.h"
#import "UIViewController+SpinnerView.h"
#import "ContainerNavigationController.h"
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
        //app.splitViewController.viewControllers = [NSArray arrayWithObjects:[app.splitViewController.viewControllers objectAtIndex:0], vc, nil];
        
        //[app.splitViewController
        
		//app.splitViewController.delegate = vc;
		// TODO: release vc and navcontroller
		
		// TODO: restore this after handling didSelect
		//[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        [vc showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];
	    // TODO: ContainerViewController here
        // ContainerRootViewController *vc = [[ContainerRootViewController alloc] initWithNoContainersView];    
        // // TODO: subclass the navigationController and override shouldRotate
        // 
        //         
        //         UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        // vc.navigationBar = navigationController.navigationBar;
        //         vc.navigationBar.barStyle = UIBarStyleBlack;
        //         vc.navigationBar.translucent = NO;
        //         vc.detailItem = @"Container Details";    
        // RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
        // app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, navigationController, nil];
        //         //app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, vc, nil];
        // //app.splitViewController.delegate = vc;
        // // TODO: release vc and navcontroller
        //         
        //         [vc showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];
                
	} else {
        ContainerViewController *vc = [[ContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
		vc.container = [containers objectAtIndex:0];
		
		RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:app.masterViewController];
        [navigationController pushViewController:self animated:NO];
		app.splitViewController.viewControllers = [NSArray arrayWithObjects:navigationController, vc, nil];
        //app.splitViewController.viewControllers = [NSArray arrayWithObjects:[app.splitViewController.viewControllers objectAtIndex:0], vc, nil];
        
        //[app.splitViewController
        
		//app.splitViewController.delegate = vc;
		// TODO: release vc and navcontroller
		
		// TODO: restore this after handling didSelect
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        [vc showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];
        //[vc loadFiles];
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
        NSLog(@"%@ - CDN Enabled: %@", container.name, container.cdnEnabled ? @"YES" : @"NO");
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
//	serverDetailViewController = [[ServerDetailViewController alloc] initWithNibName:@"ServerDetailViewController" bundle:nil];
//	serverDetailViewController.serversListViewController = self;
//	serverDetailViewController.detailItem = @"Server Details";
//	serverDetailViewController.server = [servers objectAtIndex:indexPath.row];
//	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
//    app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, serverDetailViewController, nil];
    
    containerViewController = [[ContainerViewController alloc] initWithNibName:@"ContainerViewController" bundle:nil];
    containerViewController.container = [containers objectAtIndex:indexPath.row];
    [containerViewController loadFiles];
    RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];		
    app.splitViewController.viewControllers = [NSArray arrayWithObjects:[app.splitViewController.viewControllers objectAtIndex:0], containerViewController, nil];
    //app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, containerViewController, nil];
    //[containerViewController showRootPopoverButtonItem:app.masterViewController.rootPopoverBarButtonItem];
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
    NSLog(@"container list shouldAutorotateToInterfaceOrientation");
    return YES;
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
