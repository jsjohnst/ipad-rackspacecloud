//
//  AddServerViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "AddServerViewController.h"
#import "ASICloudServersImage.h"
#import "ASICloudServersFlavor.h"
#import "ASICloudServersImageRequest.h"
#import "ASICloudServersFlavorRequest.h"


@implementation AddServerViewController

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];

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
		
		//cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
	// TODO: make sure images and flavors are ACTIVE
	// TODO: double check logos
	
    // Set up the cell...
	if (indexPath.section == 0) {
		//return @"Server Name";
		cell.textLabel.text = @"";
		cell.detailTextLabel.text = @"";
		cell.imageView.image = nil;
	} else if (indexPath.section == 1) {
		ASICloudServersImage *image = [[ASICloudServersImageRequest images] objectAtIndex:indexPath.row];
		cell.textLabel.text = image.name;
		cell.detailTextLabel.text = @"";
		cell.imageView.image = [ASICloudServersImage iconForImageId:image.imageId];
	} else if (indexPath.section == 2) {
		ASICloudServersFlavor *flavor = [[ASICloudServersFlavorRequest flavors] objectAtIndex:indexPath.row];
		cell.textLabel.text = flavor.name;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%iMB RAM, %iGB Disk", flavor.ram, flavor.disk];
		cell.imageView.image = nil;
	}
	
	
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];
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
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [super dealloc];
}


@end

