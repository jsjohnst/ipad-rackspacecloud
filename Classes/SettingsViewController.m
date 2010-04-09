//
//  SettingsViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "SettingsViewController.h"
#import "UISwitchCell.h"
#import "AccountViewController.h"

#define kPrimaryAccountSection 0
#define kSecondaryAccountsSection 1
#define kPasswordLockSection 2

@implementation SettingsViewController

@synthesize tableView;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    defaults = [NSUserDefaults standardUserDefaults];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
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
    if (section == kPrimaryAccountSection) {
        return 1;
    } else if (section == kSecondaryAccountsSection) {
        NSDictionary *accounts = [defaults objectForKey:@"secondary_accounts"];
        return [accounts count] + 1;
    } else {
        return 1; // TODO: 2 if yes?
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == kPrimaryAccountSection) {
        return @"Primary Account";
    } else if (section == kSecondaryAccountsSection) {
        return @"Secondary Accounts";
    } else {
        return @"Password Lock";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == kPrimaryAccountSection) {
        return @"This is the account that will appear on the login screen of this application.";
    } else if (section == kSecondaryAccountsSection) {
        return @"To log in with a secondary account, tap the Log Out button above the Services list.";
    } else {
        return @"If the password lock is turned on, you will be prompted to enter the password before you are allowed to view your Cloud Servers or Cloud Files containers.";
    }
}

- (UITableViewCell *)switchCell:(UITableView *)aTableView label:(NSString *)label action:(SEL)action value:(BOOL)value {
	UISwitchCell *cell = (UISwitchCell *)[aTableView dequeueReusableCellWithIdentifier:label];
	
	if (cell == nil) {
		cell = [[UISwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:label delegate:self action:action value:value];
	}
    
    // handle orientation placement issues
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        CGRect frame = CGRectMake(574.0, 9.0, 94.0, 27.0);
        cell.uiSwitch.frame = frame;
    } else {
        CGRect frame = CGRectMake(513.0, 9.0, 94.0, 27.0);
        cell.uiSwitch.frame = frame;
    }
    
	cell.textLabel.text = label;
	
	return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.tableView.backgroundView = nil;
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];        
    }
    
    // Configure the cell...
    cell.textLabel.text = @"Hello world.";
    
    if (indexPath.section == kPrimaryAccountSection) {
        cell.textLabel.text = [defaults stringForKey:@"username_preference"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == kSecondaryAccountsSection) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSDictionary *accounts = [defaults objectForKey:@"secondary_accounts"];
        NSArray *keys = [accounts keysSortedByValueUsingSelector:@selector(compare:)];
        
        if (indexPath.row < [keys count]) {
            cell.textLabel.text = [keys objectAtIndex:indexPath.row];
        } else {
            cell.textLabel.text = @"Add an account...";
        }
    } else if (indexPath.section == kPasswordLockSection) {
        return [self switchCell:aTableView label:@"Password Lock" action:nil value:NO];
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
    
    if (indexPath.section != 2) {
    
        AccountViewController *vc = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil];
        vc.settingsViewController = self;
        vc.primaryAccount = (indexPath.section == 0);
        
        if (indexPath.section == 1) {
            NSDictionary *accounts = [defaults objectForKey:@"secondary_accounts"];
            NSArray *keys = [accounts keysSortedByValueUsingSelector:@selector(compare:)];
            
            if (indexPath.row < [keys count]) {
                vc.originalUsername = [keys objectAtIndex:indexPath.row];
            }
        }
        
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:vc animated:YES];
        [vc release];
        
    }
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
    [tableView release];
    [super dealloc];
}


@end

