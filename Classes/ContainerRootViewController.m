//
//  ContainerRootViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ContainerRootViewController.h"
#import "ASICloudFilesContainer.h"
#import "ASICloudFilesObject.h"
#import "UISwitchCell.h"
#import "ASICloudFilesObjectRequest.h"
#import "UIViewController+SpinnerView.h"
#import "UIViewController+RackspaceCloud.h"
#import "RackspaceCloudAppDelegate.h"


@implementation ContainerRootViewController

@synthesize container;
@synthesize tableView;
@synthesize navigationBar;
@synthesize noFilesView, noFilesImage, noFilesTitle, noFilesMessage;

#pragma mark -
#pragma mark HTTP Request Handlers

// TODO: figure out UIDocumentInteractionController

-(void)listFilesSuccess:(ASICloudFilesObjectRequest *)request {
	[self hideSpinnerView];
	files = [[NSArray alloc] initWithArray:[request objects]];
	
	NSLog(@"files count = %d", [files count]);
	
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark View lifecycle

-(id)initWithNoContainersView {
    if ((self = [super initWithNibName:@"ContainerRootViewController" bundle:nil])) {
        // Custom initialization
		//self.view.hidden = YES;
		noFilesView.hidden = NO;
		[self.view bringSubviewToFront:self.noFilesView];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Overview", @"Files", @"Analytics", nil]];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.frame = CGRectMake(231.0, 7.0, 307.0, 29.0);
	segmentedControl.selectedSegmentIndex = 0;
	self.navigationItem.titleView = segmentedControl;
	
	[segmentedControl release];
	
	
	files = nil;
	
	[self request:[ASICloudFilesObjectRequest listRequestWithContainer:self.container.name] behavior:@"listing your files" success:@selector(listFilesSuccess:)];
	
	
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	
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

#pragma mark -
#pragma mark Rotation Support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	
	if (fromInterfaceOrientation == UIInterfaceOrientationPortrait || fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.noFilesImage.frame = CGRectMake(102, 37, 500, 500);
		self.noFilesTitle.frame = CGRectMake(301, 567, 102, 22);
		self.noFilesMessage.frame = CGRectMake(196, 623, 323, 21);
	} else { // UIInterfaceOrientationLandscapeLeft || UIInterfaceOrientationLandscapeRight	
		self.noFilesImage.frame = CGRectMake(134, 180, 500, 500);
		self.noFilesTitle.frame = CGRectMake(333, 710, 102, 22);
		self.noFilesMessage.frame = CGRectMake(228, 766, 323, 21);
	}
}

#pragma mark -
#pragma mark Switch Handlers

- (void)cdnSwitchChanged:(id)sender {
	NSLog(@"cdn switch tapped %@", sender);
}

- (void)logSwitchChanged:(id)sender {
	NSLog(@"log switch tapped %@", sender);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (container) {
		return 3;
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
		if (files != nil) {
			return [files count];
		} else {
			return 0;
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Overview";
	} else if (section == 1) {
		return @"Content Delivery Network";
	} else {
		return @"Files";
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
		
		
	} else if (indexPath.section > 1) {
		// either files or folders
		ASICloudFilesObject *file = [files objectAtIndex:indexPath.row];
		cell.textLabel.text = file.name;
		cell.detailTextLabel.text = file.contentType;
	}
    
    return cell;
}


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
#pragma mark TODO: move this.  document interaction experiments

-(void)fileDownloadSuccess:(ASICloudFilesObjectRequest *)request {
	[self hideSpinnerView];
	
	ASICloudFilesObject *file = [request object];

	RackspaceCloudAppDelegate *app = [[UIApplication sharedApplication] delegate];
	NSURL *url = [NSURL fileURLWithPath:[[app applicationDocumentsDirectory] stringByAppendingPathComponent:file.name]];
	NSLog(@"file url: %@", url);

	NSData *data = file.data;
	[data writeToURL:url atomically:YES];
	
	UIDocumentInteractionController *c = [UIDocumentInteractionController interactionControllerWithURL:url];
	//- (BOOL)presentOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated
	c.delegate = self;
	//[c presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];	
	if ([c presentPreviewAnimated:YES] == NO) {
		NSLog(@"UIDocumentInteractionController did not work.");
	}
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	return self;
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
	
	ASICloudFilesObject *file = [files objectAtIndex:indexPath.row];
	ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest getObjectRequestWithContainer:self.container.name objectPath:file.name];
	[self request:request behavior:@"downloading the file" success:@selector(fileDownloadSuccess:)];
	
	/*
	ContainerRootViewController *vc = [[ContainerRootViewController alloc] initWithNibName:@"ContainerRootViewController" bundle:nil];
	vc.container = self.container;
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
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
	if (files != nil) {
		[files release];
	}
	[tableView release];
	[navigationBar release];
	[noFilesView release];
	[noFilesImage release];
	[noFilesTitle release];
	[noFilesMessage release];
    [super dealloc];
}


@end

