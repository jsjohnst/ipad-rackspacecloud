//
//  ServerDetailViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ServerDetailViewController.h"
#import "MasterViewController.h"
#import "ASICloudServersServer.h"
#import "ASICloudServersImage.h"
#import "ASICloudServersImageRequest.h"
#import "ASICloudServersFlavor.h"
#import "ASICloudServersFlavorRequest.h"
#import "AddServerViewController.h"
#import "RenameServerViewController.h"
#import "ResetServerAdminPasswordViewController.h"
#import "RebootServerViewController.h"
#import "ResizeServerViewController.h"
#import "CreateServerSnapshotViewController.h"
#import "ManageBackupSchedulesViewController.h"
#import "RebuildServerViewController.h"
#import "UIViewController+SpinnerView.h"
#import "ASICloudServersServerRequest.h"
#import "UIViewController+RackspaceCloud.h"
#import "VerifyServerResizeViewController.h"
#import "UIViewController+RackspaceCloud.h"

#import "ServersListViewController.h"


#define kNameSection 0
#define kDetailsSection 1
#define kPublicIPSection 2
#define kPrivateIPSection 3
#define kMetadataSection 4
#define kActionSection 5


@implementation ServerDetailViewController

//@synthesize navigationBar, popoverController, detailItem;
@synthesize tableView;
@synthesize server;
//@synthesize logoImageView;
@synthesize backgroundImageView;
@synthesize noServersView, noServersImage, noServersTitle, noServersMessage;
@synthesize serversListViewController;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

-(id)initWithNoServersView {
    if ((self = [super initWithNibName:@"ServerDetailViewController" bundle:nil])) {
        // Custom initialization
		//self.view.hidden = YES;
		noServersView.hidden = NO;
		[self.view bringSubviewToFront:self.noServersView];
    }
    return self;
}

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)loadServer {
	//[self request:[ASICloudServersServerRequest getServerRequest:self.server.serverId] behavior:@"retrieving your server" success:@selector(getServerSuccess:) showSpinner:NO];
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest getServerRequest:self.server.serverId];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(getServerRequestFinished:)];
	[request setDidFailSelector:@selector(getServerRequestFailed:)];
	[request startAsynchronous];	
}

- (void)listBackupScheduleSuccess:(ASICloudServersServerRequest *)request {
	if ([request isSuccess]) {
		self.server.backupSchedule = [[request backupSchedule] retain];
	}
}

-(void)deleteServerSuccess:(ASICloudServersServerRequest *)request {
    [self.serversListViewController loadServers];
}

-(void)deleteServerRequestFinished:(ASICloudServersServerRequest *)request {
	//NSLog(@"Delete Response: %i - %@", [request responseStatusCode], [request responseString]);
	[self hideSpinnerView];
	
	if ([request responseStatusCode] == 202) {
		[self.serversListViewController loadServers:YES];		
	} else {
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"deleting your server"];
	}
}

-(void)deleteServerRequestFailed:(ASICloudServersServerRequest *)request {
	[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"deleting your server"];
}

-(void)getServerRequestFinished:(ASICloudServersServerRequest *)request {
	//NSLog(@"Poll Server Response: %i - %@ Progress: %i", [request responseStatusCode], [request server].status, [request server].progress);
	if ([request isSuccess]) {
        self.server = [request server];
		ASICloudServersServerRequest *backupRequest = [ASICloudServersServerRequest listBackupScheduleRequest:self.server.serverId];
		[self request:backupRequest behavior:@"retrieving your server's backup schedule" success:@selector(listBackupScheduleSuccess:) showSpinner:NO];
		
		// refresh in the list view so the OS icon and name stay fresh
        [self.serversListViewController refreshServer:self.server];
	}
    [self.tableView reloadData];
}

-(void)getServerRequestFailed:(ASICloudServersServerRequest *)request {
    //NSLog(@"Poll Server Failed");
    [self.tableView reloadData]; // keep polling!
}

#pragma mark -
#pragma mark Progress Bar Animation

