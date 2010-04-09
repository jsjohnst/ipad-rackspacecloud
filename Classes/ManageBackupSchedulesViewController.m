//
//  ManageBackupSchedulesViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
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

-(void)updateBackupScheduleRequestFinished:(ASICloudServersServerRequest *)request {
	[self hideSpinnerView];
	
	if ([request responseStatusCode] == 202 || [request responseStatusCode] == 204) {
		if (self.serverDetailViewController.server.backupSchedule) {
			[self.serverDetailViewController.server.backupSchedule release];
		}
		self.serverDetailViewController.server.backupSchedule = [[request backupSchedule] retain];
		[tableView reloadData];
		[self.serverDetailViewController loadServer];
		[self dismissModalViewControllerAnimated:YES];
	} else {
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"saving your server's backup schedule"];		
	}
}

-(void)updateBackupScheduleRequestFailed:(ASICloudServersServerRequest *)request {
	[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"saving your server's backup schedule"];
}

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender {
	[self showSpinnerView];
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest updateBackupScheduleRequest:self.serverDetailViewController.server.serverId daily:self.serverDetailViewController.server.backupSchedule.daily weekly:self.serverDetailViewController.server.backupSchedule.weekly];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(updateBackupScheduleRequestFinished:)];
	[request setDidFailSelector:@selector(updateBackupScheduleRequestFailed:)];
	[request startAsynchronous];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	hourValues = [[NSArray alloc] initWithObjects:@"No Daily Backup", @"0000-0200", @"0200-0400", @"0400-0600", @"0600-0800", @"0800-1000", @"1000-1200", @"1200-1400", @"1400-1600", @"1800-2000", @"2000-2200", @"2200-0000", nil];
	hourKeys = [[NSArray alloc] initWithObjects:@"DISABLED", @"H_0000_0200", @"H_0200_0400", @"H_0400_0600", @"H_0600_0800", @"H_0800_1000", @"H_1000_1200", @"H_1200_1400", @"H_1400_1600", @"H_1800_2000", @"H_2000_2200", @"H_2200_0000", nil];
	hours = [[NSDictionary alloc] initWithObjects:hourKeys forKeys:hourValues];
	dayValues = [[NSArray alloc] initWithObjects:@"No Weekly Backup", @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];
	dayKeys = [[NSArray alloc] initWithObjects:@"DISABLED", @"SUNDAY", @"MONDAY", @"TUESDAY", @"WEDNESDAY", @"THURSDAY", @"FRIDAY", @"SATURDAY", nil];
	days = [[NSDictionary alloc] initWithObjects:dayKeys forKeys:dayValues];		
}

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
		return @"The backup service allows you to hold three distinct backup images. The backups are full-system copies of your server. In order to use the daily or weekly scheduled backup you must have an available backup slot.";
	} else {
		return @"";
	}	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
  	
    // Configure the cell...
	if (indexPath.section == kDailySection) {
		NSString *key = [hourKeys objectAtIndex:indexPath.row];
		NSString *value = [hourValues objectAtIndex:indexPath.row];
		
		cell.textLabel.text = value;
		if ([key isEqualToString:self.serverDetailViewController.server.backupSchedule.daily]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	} else if (indexPath.section == kWeeklySection) {
		NSString *key = [dayKeys objectAtIndex:indexPath.row];
		NSString *value = [dayValues objectAtIndex:indexPath.row];

		cell.textLabel.text = value;
		if ([key isEqualToString:self.serverDetailViewController.server.backupSchedule.weekly]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kDailySection) {
		NSString *key = [hourKeys objectAtIndex:indexPath.row];
		self.serverDetailViewController.server.backupSchedule.daily = key;
	} else if (indexPath.section == kWeeklySection) {
		NSString *key = [dayKeys objectAtIndex:indexPath.row];
		self.serverDetailViewController.server.backupSchedule.weekly = key;
	}
	[aTableView reloadData];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[serverDetailViewController release];
	[hours release];
	[days release];
	[hourKeys release];
	[dayKeys release];
	[tableView release];
	[hourValues release];
	[dayValues release];
    [super dealloc];
}

@end
