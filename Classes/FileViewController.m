//
//  FileViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "FileViewController.h"
#import "ASICloudFilesObject.h"
#import "ASICloudFilesContainer.h"
#import "ASICloudFilesObjectRequest.h"
#import "UIViewController+RackspaceCloud.h"
#import "UIViewController+SpinnerView.h"


@implementation FileViewController

@synthesize container, file, tableView;

#pragma mark -
#pragma mark Initialization

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil container:(ASICloudFilesContainer *)aContainer file:(ASICloudFilesObject *)aFile {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
        container = aContainer;
        file = aFile;
    }
    return self;
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
    return 2; // TODO: consider 3 sections and do metadata
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return 3;
	} else {
		/*
		 Preview File
		 Email Link to File (if CDN enabled)
		 Email File as Attachment
		 Shorten CDN URL with bit.ly (if CDN enabled)
		 Tweet Link to File (if CDN enabled)
		 Delete File
		 */        
        if (container.cdnEnabled) {
            return 4;
        } else {
            return 3;
        }        
	}
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
    }
    
    // Configure the cell...
    //NSLog(@"File: %@, %i, %@", file.name, file.bytes, file.contentType);
    
    if (indexPath.section == 0) {
        // file attributes
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = file.name;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Size";
            cell.detailTextLabel.text = [file humanizedBytes];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Content Type";
            cell.detailTextLabel.text = file.contentType;
        }
    } else if (indexPath.section == 1) {
        // actions
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.detailTextLabel.text = @"";
        
		/*
		 Preview File
		 Email Link to File (if CDN enabled)
		 Email File as Attachment
		 Shorten CDN URL with bit.ly (if CDN enabled)
		 Tweet Link to File (if CDN enabled)
		 Delete File
		 */
        
        if (container.cdnEnabled) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Preview File";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Email Link to File";
            } else if (indexPath.row == 2) {
                cell.textLabel.text = @"Email File as Attachment";
            } else if (indexPath.row == 3) {
                cell.textLabel.text = @"Delete File";
//                cell.textLabel.text = @"Shorten URL with bit.ly";
//            } else if (indexPath.row == 4) {
//                cell.textLabel.text = @"Tweet Link to File";
//            } else if (indexPath.row == 5) {
//                cell.textLabel.text = @"Delete File";
            }
        } else {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Preview File";
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Email File as Attachment";
            } else if (indexPath.row == 2) {
                cell.textLabel.text = @"Delete File";
            }
        }
        
        
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
#pragma mark Actions

- (void)emailLinkToFile {
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;		
    [vc setSubject:self.file.name];
    NSString *emailBody = [NSString stringWithFormat:@"%@/%@", self.container.cdnURL, [self.file.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [vc setMessageBody:emailBody isHTML:NO];
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

- (void)downloadFileToAttachSuccess:(ASICloudFilesObjectRequest *)request {
    [self hideSpinnerView];
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;
    [vc setSubject:self.file.name];
    
    //NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.container.cdnURL, [self.file.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSURL *url = [NSURL URLWithString:urlString];
    //NSData *attachmentData = [NSData dataWithContentsOfURL:url];
    
    ASICloudFilesObject *object = [request object];
    
    [vc addAttachmentData:object.data mimeType:self.file.contentType fileName:self.file.name];
    
    // Fill out the email body text
    NSString *emailBody = @"";
    [vc setMessageBody:emailBody isHTML:NO];
    
    [self presentModalViewController:vc animated:YES];
    [vc release];    
}

- (void)emailFileAsAttachment {
    // TODO: container.name is failing
    //NSLog(@"container name: %@", container.name);
    //NSLog(@"file name:      %@", file.name);
    //NSLog(@"file path:      %@", file.fullPath);
    
    ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest getObjectRequestWithContainer:self.container.name objectPath:self.file.fullPath];
    [self request:request behavior:@"attaching your file" success:@selector(downloadFileToAttachSuccess:)];
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
    if (indexPath.section == 1) {
        if (container.cdnEnabled) {
            if (indexPath.row == 0) {
                //cell.textLabel.text = @"Preview File";
            } else if (indexPath.row == 1) {
                [self emailLinkToFile];
            } else if (indexPath.row == 2) {
                [self emailFileAsAttachment];
            } else if (indexPath.row == 3) {
                // TODO: delete file

//            } else if (indexPath.row == 3) {
//                //cell.textLabel.text = @"Shorten URL with bit.ly";
//            } else if (indexPath.row == 4) {
//                //cell.textLabel.text = @"Tweet Link to File";
//            } else if (indexPath.row == 5) {
//                //cell.textLabel.text = @"Delete File";
            }
        } else {
            if (indexPath.row == 0) {
                //cell.textLabel.text = @"Preview File";
            } else if (indexPath.row == 1) {
                [self emailFileAsAttachment];
            } else if (indexPath.row == 2) {
                //cell.textLabel.text = @"Delete File";
            }
        }
    }
    
}

#pragma mark Mail Composer Delegate

// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
	[self dismissModalViewControllerAnimated:YES];
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
	[file release];
	[tableView release];
    [super dealloc];
}


@end