- (void)animateProgressBarTo:(float)to {
	if (progressTimer == nil) {
		progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(moveProgress) userInfo:nil repeats:YES];
	}
}

- (void)moveProgress {
	if (progressView.progress < [self.server humanizedProgress] * 0.01) {
		progressView.progress += 0.01;
	} else if (progressView.progress > [self.server humanizedProgress] * 0.01) {
		//progressView.progress = [self.server humanizedProgress] * 0.01;
	} else if (progressView.progress == [self.server humanizedProgress] * 0.01) {
		[progressTimer invalidate];
		progressTimer = nil;
	}
}

#pragma mark -
#pragma mark Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (server) {
		return 6;
	} else {
		// show No Servers View
		//self.logoImageView.image = nil;
		self.backgroundImageView.image = nil;
		self.tableView.backgroundView = nil;
		noServersView.hidden = NO;
		[self.view bringSubviewToFront:self.noServersView];
		return 0;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == kActionSection) {
		return 7;
	} else if (section == kNameSection) {
		if ([server shouldBePolled]) {
			return 4;
		} else {
			return 3;
		}
	} else if (section == kDetailsSection) {
		return 3;
	} else if (section == kPublicIPSection) {
		return [server.publicIpAddresses count];
	} else if (section == kPrivateIPSection) {
		return [server.privateIpAddresses count];
	} else if (section == kMetadataSection) {
        return 0;
		//return [[server.metadata allKeys] count];
	} else {
		return 0;
	}
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	if (section == kNameSection) {
		return @"Overview";
	} else if (section == kDetailsSection) {
		return @"Technical Details";
	} else if (section == kPublicIPSection) {
		return @"Public IP Addresses";
	} else if (section == kPrivateIPSection) {
		return @"Private IP Addresses";
	} else if (section == kMetadataSection) {
//		if ([[server.metadata allKeys] count] > 0) {
//			return @"Server Metadata";
//		} else {
			return @"";
//		}
	}
	
	return @"Actions";
}

