//
//  ManageBackupSchedulesViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ManageBackupSchedulesViewController.h"
#import "ASICloudServersServerRequest.h"
#import "ServerDetailViewController.h"
#import "ASICloudServersServer.h"
#import "UIViewController+SpinnerView.h"
#import "ASICloudServersBackupSchedule.h"



#define kHeaderSection 0
#define kDailySection 1
#define kWeeklySection 2

@implementation ManageBackupSchedulesViewController

@synthesize serverDetailViewController, tableView;

#pragma mark -
#pragma mark HTTP Response Handlers

// TODO: get this before showing up in this view controller
-(void)listBackupScheduleRequestFinished:(ASICloudServersServerRequest *)request {
	NSLog(@"List Backup Response: %i - %@", [request responseStatusCode], [request responseString]);
	
	if ([request responseStatusCode] == 200) {
		backupSchedule = [[request backupSchedule] retain];
		NSLog(@"Returned backup schedule: %@ %@", backupSchedule.daily, backupSchedule.weekly);
		[tableView reloadData];
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

-(void)listBackupScheduleRequestFailed:(ASICloudServersServerRequest *)request {
	NSLog(@"list backup request failed - %i", [request responseStatusCode]);
	// TODO: handle
}

-(void)updateBackupScheduleRequestFinished:(ASICloudServersServerRequest *)request {
	NSLog(@"List Backup Response: %i - %@", [request responseStatusCode], [request responseString]);
	[self hideSpinnerView];
	
	if ([request responseStatusCode] == 202 || [request responseStatusCode] == 204) {
		backupSchedule = [[request backupSchedule] retain];
		[tableView reloadData];
		[self dismissModalViewControllerAnimated:YES];
	} else {
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"saving your server's backup schedule"];		
	}
}

-(void)updateBackupScheduleRequestFailed:(ASICloudServersServerRequest *)request {
	NSLog(@"update backup request failed - %i", [request responseStatusCode]);
	[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"saving your server's backup schedule"];
}

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender {
	[self showSpinnerView];
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest updateBackupScheduleRequest:self.serverDetailViewController.server.serverId daily:backupSchedule.daily weekly:backupSchedule.weekly];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updateBackupScheduleRequestFinished:)];
	[request setDidFailSelector:@selector(updateBackupScheduleRequestFailed:)];
	[request startAsynchronous];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	
	// NSTimeZone* destinationTimeZone = [NSTimeZone defaultTimeZone];
	// [tz secondsFromGMT];

	hourValues = [[NSArray alloc] initWithObjects:@"No Daily Backup", @"0000-0200", @"0200-0400", @"0400-0600", @"0600-0800", @"0800-1000", @"1000-1200", @"1200-1400", @"1400-1600", @"1800-2000", @"2000-2200", @"2200-0000", nil];
	hourKeys = [[NSArray alloc] initWithObjects:@"DISABLED", @"H_0000_0200", @"H_0200_0400", @"H_0400_0600", @"H_0600_0800", @"H_0800_1000", @"H_1000_1200", @"H_1200_1400", @"H_1400_1600", @"H_1800_2000", @"H_2000_2200", @"H_2200_0000", nil];
	hours = [[NSDictionary alloc] initWithObjects:hourKeys forKeys:hourValues];
	dayValues = [[NSArray alloc] initWithObjects:@"No Weekly Backup", @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
	dayKeys = [[NSArray alloc] initWithObjects:@"DISABLED", @"SUNDAY", @"MONDAY", @"TUESDAY", @"WEDNESDAY", @"THURSDAY", @"FRIDAY", @"SATURDAY", nil];
	days = [[NSDictionary alloc] initWithObjects:dayKeys forKeys:dayValues];
		
	backupSchedule = [[ASICloudServersBackupSchedule alloc] init];
	
	//+ (id)listBackupScheduleRequest:(NSUInteger)serverId
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest listBackupScheduleRequest:self.serverDetailViewController.server.serverId];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(listBackupScheduleRequestFinished:)];
	[request setDidFailSelector:@selector(listBackupScheduleRequestFailed:)];
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == kHeaderSection) {
		return 0;
	} else if (section == kDailySection) {
		return [hours count];
	} else { // kWeeklySection
		return [days count];
	}
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (section == kDailySection) {
		return @"Daily Backup Window (GMT)";
	} else if (section == kWeeklySection) {
		return @"Weekly Backup Window";
	} else {
		return @"";
	}
}


- (NSString *)tableView:(UITableView *)aTableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		// TODO: for some reason this gets clipped if you scroll down and then back up
		return @"The backup service allows you to hold three distinct backup images. The backups are full-system copies of your server. In order to use the daily or weekly scheduled backup you must have an available backup slot.";
	} else {
		return @"";
	}	
}


// hours (GMT): No Daily Backup, 0000-0200, 0200-0400 ... 2200-0000
// TODO: convert to local time?
// NSTimeZone* destinationTimeZone = [NSTimeZone defaultTimeZone];
// [tz secondsFromGMT];
// days: No Weekly Backup sunday-saturday




// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
  
	//NSLog(@"backup: %@ %@", backupSchedule.daily, backupSchedule.weekly);
	
    // Configure the cell...
	if (indexPath.section == kDailySection) {
		NSString *key = [hourKeys objectAtIndex:indexPath.row];
		NSString *value = [hourValues objectAtIndex:indexPath.row];
		
		cell.textLabel.text = value;
		if ([key isEqualToString:backupSchedule.daily]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	} else if (indexPath.section == kWeeklySection) {
		NSString *key = [dayKeys objectAtIndex:indexPath.row];
		NSString *value = [dayValues objectAtIndex:indexPath.row];

		cell.textLabel.text = value;
		if ([key isEqualToString:backupSchedule.weekly]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)aTableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)aTableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kDailySection) {
		NSString *key = [hourKeys objectAtIndex:indexPath.row];
		backupSchedule.daily = key;
	} else if (indexPath.section == kWeeklySection) {
		NSString *key = [dayKeys objectAtIndex:indexPath.row];
		backupSchedule.weekly = key;
	}
	[aTableView reloadData];
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
	[hourKeys release];
	[dayKeys release];
	[backupSchedule release];
	[tableView release];
	[hourValues release];
	[dayValues release];
    [super dealloc];
}


@end

