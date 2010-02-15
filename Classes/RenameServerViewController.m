//
//  RenameServerViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "RenameServerViewController.h"
#import "ASICloudServersServerRequest.h"
#import "ASICloudServersServer.h"
#import "TextFieldCell.h"
#import "ServerDetailViewController.h"
#import "SpinnerViewController.h"
#import "UIViewController+SpinnerView.h"


@implementation RenameServerViewController

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)renameServerRequestFinished:(ASICloudServersServerRequest *)request {
	NSLog(@"Rename Response: %i - %@", [request responseStatusCode], [request responseString]);
	[self hideSpinnerView];
	
	if ([request responseStatusCode] == 204) {
		self.serverDetailViewController.server.name = textField.text;
		[self.serverDetailViewController.tableView reloadData];
		[self dismissModalViewControllerAnimated:YES];
	} else {
		NSString *title = @"Error";
		NSString *errorMessage = @"There was a problem renaming your server.";
		switch ([request responseStatusCode]) {
			case 400: // cloudServersFault
				break;
			case 500: // cloudServersFault
				break;
			case 503:
				errorMessage = @"Your server was not renamed because the service is currently unavailable.  Please try again later.";
				break;				
			case 401:
				title = @"Authentication Failure";
				errorMessage = @"Please check your User Name and API Key.";
				break;
			case 409:
				errorMessage = @"Your server cannot be renamed at the moment because it is currently building.";
				break;
			case 413:
				errorMessage = @"Your server cannot be renamed at the moment because you have exceeded your API rate limit.  Please try again later or contact support for a rate limit increase.";
				break;
			default:
				break;
		}
		[self alert:title message:errorMessage];
	}
}

-(void)renameServerRequestFailed:(ASICloudServersServerRequest *)request {
	NSLog(@"Rename Server Request Failed");
	[self hideSpinnerView];
	NSString *title = @"Connection Failure";
	NSString *errorMessage = @"Please check your connection and try again.";
	[self alert:title message:errorMessage];
}

#pragma mark -
#pragma mark Button Handlers

-(void)saveButtonPressed:(id)sender {
	if ([textField.text isEqualToString:@""]) {
		[self alert:@"Error" message:@"Please enter a new server name."];
	} else {
		[self showSpinnerView];
		
		ASICloudServersServerRequest *request = [ASICloudServersServerRequest updateServerNameRequest:self.serverDetailViewController.server.serverId name:textField.text];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(renameServerRequestFinished:)];
		[request setDidFailSelector:@selector(renameServerRequestFailed:)];
		[request startAsynchronous];
	}
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[textField becomeFirstResponder];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Server Name";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return @"The name is a tag for identifying your server. You can change it at any time. When rebuilding your server, this name is used as the hostname.";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		textField = cell.textField;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    
	// TODO: don't show this if the server is not ACTIVE?
	// TODO: verify resize screen
	
    // Configure the cell...
	cell.textLabel.text = @"";
    
    return cell;
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
    [super dealloc];
}

@end
