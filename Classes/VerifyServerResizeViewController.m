//
//  VerifyServerResizeViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/21/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "VerifyServerResizeViewController.h"
#import "UIViewController+RackspaceCloud.h"
#import "ASICloudServersServerRequest.h"
#import "ServerDetailViewController.h"
#import "ASICloudServersServer.h"

@implementation VerifyServerResizeViewController

@synthesize serverDetailViewController;

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)confirmSuccess:(ASICloudServersServerRequest *)request {
	[self.serverDetailViewController loadServer];
	[self dismissModalViewControllerAnimated:YES];
}

-(void)revertSuccess:(ASICloudServersServerRequest *)request {
	[self.serverDetailViewController loadServer];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Is everything working properly?";
	} else {
		return @"Would you like to revert back to the original size?";
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return @"After verification, the old server will be deleted and will be billed at a prorated amount.";
	} else {
		return @"If no verification is made, the resize will be automatically verified after 12 hours.";
	}	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	if (indexPath.section == 0) {
		cell.textLabel.text = @"Confirm Resize";
	} else {
		cell.textLabel.text = @"Rollback Resize";
	}
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		ASICloudServersServerRequest *request = [ASICloudServersServerRequest confirmResizeServerRequest:self.serverDetailViewController.server.serverId];
		[self request:request behavior:@"confirming your server resize" success:@selector(confirmSuccess:)];
	} else if (indexPath.section == 1) {
		ASICloudServersServerRequest *request = [ASICloudServersServerRequest revertResizeServerRequest:self.serverDetailViewController.server.serverId];
		[self request:request behavior:@"reverting your server resize" success:@selector(confirmSuccess:)];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[serverDetailViewController release];
    [super dealloc];
}

@end
