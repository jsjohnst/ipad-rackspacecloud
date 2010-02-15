//
//  ResetServerAdminPasswordViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ResetServerAdminPasswordViewController.h"
#import "ServerDetailViewController.h"
#import "ASICloudServersServerRequest.h"
#import "ASICloudServersServer.h"
#import "TextFieldCell.h"
#import "UIViewController+SpinnerView.h"


@implementation ResetServerAdminPasswordViewController

@synthesize serverDetailViewController;

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)updatePasswordRequestFinished:(ASICloudServersServerRequest *)request {
	[self hideSpinnerView];
	NSLog(@"Rename Response: %i - %@", [request responseStatusCode], [request responseString]);
	
	if ([request responseStatusCode] == 204) {
		[self dismissModalViewControllerAnimated:YES];
		//self.serverDetailViewController.server.name = textField.text;
		[self.serverDetailViewController.tableView reloadData];
		[self dismissModalViewControllerAnimated:YES];
	} else {
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"resetting your password"];
	}
}

-(void)updatePasswordRequestFailed:(ASICloudServersServerRequest *)request {
	NSLog(@"Rename Server Request Failed");
	[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"resetting your password"];
}

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender {
	[self showSpinnerView];
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest updateServerAdminPasswordRequest:self.serverDetailViewController.server.serverId adminPass:textField.text];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updatePasswordRequestFinished:)];
	[request setDidFailSelector:@selector(updatePasswordRequestFailed:)];
	[request startAsynchronous];
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

//If you have lost or forgotten the root/administrator password for your Cloud Server, use the button below to reset it.

//Your server will be gracefully shutdown, the root/administrator password will be updated and the server will be restarted. You will receive the new password via email.

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return @"The root password will be updated and the server will be restarted.  Please note that this process will only work if you have a user line for \"root\" in your passwd or shadow file.";
	} else {
		return @"";
	}
}



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		textField = cell.textField;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.secureTextEntry = YES;
    }
    
    // Configure the cell...
	cell.textLabel.text = @"";
    
    return cell;
}


// Override to support conditional editing of the table view.
/*
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


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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

