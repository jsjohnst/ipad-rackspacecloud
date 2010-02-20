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
#import "UIViewController+RackspaceCloud.h"


@implementation RenameServerViewController

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)serverRenameSuccess:(ASICloudServersServerRequest *)request {
	self.serverDetailViewController.server.name = textField.text;
	[self.serverDetailViewController.tableView reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Button Handlers

-(void)saveButtonPressed:(id)sender {
	if ([textField.text isEqualToString:@""]) {
		[self alert:@"Error" message:@"Please enter a new server name."];
	} else {
		[self request:[ASICloudServersServerRequest updateServerNameRequest:self.serverDetailViewController.server.serverId name:textField.text] behavior:@"renaming your server" success:@selector(serverRenameSuccess:)];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"RenameCell";
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		textField = cell.textField;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }    
    return cell;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [super dealloc];
}

@end