- (UITableViewCell *)tableView:(UITableView *)aTableView statusCellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"StatusCell";
	UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	}
	
	cell.textLabel.text = @"Status";
    cell.detailTextLabel.text = [server humanizedStatus];

	//NSLog(@"server status = %@", server.status);
	if ([server.status isEqualToString:@"VERIFY_RESIZE"]) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView progressCellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"ProgressCell";
	UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	cell.textLabel.text = @"Progress";
	
	if ([server shouldBePolled]) {
		if (progressView == nil) {
			progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
			CGRect r = progressView.frame;
            
            if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                r.origin.x += 323;
            } else { // UIInterfaceOrientationLandscapeLeft || UIInterfaceOrientationLandscapeRight	
                r.origin.x += 260;
            }                    
            
            
			r.origin.y += 18;
			r.size.width += 230;
			progressView.frame = r;		
			[cell addSubview:progressView];
		}
		
		// looks weird when you animate the unknown status, since it has 100% progress
		if (![server.status isEqualToString:@"UNKNOWN"]) {
			[self animateProgressBarTo:[self.server humanizedProgress] * 0.01];
		}

		[self loadServer];
	}
	
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//self.logoImageView.image = [ASICloudServersImage logoForImageId:server.imageId];
	self.backgroundImageView.image = [ASICloudServersImage backgroundForImageId:server.imageId];
	self.tableView.backgroundView = nil; // makes it clear
	self.detailItem = @"Server Details";
	self.navigationItem.title = @"Server Details";
	
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	}

	cell.accessoryType = UITableViewCellAccessoryNone;
	
	//if (indexPath.section == kNameSection || indexPath.section == kDetailsSection) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//}

	
	UITableViewCell *actionCell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:@"ActionCell"];
	if (actionCell == nil) {
		actionCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActionCell"] autorelease];
		actionCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		//actionCell.accessoryType = UITableViewCellAccessoryNone;
		actionCell.selectionStyle = UITableViewCellSelectionStyleNone;
		actionCell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
		actionCell.textLabel.backgroundColor = [UIColor clearColor];
		actionCell.detailTextLabel.backgroundColor = [UIColor clearColor];
	}
	
	
	if (indexPath.section == kNameSection) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Server Name";
			cell.detailTextLabel.text = server.name;
		} else if (indexPath.row == 1) {
            return [self tableView:tableView statusCellForRowAtIndexPath:indexPath];
		} else if ((indexPath.row == 2) && [server shouldBePolled]) {
			return [self tableView:tableView progressCellForRowAtIndexPath:indexPath];
		} else { //if (indexPath.row == 2) {
			cell.textLabel.text = @"Host ID";
			cell.detailTextLabel.text = server.hostId;
		}
	} else if (indexPath.section == kDetailsSection) {
		ASICloudServersFlavor *flavor = [ASICloudServersFlavorRequest flavorForId:server.flavorId];
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Operating System";			
			cell.detailTextLabel.text = [ASICloudServersImageRequest imageForId:server.imageId].name;
		} else if (indexPath.row == 1) {
			cell.textLabel.text = @"Memory";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%i MB", flavor.ram];
		} else if (indexPath.row == 2) {
			cell.textLabel.text = @"Disk";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%i GB", flavor.disk];
		}
	} else if (indexPath.section == kActionSection) {
		if (indexPath.row == 0) {
			actionCell.textLabel.text = @"Reboot This Server";
//        } else if (indexPath.row == 1) {
//            // TODO: don't always show this?
//            actionCell.textLabel.text = @"Launch SSH Client";
		} else if (indexPath.row == 1) {
			actionCell.textLabel.text = @"Rename This Server";
		} else if (indexPath.row == 2) {
			actionCell.textLabel.text = @"Resize This Server";
		} else if (indexPath.row == 3) {
			actionCell.textLabel.text = @"Change the Root Password";
		} else if (indexPath.row == 4) {
			actionCell.textLabel.text = @"Manage Backup Schedules";
		} else if (indexPath.row == 5) {
			actionCell.textLabel.text = @"Rebuild This Server"; // From Scratch" ?
		} else if (indexPath.row == 6) {
			actionCell.textLabel.text = @"Delete This Server";
		}
		return actionCell;
	} else if (indexPath.section == kPublicIPSection) {
		cell.textLabel.text = [[server publicIpAddresses] objectAtIndex:indexPath.row];
		cell.detailTextLabel.text = @"";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if (indexPath.section == kPrivateIPSection) {
		cell.textLabel.text = [[server privateIpAddresses] objectAtIndex:indexPath.row];
		cell.detailTextLabel.text = @"";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if (indexPath.section == kMetadataSection) {
//        NSArray *arr = [server.metadata allKeys];
//        for (int i = 0; i < [arr count]; i++) {
//            NSLog(@"key: %@", [arr objectAtIndex:i]);
//        }
//		NSString *key = [[server.metadata allKeys] objectAtIndex:indexPath.row];
//		cell.textLabel.text = key;
//		cell.detailTextLabel.text = [server.metadata objectForKey:key];
		cell.textLabel.text = @"meta";
		cell.detailTextLabel.text = @"meta";
	} else {
		cell.textLabel.text = @"";
		cell.detailTextLabel.text = @"";
	}
	
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	
	if (indexPath.section == kNameSection) {
		if (indexPath.row == 1 && [server.status isEqualToString:@"VERIFY_RESIZE"]) {
			VerifyServerResizeViewController *vc = [[VerifyServerResizeViewController alloc] initWithNibName:@"VerifyServerResizeViewController" bundle:nil];
			vc.modalPresentationStyle = UIModalPresentationFormSheet; 
			vc.serverDetailViewController = self;
			[self presentModalViewController:vc animated:YES];
		}
	} else if (indexPath.section == kActionSection) {
		
		NSString *className = nil;
		
		switch (indexPath.row) {
			case 0:
				className = @"RebootServerViewController";
				break;
			case 1:
                //className = nil; // TODO: restore
				className = @"RenameServerViewController";
				break;
			case 2:
				className = @"ResizeServerViewController";
				break;
			case 3:
				className = @"ResetServerAdminPasswordViewController";
				break;
			case 4:
				className = @"ManageBackupSchedulesViewController";
				break;
			case 5:
				className = @"RebuildServerViewController";
				break;
			default:
				break;
		}

		if (className != nil) {
            
            // it's a modal view controller, so show it
            Class class = NSClassFromString(className);
            UIViewController *vc = [[class alloc] initWithNibName:className bundle:nil];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
            SEL method = NSSelectorFromString(@"setServerDetailViewController:");
            if ([vc respondsToSelector:method]) {
                [vc performSelector:method withObject:self];
            }
            
            [self presentModalViewController:vc animated:YES];
		} else {
//            if (indexPath.row == 1) {
//                NSLog(@"ssh url: %@", [NSString stringWithFormat:@"%@%@", @"ssh://", [server.publicIpAddresses objectAtIndex:0]]);
//                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"ssh://", [server.publicIpAddresses objectAtIndex:0]]];                
//                UIApplication *app = [UIApplication sharedApplication];
//                
//                if ([app canOpenURL:url]) {
//                    [app openURL:url];
//                } else {
//                    NSLog(@"can't open the ssh client url");
//                }
//            } else 
            if (indexPath.row == 6) {
				NSString *title = @"Are you sure you want to delete this server?  This operation cannot be undone and you will lose all backup images.";
				//NSString *deleteTitle = [NSString stringWithFormat:@"Permanently Delete Server %@", self.server.name];
				NSString *deleteTitle = @"Delete This Server";
				
				if (deleteServerActionSheet != nil) {
					[deleteServerActionSheet release];
				}
				deleteServerActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:deleteTitle otherButtonTitles:nil];				
				deleteServerActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
				[deleteServerActionSheet showInView:self.view];
			}			
		}
		
	} else if (indexPath.section == kPublicIPSection) {
		UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];		
		if (publicIPActionSheet != nil) {
			[publicIPActionSheet release];
		}
		//publicIPActionSheet = [[UIActionSheet alloc] initWithTitle:cell.textLabel.text delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Ping IP Address", @"Copy IP Address", @"Open in Safari", nil];
        publicIPActionSheet = [[UIActionSheet alloc] initWithTitle:cell.textLabel.text delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Ping IP Address", @"Copy IP Address", nil];
		// would be nice to show as a popover, but i'm having trouble positioning it properly
		[publicIPActionSheet showInView:self.view];
	} else if (indexPath.section == kPrivateIPSection) {
		UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];		
		if (privateIPActionSheet != nil) {
			[privateIPActionSheet release];
		}		
		privateIPActionSheet = [[UIActionSheet alloc] initWithTitle:cell.textLabel.text delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Copy IP Address", nil];
		// would be nice to show as a popover, but i'm having trouble positioning it properly
		[privateIPActionSheet showInView:self.view];
	}
}

