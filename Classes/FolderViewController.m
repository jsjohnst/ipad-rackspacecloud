//
//  FolderViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "FolderViewController.h"
#import "ASICloudFilesFolder.h"
#import "ASICloudFilesObject.h"
#import "FileViewController.h"


@implementation FolderViewController

@synthesize container, folder, tableView;

#pragma mark -
#pragma mark Utilities

- (BOOL)hasSubfolders {
	return [folder.folders count] > 0;
}

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([self hasSubfolders]) {
		return 2;
	} else {
		return 1; // just showing files
	}	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		if ([self hasSubfolders]) {
			return [folder.folders count];
		} else {
			return [folder.files count];
		}
	} else {
		// definitely files
		return [folder.files count];
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	aTableView.backgroundView = nil; // transparent background
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
	if (indexPath.section == 0) {
		if ([self hasSubfolders]) {
			ASICloudFilesFolder *subfolder = [folder.folders objectAtIndex:indexPath.row];
			cell.textLabel.text = subfolder.name;
		} else {
			ASICloudFilesObject *file = [folder.files objectAtIndex:indexPath.row];
			cell.textLabel.text = file.name;
		}
	} else {
		ASICloudFilesObject *file = [folder.files objectAtIndex:indexPath.row];
		cell.textLabel.text = file.name;
	}
    
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
		if ([self hasSubfolders]) {
			FolderViewController *vc = [[FolderViewController alloc] initWithNibName:@"FolderViewController" bundle:nil];
			vc.folder = [folder.folders objectAtIndex:indexPath.row];
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
		} else {
            FileViewController *vc = [[FileViewController alloc] initWithNibName:@"FileViewController" bundle:nil];
            vc.file = [folder.files objectAtIndex:indexPath.row];
            vc.container = [self.container retain];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
		}
	} else {
        FileViewController *vc = [[FileViewController alloc] initWithNibName:@"FileViewController" bundle:nil];
        vc.file = [folder.files objectAtIndex:indexPath.row];
        vc.container = [self.container retain];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [container release];
	[folder release];
	[tableView release];
    [super dealloc];
}


@end

