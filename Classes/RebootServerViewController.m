//
//  RebootServerViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "RebootServerViewController.h"
#import "ServerDetailViewController.h"
#import "ASICloudServersServerRequest.h"
#import "ASICloudServersServer.h"
#import "UIViewController+SpinnerView.h"


@implementation RebootServerViewController

@synthesize serverDetailViewController;

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)rebootRequestFinished:(ASICloudServersServerRequest *)request {
	NSLog(@"Reboot response: %i", [request responseStatusCode]);
	[self hideSpinnerView];
	// TODO: handle error
	
	[self dismissModalViewControllerAnimated:YES];
}

-(void)rebootRequestFailed:(ASICloudServersServerRequest *)request {
	NSLog(@"Reboot request failed.");
	// TODO: handle
}

#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

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
    // Return YES for supported orientations
    return YES;
}

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Select a Reboot Type";
	} else { //if (section == 1) {
		return @"";
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return @"A soft reboot performs a graceful shutdown of your system. Services are halted individually and the system is restarted.";
	} else {
		return @"A hard reboot is the equivalent of unplugging your server. Power is lost immediately.";
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	if (indexPath.section == 0) {
		cell.textLabel.text = @"Perform Soft Reboot";
	} else if (indexPath.section == 1) {
		cell.textLabel.text = @"Perform Hard Reboot";
	}
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)performReboot:(NSString *)rebootType {
	// TODO: perhaps write a generic finish/fail handler?
	[self showSpinnerView:@"Rebooting..."];
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest rebootServerRequest:self.serverDetailViewController.server.serverId rebootType:rebootType];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(rebootRequestFinished:)];
	[request setDidFailSelector:@selector(rebootRequestFailed:)];
	[request startAsynchronous];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	if (indexPath.section == 0) {
		[self performReboot:@"SOFT"];
	} else if (indexPath.section == 1) {
		[self performReboot:@"HARD"];
	}
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

