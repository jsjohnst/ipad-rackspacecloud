//
//  AddServerViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "AddServerViewController.h"
#import "ASICloudServersServer.h"
#import "ASICloudServersImage.h"
#import "ASICloudServersFlavor.h"
#import "ASICloudServersServerRequest.h"
#import "ASICloudServersImageRequest.h"
#import "ASICloudServersFlavorRequest.h"
#import "TextFieldCell.h"
#import "SliderCell.h"
#import "UIViewController+SpinnerView.h"
#import "ServersListViewController.h"
#import "ServerDetailViewController.h"
#import "UIViewController+RackspaceCloud.h"


@implementation AddServerViewController

@synthesize server, serverDetailViewController;

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
	server = [[ASICloudServersServer alloc] init];
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

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
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	} else if (section == 1) {
		return [[ASICloudServersImageRequest images] count];
	} else if (section == 2) {
		return [[ASICloudServersFlavorRequest flavors] count];
	}
	
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Server Name";
	} else if (section == 1) {
		return @"Choose an Image";
	} else if (section == 2) {
		return @"Choose a Flavor";
	}
	
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];		
    }
    
    static NSString *NameCellIdentifier = @"NameCell";
    
    TextFieldCell *nameCell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:NameCellIdentifier];
    if (nameCell == nil) {
        nameCell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NameCellIdentifier] autorelease];
		textField = nameCell.textField;
		textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		textField.delegate = self;
    }
    
	textField.text = server.name;
	
	// TODO: verify resize screen
	
	// TODO: building progress
	
    // Configure the cell...
	cell.textLabel.text = @"";
	
    // Set up the cell...
	if (indexPath.section == 0) {
		return nameCell;
	} else if (indexPath.section == 1) {
		ASICloudServersImage *image = [[ASICloudServersImageRequest images] objectAtIndex:indexPath.row];
		cell.textLabel.text = image.name;
		cell.detailTextLabel.text = @"";
		cell.imageView.image = [ASICloudServersImage iconForImageId:image.imageId];
		if (server.imageId == image.imageId) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	} else if (indexPath.section == 2) {
		ASICloudServersFlavor *flavor = [[ASICloudServersFlavorRequest flavors] objectAtIndex:indexPath.row];
		cell.textLabel.text = flavor.name;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%iMB RAM, %iGB Disk", flavor.ram, flavor.disk];
		cell.imageView.image = nil;
		if (server.flavorId == flavor.flavorId) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
	
	
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];
	if (indexPath.section == 1) {
		ASICloudServersImage *image = [[ASICloudServersImageRequest images] objectAtIndex:indexPath.row];
		server.imageId = image.imageId;
	} else if (indexPath.section == 2) {
		ASICloudServersFlavor *flavor = [[ASICloudServersFlavorRequest flavors] objectAtIndex:indexPath.row];
		server.flavorId = flavor.flavorId;
	}
	[tableView reloadData];
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

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)aTextField {
	server.name = aTextField.text;
}



#pragma mark -
#pragma mark HTTP Response Handlers

-(void)createServerSuccess:(ASICloudServersServerRequest *)request {
	[self.serverDetailViewController.serversListViewController loadServers];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender {	
	if (server.name == nil || [server.name isEqualToString:@""]) {
		[self alert:@"Error" message:@"Please enter a server name."];
	} else if (server.flavorId == 0) {
		[self alert:@"Error" message:@"Please select a flavor."];
	} else if (server.imageId == 0) {
		[self alert:@"Error" message:@"Please select an image."];
	} else {
		// create the server
		[self request:[ASICloudServersServerRequest createServerRequest:server] behavior:@"creating your server" success:@selector(createServerSuccess:)];
	}	
}

- (void)dealloc {
	[server release];
	[serverDetailViewController release];
    [super dealloc];
}


@end