#pragma mark -
#pragma mark Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet == deleteServerActionSheet) {
		if (buttonIndex	== 0) {
			[self request:[ASICloudServersServerRequest deleteServerRequest:self.server.serverId] behavior:@"deleting your server" success:@selector(deleteServerSuccess:) showSpinner:showSpinner];
		}
	} else if (actionSheet == publicIPActionSheet) {
		/*
		 @"Ping IP Address", @"Copy IP Address", @"Open in Safari"
		 
		 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		 [pasteboard setString:@"blah"];
		 
		 NSString *urlString = [NSString stringWithFormat:@"http://just-ping.com/index.php?vh=173.203.209.116&s=ping", cell.textLabel.text];
		 NSURL *url = [NSURL URLWithString:urlString];
		 [[UIApplication sharedApplication] openURL:url];
		 */
		
		NSString *currentIPAddress = actionSheet.title;
		
		if (buttonIndex == 0) {
			NSString *urlString = [NSString stringWithFormat:@"http://just-ping.com/index.php?vh=%@&s=ping", currentIPAddress];
			NSURL *url = [NSURL URLWithString:urlString];
			[[UIApplication sharedApplication] openURL:url];
		} else if (buttonIndex == 1) {
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			[pasteboard setString:currentIPAddress];
		} else if (buttonIndex == 2) {
			NSString *urlString = [NSString stringWithFormat:@"http://%@", currentIPAddress];
			NSURL *url = [NSURL URLWithString:urlString];
			[[UIApplication sharedApplication] openURL:url];
		}
	} else if (actionSheet == privateIPActionSheet) {
		NSString *currentIPAddress = actionSheet.title;
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		[pasteboard setString:currentIPAddress];		
	}
}



