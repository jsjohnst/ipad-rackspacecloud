//
//  ManageBackupSchedulesViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ManageBackupSchedulesViewController.h"

#define kHeaderSection 0
#define kDailySection 1
#define kWeeklySection 2

@implementation ManageBackupSchedulesViewController

@synthesize serverDetailViewController;

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	hours = [[NSArray arrayWithObjects:@"No Daily Backup", @"0000-0200", @"0200-0400", @"0400-0600", @"0600-0800", @"0800-1000", @"1000-1200", @"1200-1400", @"1400-1600", @"1800-2000", @"2000-2200", @"2200-0000", nil] retain];
	days = [[NSArray arrayWithObjects:@"No Weekly Backup", @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil] retain];
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

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == kHeaderSection) {
		return 0;
	} else if (section == kDailySection) {
		return [hours count];
	} else { // kWeeklySection
		return [days count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == kDailySection) {
		return @"Daily Backup Window (GMT)";
	} else if (section == kWeeklySection) {
		return @"Weekly Backup Window";
	} else {
		return @"";
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		// TODO: for some reason this gets clipped if you scroll down and then back up
		return @"The backup service allows you to hold three distinct backup images. The backups are full-system copies of your server. In order to use the daily or weekly scheduled backup you must have an available backup slot.";
	} else {
		return @"";
	}	
}


// hours (GMT): No Daily Backup, 0000-0200, 0200-0400 ... 2200-0000
// TODO: convert to local time?
// days: No Weekly Backup sunday-saturday



// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	if (indexPath.section == kDailySection) {
		cell.textLabel.text = [hours objectAtIndex:indexPath.row];
	} else if (indexPath.section == kWeeklySection) {
		cell.textLabel.text = [days objectAtIndex:indexPath.row];
	}
    
    return cell;
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
	[hours release];
	[days release];
    [super dealloc];
}


@end

