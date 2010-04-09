//
//  AccountViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "AccountViewController.h"
#import "SettingsViewController.h"
#import "TextFieldCell.h"


@implementation AccountViewController

@synthesize navigationItem;
@synthesize settingsViewController;
@synthesize primaryAccount;
@synthesize originalUsername;

#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
    [self.settingsViewController.tableView reloadData];
}

-(void)saveButtonPressed:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *secondaryAccounts = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"secondary_accounts"]];
    
    if (primaryAccount) {
        [defaults setObject:usernameTextField.text forKey:@"username_preference"];
        [defaults setObject:apiKeyTextField.text forKey:@"api_key_preference"];
    } else if (originalUsername) {
        [secondaryAccounts removeObjectForKey:originalUsername];
        [secondaryAccounts setObject:apiKeyTextField.text forKey:usernameTextField.text];
    } else {
        [secondaryAccounts setObject:apiKeyTextField.text forKey:usernameTextField.text];
    }
    
    [defaults setObject:[NSDictionary dictionaryWithDictionary:secondaryAccounts] forKey:@"secondary_accounts"];
    
    [defaults synchronize];
    [self.settingsViewController.tableView reloadData];
    
	[self dismissModalViewControllerAnimated:YES];
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


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (primaryAccount) {
        self.navigationItem.title = @"Primary Account";
    } else if (originalUsername) {
        self.navigationItem.title = @"Edit Account";
        // TODO: show delete button
    } else {
        self.navigationItem.title = @"Add Account";
        [usernameTextField becomeFirstResponder];
    }
}

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
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Username";
    } else {
        return @"API Key";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (indexPath.section == 0) {
		static NSString *CellIdentifier = @"UsernameCell";
		TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			usernameTextField = cell.textField;
			usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		}
		cell.textLabel.text = @"";

        if (primaryAccount) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            usernameTextField.text = [defaults stringForKey:@"username_preference"];
        } else if (originalUsername) {
            usernameTextField.text = originalUsername;
        } else {
            usernameTextField.text = @"";
        }

		return cell;
	} else {
		static NSString *CellIdentifier = @"APIKeyCell";
		TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			apiKeyTextField = cell.textField;
			apiKeyTextField.text = @"";
			apiKeyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
			apiKeyTextField.secureTextEntry = YES;
		}
		cell.textLabel.text = @""; 
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if (primaryAccount) {
            apiKeyTextField.text = [defaults stringForKey:@"api_key_preference"];
        } else if (originalUsername) {
            NSDictionary *secondaryAccounts = [defaults objectForKey:@"secondary_accounts"];
            apiKeyTextField.text = [secondaryAccounts objectForKey:originalUsername];
        } else {
            apiKeyTextField.text = @"";
        }
        
		return cell;
	}
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
    [navigationItem release];
    [settingsViewController release];
    [originalUsername release];
    [super dealloc];
}


@end

