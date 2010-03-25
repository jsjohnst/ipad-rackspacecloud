//
//  ContainerViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ContainerViewController.h"
#import "ASICloudFilesContainer.h"
#import "ASICloudFilesFolder.h"
#import "ASICloudFilesObjectRequest.h"
#import "ASICloudFilesObject.h"
#import "UISwitchCell.h"
#import "UIViewController+SpinnerView.h"
#import "UIViewController+RackspaceCloud.h"


@implementation ContainerViewController

// data
@synthesize container, rootFolder;

// no files view
@synthesize noFilesView, noFilesImage, noFilesTitle, noFilesMessage;

// ui elements
@synthesize tableView;

#pragma mark -
#pragma mark HTTP Request Handlers

-(void)listFilesSuccess:(ASICloudFilesObjectRequest *)request {
	[self hideSpinnerView];
	
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	NSLog(@"CALLING FOLDERS");
	rootFolder = [request folder];
    NSLog(@"files count in root folder: %i", [rootFolder.files count]);
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	NSLog(@"------------------------------------------------------");
	
	[self.tableView reloadData];
}

- (void)loadFiles {
    rootFolder = nil;
	[self request:[ASICloudFilesObjectRequest listRequestWithContainer:self.container.name] behavior:@"listing your files" success:@selector(listFilesSuccess:)];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadFiles];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadFiles];
}

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
    if (container) {
        if (rootFolder) {
            if ([rootFolder.folders count] > 0) {
                return 4;
            } else {
                return 3;
            }            
        } else {
			return 2;
        }
	} else {
		self.tableView.backgroundView = nil;
		self.noFilesView.hidden = NO;
		[self.view bringSubviewToFront:self.noFilesView];
		return 0;
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return 2;
	} else if (section == 1) {
		return 4;
	} else {
		if (rootFolder != nil) {
		    if (section == 2) {
		        if ([rootFolder.folders count] > 0) {
                    return [rootFolder.folders count];
	            } else if ([rootFolder.files count] > 0) {
                    return [rootFolder.files count];
                } else {
                    return 0;
                }
		    } else if (section == 3) {
		        return [rootFolder.files count];
		    } else {
                return 0;
		    }
		} else {
			return 0;
		}
	}
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Overview";
	} else if (section == 1) {
		return @"Content Delivery Network";
	} else {
	    if (section == 2) {
            if ([rootFolder.folders count] > 0) {
                return @"Folders";
            } else if ([rootFolder.files count] > 0) {
                return @"Files";
            } else {
                return 0;
            }
	    } else {
	        if ([rootFolder.files count] > 0) {
                return @"Files";
            } else {
                return @"";
            }
	    }
	}
}


- (UITableViewCell *)switchCell:(UITableView *)aTableView label:(NSString *)label action:(SEL)action value:(BOOL)value {
	UISwitchCell *cell = (UISwitchCell *)[aTableView dequeueReusableCellWithIdentifier:label];
	
	if (cell == nil) {
		cell = [[UISwitchCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:label delegate:self action:action value:value];
	}
    
	cell.textLabel.text = label;
	
	return cell;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	aTableView.backgroundView = nil;
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
	cell.textLabel.text = @"Field";
	cell.detailTextLabel.text = @"Value";
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Container Name";
			cell.detailTextLabel.text = container.name;
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"Size";
			cell.detailTextLabel.text = [container humanizedSize];
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	} else if (indexPath.section == 1) {
		
		if (indexPath.row == 0) {
			return [self switchCell:aTableView label:@"CDN Access Enabled" action:@selector(cdnSwitchChanged:) value:container.cdnEnabled];			
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"CDN URL";
			cell.detailTextLabel.text = container.cdnURL; // TODO: tap with UIActionSheet to copy, email, shorten, etc
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		} else if (indexPath.row == 2) {
			cell.textLabel.text = @"TTL";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", container.ttl]; // TODO: UISlider
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else {
			return [self switchCell:aTableView label:@"CDN Logging Enabled" action:@selector(logSwitchChanged:) value:container.logRetention];			
		}
		
		
	} else if (indexPath.section == 2) {
		// either files or folders
		
        if ([rootFolder.folders count] > 0) {
            ASICloudFilesFolder *folder = [rootFolder.folders objectAtIndex:indexPath.row];
    		cell.textLabel.text = folder.name;
    	    // TODO: include humanized size in folder object and detailText here
    		cell.detailTextLabel.text = [NSString stringWithFormat:@"%i files", [folder.files count]];
        } else {
    		ASICloudFilesObject *file = [rootFolder.files objectAtIndex:indexPath.row];
    		cell.textLabel.text = file.name;
    		cell.detailTextLabel.text = file.contentType;
		}
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
	} else if (indexPath.section == 3) {
	    // definitely files
		ASICloudFilesObject *file = [rootFolder.files objectAtIndex:indexPath.row];
		cell.textLabel.text = file.name;
		cell.detailTextLabel.text = file.contentType;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    [container release];
    [rootFolder release];
    [noFilesView release];
    [noFilesImage release];
    [noFilesTitle release];
    [noFilesMessage release];
    [tableView release];
    
    [super dealloc];
}


@end