#pragma mark -
#pragma mark Button Handlers

-(void)addButtonPressed:(id)sender {
	AddServerViewController *vc = [[AddServerViewController alloc] initWithNibName:@"AddServerViewController" bundle:nil];
	vc.serverDetailViewController = self;
	vc.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:vc animated:YES];
}

#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {	
    showSpinner = (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    [self.tableView reloadData];
	if (fromInterfaceOrientation == UIInterfaceOrientationPortrait || fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.noServersImage.frame = CGRectMake(102, 37, 500, 500);
		self.noServersTitle.frame = CGRectMake(301, 567, 102, 22);
		self.noServersMessage.frame = CGRectMake(196, 623, 323, 21);
	} else { // UIInterfaceOrientationLandscapeLeft || UIInterfaceOrientationLandscapeRight	
		self.noServersImage.frame = CGRectMake(134, 180, 500, 500);
		self.noServersTitle.frame = CGRectMake(333, 710, 102, 22);
		self.noServersMessage.frame = CGRectMake(228, 766, 323, 21);
	}
    
    CGRect r = progressView.frame;    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        r.origin.x = 43 + 678 - 388 - 10;
    } else { // UIInterfaceOrientationLandscapeLeft || UIInterfaceOrientationLandscapeRight	
        r.origin.x = 43 + 678 - 388 - 10 - 63;
    }                    
    progressView.frame = r;
    
}

#pragma mark -
#pragma mark View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		// 704
		
		//self.noServersImage.frame = CGRectMake(102, 134, 500, 500);
	} else { // UIInterfaceOrientationLandscapeLeft || UIInterfaceOrientationLandscapeRight	
		self.noServersImage.frame = CGRectMake(102, 37, 500, 500);
		self.noServersTitle.frame = CGRectMake(301, 567, 102, 22);
		self.noServersMessage.frame = CGRectMake(196, 623, 323, 21);
		
	}
	
	progressTimer = nil;
	progressView = nil;
	
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest listBackupScheduleRequest:self.server.serverId];
	[self request:request behavior:@"retrieving your server's backup schedule" success:@selector(listBackupScheduleSuccess:) showSpinner:NO];	
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    showSpinner = (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);

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

//- (void)viewDidUnload {
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//    self.popoverController = nil;
//}


#pragma mark -
#pragma mark Memory management

/*
 - (void)didReceiveMemoryWarning {
 // Releases the view if it doesn't have a superview.
 [super didReceiveMemoryWarning];
 
 // Release any cached data, images, etc that aren't in use.
 }
 */

- (void)dealloc {
//    [popoverController release];
//    [navigationBar release];
//    [detailItem release];
	
	[tableView release];
	[server release];
	
	//[logoImageView release];
	[backgroundImageView release];
	
	[noServersView release];
	[noServersImage release];
	[noServersTitle release];
	[noServersMessage release];
	
	[serversListViewController release];
	
	if (progressView != nil) {
		[progressView release];
	}
	
	if (deleteServerActionSheet != nil) {
		[deleteServerActionSheet release];
	}
	
	if (publicIPActionSheet != nil) {
		[publicIPActionSheet release];
	}
	
	if (privateIPActionSheet != nil) {
		[privateIPActionSheet release];
	}
	
    [super dealloc];
}

@end
