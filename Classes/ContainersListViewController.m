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

// TODO: how to extract album art from mp3
// TODO: preview icon as metadata?

@implementation ContainersListViewController

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
		container.cdnEnabled = cdnContainer.cdnEnabled;
		container.cdnURL = cdnContainer.cdnURL;
		container.ttl = cdnContainer.ttl;
		container.logRetention = cdnContainer.logRetention;
		container.referrerACL = cdnContainer.referrerACL;
		container.useragentACL = cdnContainer.useragentACL;			
	}
}

- (void)listContainersSuccess:(ASICloudFilesContainerRequest *)request {
	[containers release];
	containers = [[NSMutableArray alloc] initWithArray:[request containers]];
	[self request:[ASICloudFilesCDNRequest listRequest] behavior:@"retrieving your CDN containers" success:@selector(listCDNContainersSuccess:)];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//ContainerRootViewController *vc = [[ContainerRootViewController alloc] initWithNibName:@"ContainerRootViewController" bundle:nil];
	ContainerDetailViewController *vc = [[ContainerDetailViewController alloc] initWithNibName:@"ContainerDetailViewController" bundle:nil];
	vc.detailItem = @"Container Details";	
	vc.container = [containers objectAtIndex:indexPath.row];
	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
    app.splitViewController.viewControllers = [NSArray arrayWithObjects:self.navigationController, vc, nil];
	app.splitViewController.delegate = vc;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[containers release];
	[containersDict release];
    [super dealloc];
    self = nil; // to prevent ASIHttpRequest from calling a deallocated delegate
}

@end
