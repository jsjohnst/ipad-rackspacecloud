//
//  ResetServerAdminPasswordViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ResetServerAdminPasswordViewController.h"
#import "ServerDetailViewController.h"
#import "ASICloudServersServerRequest.h"
#import "ASICloudServersServer.h"
#import "TextFieldCell.h"
#import "UIViewController+SpinnerView.h"
#import "UIViewController+RackspaceCloud.h"


@implementation ResetServerAdminPasswordViewController

@synthesize serverDetailViewController;

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)updatePasswordSuccess:(ASICloudServersServerRequest *)request {
	[self hideSpinnerView];
	[self.serverDetailViewController.tableView reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

-(void)updatePasswordRequestFinished:(ASICloudServersServerRequest *)request {
	[self hideSpinnerView];
	
	if ([request responseStatusCode] == 204) {
		[self.serverDetailViewController.tableView reloadData];
		[self dismissModalViewControllerAnimated:YES];
	} else {
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"resetting your password"];
	}
}

-(void)updatePasswordRequestFailed:(ASICloudServersServerRequest *)request {
	[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"resetting your password"];
}

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender {
	if ([textField.text isEqualToString:@""]) {
		[self alert:@"Error" message:@"Please enter a new password."];
	} else if ([confirmTextField.text isEqualToString:@""]) {
		[self alert:@"Error" message:@"Please confirm your new password."];
	} else if (![textField.text isEqualToString:confirmTextField.text]) {
		[self alert:@"Error" message:@"The password and confirmation do not match."];
	} else {
		[self showSpinnerView];		
		ASICloudServersServerRequest *request = [ASICloudServersServerRequest updateServerAdminPasswordRequest:self.serverDetailViewController.server.serverId adminPass:textField.text];
		[self request:request behavior:@"resetting your password" success:@selector(updatePasswordSuccess:)];
	}
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[textField becomeFirstResponder];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
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
		return @"New Password";
	} else { //if (section == 1) {
		return @"Confirm Password";
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return @"The root password will be updated and the server will be restarted.  Please note that this process will only work if you have a user line for \"root\" in your passwd or shadow file.";
	} else {
		return @"";
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (indexPath.section == 0) {
		static NSString *CellIdentifier = @"Cell";
		TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			textField = cell.textField;
			textField.text = @"";
			textField.clearButtonMode = UITextFieldViewModeWhileEditing;
			textField.secureTextEntry = YES;
		}
		cell.textLabel.text = @"";    
		return cell;
	} else {
		static NSString *CellIdentifier = @"ConfirmCell";
		TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			confirmTextField = cell.textField;
			confirmTextField.text = @"";
			confirmTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
			confirmTextField.secureTextEntry = YES;
		}
		cell.textLabel.text = @"";    
		return cell;
	}
	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[serverDetailViewController release];
    [super dealloc];
}


@end

