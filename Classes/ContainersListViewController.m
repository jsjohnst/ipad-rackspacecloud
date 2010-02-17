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

// TODO: how to extract album art from mp3
// TODO: preview icon as metadata?

@implementation ContainersListViewController

#pragma mark -
#pragma mark HTTP Request Handlers

- (void)listCDNContainersFinished:(ASICloudFilesCDNRequest *)request {
	NSLog(@"CDN GET /containers: %i", [request responseStatusCode]);
	NSLog(@"%@", [request responseString]);

	if ([request responseStatusCode] == 200) {
		
		NSArray *cdnContainers = [request containers];
		
		// update containers with cdnContainers attributes
		NSLog(@"cdnContainers count: %i", [cdnContainers count]);
		
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
		
	} else {
		// TODO: deal with it
	}
}

- (void)listCDNContainersFailed:(ASIHTTPRequest *)request {
	NSLog(@"List CDN Containers Failed");
	// TODO: handle this failure
}

- (void)listContainersFinished:(ASICloudFilesContainerRequest *)request {
	NSLog(@"GET /containers: %i", [request responseStatusCode]);
	NSLog(@"%@", [request responseString]);
	if ([request responseStatusCode] == 200) {
		
		[containers release];
		containers = [[NSMutableArray alloc] initWithArray:[request containers]];
		
		ASICloudFilesCDNRequest *request = [ASICloudFilesCDNRequest listRequest];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(listCDNContainersFinished:)];
		[request setDidFailSelector:@selector(listCDNContainersFailed:)];
		[request startAsynchronous];
		
		//containers = [request containers];
		[self.tableView reloadData];
	} else {
		// TODO: deal with it
	}
}

- (void)listContainersFailed:(ASIHTTPRequest *)request {
	NSLog(@"List Containers Failed");
	// TODO: handle this failure
}


#pragma mark -
#pragma mark View Lifecycle

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	containers = [[NSMutableArray alloc] init];
	containersDict = [[NSMutableDictionary alloc] init];

	
	ASICloudFilesRequest *request = [ASICloudFilesContainerRequest listRequest];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(listContainersFinished:)];
	[request setDidFailSelector:@selector(listContainersFailed:)];
	[request startAsynchronous];
	
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
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    return [containers count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	ASICloudFilesContainer *container = [containers objectAtIndex:indexPath.row];
	
	cell.textLabel.text = container.name;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];
	
	
	ContainerRootViewController *vc = [[ContainerRootViewController alloc] initWithNibName:@"ContainerRootViewController" bundle:nil];
	//ContainerDetailViewController *vc = [[ContainerDetailViewController alloc] initWithNibName:@"ContainerDetailViewController" bundle:nil];
	//vc.detailItem = @"Container Details";
	
	vc.container = [containers objectAtIndex:indexPath.row];
	
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
	[containers release];
	[containersDict release];
    [super dealloc];
}


@end

