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
#import "SliderCell.h"
#import "UIViewController+SpinnerView.h"
#import "UIViewController+RackspaceCloud.h"
#import "ASICloudFilesCDNRequest.h"


@implementation ContainerViewController

// data
@synthesize container, rootFolder;

// no files view
@synthesize noFilesView, noFilesImage, noFilesTitle, noFilesMessage;

// ui elements
@synthesize tableView, ttlSlider;

#pragma mark -
#pragma mark HTTP Request Handlers

-(void)listFilesSuccess:(ASICloudFilesObjectRequest *)request {
	[self hideSpinnerView];
	
	if (currentFolderNavigation != nil) {
        [currentFolderNavigation release];
        currentFolderNavigation = [[NSMutableArray alloc] initWithCapacity:10];
	}
	
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"CALLING FOLDERS");
	rootFolder = [request folder];
    //NSLog(@"adding to currentFolderNavigation");
    [currentFolderNavigation addObject:rootFolder];
    //NSLog(@"currentFolderNavigation has %i objects", [currentFolderNavigation count]);
    //     //NSLog(@"files count in root folder: %i", [rootFolder.files count]);
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
    // //NSLog(@"------------------------------------------------------");
	
	[self.tableView reloadData];
}

- (void)ttlUpdateSuccess:(ASICloudFilesCDNRequest *)request {
    //NSLog(@"TTL update response: %i", [request responseStatusCode]);
    [self hideSpinnerView];
}

- (void)cdnEnableSuccess:(ASICloudFilesCDNRequest *)request {
    //NSLog(@"CDN enable response: %i", [request responseStatusCode]);
    [self hideSpinnerView];
    [self.tableView reloadData];
}

- (void)cdnLoggingSuccess:(ASICloudFilesCDNRequest *)request {
    //NSLog(@"CDN logging response: %i", [request responseStatusCode]);
    [self hideSpinnerView];
}

- (void)loadFiles {
    rootFolder = nil;
    [self request:[ASICloudFilesObjectRequest listRequestWithContainer:self.container.name] behavior:@"listing your files" success:@selector(listFilesSuccess:)];
}

#pragma mark -
#pragma mark Switch Handlers

- (void)cdnSwitchChanged:(id)sender {
    UISwitch *uiSwitch = (UISwitch *)sender;
	//NSLog(@"cdn switch tapped %@", sender);
    
    // now, this is a little weird.  if a container has never been CDN enabled, you must enable with a PUT.
    // if it has ever been CDN enabled, you must use post
    
    if (self.container.cdnEnabled) {
        // definitely a POST
        ASICloudFilesCDNRequest *request = [ASICloudFilesCDNRequest postRequestWithContainer:self.container.name cdnEnabled:uiSwitch.on ttl:self.container.ttl loggingEnabled:self.container.logRetention];
        [self request:request behavior:@"updating CDN attributes" success:@selector(cdnEnableSuccess:) showSpinner:showSpinner];
    } else {
        if (uiSwitch.on) {
            ASICloudFilesCDNRequest *request = [ASICloudFilesCDNRequest putRequestWithContainer:self.container.name];
            [self request:request behavior:@"updating CDN attributes" success:@selector(cdnEnableSuccess:) showSpinner:showSpinner];        
            ASICloudFilesCDNRequest *postRequest = [ASICloudFilesCDNRequest postRequestWithContainer:self.container.name cdnEnabled:uiSwitch.on ttl:self.container.ttl loggingEnabled:self.container.logRetention];
            [self request:postRequest behavior:@"updating CDN attributes" success:@selector(cdnEnableSuccess:) showSpinner:NO];        
        } else {
            ASICloudFilesCDNRequest *request = [ASICloudFilesCDNRequest postRequestWithContainer:self.container.name cdnEnabled:uiSwitch.on ttl:self.container.ttl loggingEnabled:self.container.logRetention];
            [self request:request behavior:@"updating CDN attributes" success:@selector(cdnEnableSuccess:) showSpinner:showSpinner];        
        }
        
    }
    
    self.container.cdnEnabled = uiSwitch.on;
    
}

//- (void)logSwitchChanged:(id)sender {
//    UISwitch *uiSwitch = (UISwitch *)sender;
//	//NSLog(@"log switch tapped %@, %i", sender, uiSwitch.on);
//    ASICloudFilesCDNRequest *request = [ASICloudFilesCDNRequest postRequestWithContainer:self.container.name cdnEnabled:self.container.cdnEnabled ttl:self.container.ttl loggingEnabled:uiSwitch.on];
//    [self request:request behavior:@"updating the TTL" success:@selector(ttlUpdateSuccess:) showSpinner:showSpinner];    
//}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    noFilesMessage.text = @""; // TODO: remove this when file creation support is added
    
    currentFolderNavigation = [[NSMutableArray alloc] initWithCapacity:10];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self loadFiles];
	[[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(orientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		// 704
		
		//self.noServersImage.frame = CGRectMake(102, 134, 500, 500);
	} else { // UIInterfaceOrientationLandscapeLeft || UIInterfaceOrientationLandscapeRight	
		self.noFilesImage.frame = CGRectMake(102, 37, 500, 500);
		self.noFilesTitle.frame = CGRectMake(301, 567, 102, 22);
		self.noFilesMessage.frame = CGRectMake(172, 623, 370, 21);
		
	}
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    showSpinner = (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
	self.detailItem = @"Container Details";
	self.navigationItem.title = @"Container Details";
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

#pragma mark -
#pragma mark Rotation Support

- (void)orientationDidChange:(NSNotification *)notification {
	// reload the table view to correct UILabel widths
	[NSTimer scheduledTimerWithTimeInterval:0.25 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:NO];	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	
    // spinner acts weird, so don't show it in landscape
    showSpinner = (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    
	if (fromInterfaceOrientation == UIInterfaceOrientationPortrait || fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.noFilesImage.frame = CGRectMake(102, 37, 500, 500);
		self.noFilesTitle.frame = CGRectMake(301, 567, 102, 22);
		self.noFilesMessage.frame = CGRectMake(172, 623, 370, 21);        
	} else { // UIInterfaceOrientationLandscapeLeft || UIInterfaceOrientationLandscapeRight	
		self.noFilesImage.frame = CGRectMake(134, 180, 500, 500);
		self.noFilesTitle.frame = CGRectMake(333, 710, 102, 22);
		self.noFilesMessage.frame = CGRectMake(204, 766, 370, 21);
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (container) {
        if (rootFolder) {
            if ([rootFolder.folders count] > 0) {
                
                //ASICloudFilesFolder *lastFolder = [currentFolderNavigation lastObject];
                //if ([lastFolder.folders count] > 0) {
                    return 3 + [currentFolderNavigation count];
                //} else {
                //    return 3 + [currentFolderNavigation count] - 1;
                //}
                
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
        if (self.container.cdnEnabled) {
            return 3;
        } else {
            return 1;
        }
	} else {
		if (rootFolder != nil) {
		    
            NSInteger offsetSection = section - 2;
		    
            //NSLog(@"[currentFolderNavigation count] = ", [currentFolderNavigation count]);
		    
            if ([rootFolder.folders count] > 0 && offsetSection < [currentFolderNavigation count]) {
                // it's a folder in the stack
                ASICloudFilesFolder *folder = [currentFolderNavigation objectAtIndex:offsetSection];
                //NSLog(@"number of rows: %i", [folder.folders count]);
                if ([folder.folders count] > 0) {
                    return [folder.folders count] + 1; // +1 for "/"
                } else {
                    return [folder.folders count];
                }
            } else {
                // it's the files in the current folder
                ASICloudFilesFolder *folder = [currentFolderNavigation lastObject];
                return [folder.files count];
            }
		    
            // if (section == 2) {
            //     if ([rootFolder.folders count] > 0) {
            //                     return [rootFolder.folders count];
            //              } else if ([rootFolder.files count] > 0) {
            //                     return [rootFolder.files count];
            //                 } else {
            //                     return 0;
            //                 }
            // } else if (section == 3) {
            //     return [rootFolder.files count];
            // } else {
            //                 return 0;
            // }
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
            if ([rootFolder.folders count] > 0 || [rootFolder.files count] > 0 ) {
                return @"Files";
            } else {
                return @"";
            }
//            if ([rootFolder.folders count] > 0) {
//                return @"Folders";
//            } else if ([rootFolder.files count] > 0) {
//                return @"Files";
//            } else {
//                return 0;
//            }
	    } else {
//	        if ([rootFolder.files count] > 0) {
//                return @"Files";
//            } else {
                return @"";
//            }
	    }
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

- (float)ttlToPercentage {
    return self.container.ttl / 259200.0;
}

- (NSInteger)ttlFromPercentage:(float)percentage {
    return percentage * 259200;
}

- (NSString *)ttlToHours {
    NSString *result = [NSString stringWithFormat:@"%.0f hours", self.container.ttl / 3600.0];
    if ([result isEqualToString:@"1 hours"]) {
        result = @"1 hour";
    }
    return result;
}

- (UITableViewCell *)sliderCell:(UITableView *)aTableView label:(NSString *)label action:(SEL)action value:(BOOL)value {
	SliderCell *cell = (SliderCell *)[aTableView dequeueReusableCellWithIdentifier:label];
	
	if (cell == nil) {
		//cell = [[SliderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:label delegate:self action:action value:value];
        cell = [[SliderCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:label];
	}
    
    // handle orientation placement issues
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        CGRect rect = CGRectMake(310.0, 9.0, 330.0, 27.0);
        cell.slider.frame = rect;
    } else {
        CGRect rect = CGRectMake(247.0, 9.0, 330.0, 27.0);
        cell.slider.frame = rect;
    }
    

    [cell.slider addTarget:self action:@selector(ttlSliderMoved:) forControlEvents:UIControlEventValueChanged];
    [cell.slider addTarget:self action:@selector(ttlSliderFinished:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.slider.value = [self ttlToPercentage];
    ttlSlider = cell.slider;
    
	cell.textLabel.text = label;
    cell.detailTextLabel.text = [self ttlToHours]; // [NSString stringWithFormat:@"%d", container.ttl];
	
    ttlLabel = cell.detailTextLabel;
    
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
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else if (indexPath.row == 2) {
            return [self sliderCell:aTableView label:@"TTL" action:nil value:YES];
        // TODO: bring back log switch
//		} else {
//			return [self switchCell:aTableView label:@"CDN Logging Enabled" action:@selector(logSwitchChanged:) value:container.logRetention];			
		}
		
		
	} else if (indexPath.section >= 2) {
		// either files or folders
        cell.accessoryType = UITableViewCellAccessoryNone;

        NSInteger offsetSection = indexPath.section - 2;
	    
	    
        if ([rootFolder.folders count] > 0 && offsetSection < [currentFolderNavigation count]) {
            // it's a folder in the stack
            ASICloudFilesFolder *folder = [currentFolderNavigation objectAtIndex:offsetSection]; 
            
            if (indexPath.row > 0) {
                ASICloudFilesFolder *currentFolder = [folder.folders objectAtIndex:indexPath.row - 1];
        		//cell.textLabel.text = currentFolder.name;
                cell.textLabel.text = [NSString stringWithFormat:@"%@/%@", folder.name, currentFolder.name];
        	    // TODO: include humanized size in folder object and detailText here
                if ([currentFolder.files count] == 1) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i file", [currentFolder.files count]];
                } else {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i files", [currentFolder.files count]];
                }
                
                if ([currentFolderNavigation count] > offsetSection + 1) {
                    ASICloudFilesFolder *nextFolder = [currentFolderNavigation objectAtIndex:offsetSection + 1];
                    if ([currentFolder.name isEqualToString:nextFolder.name]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                }
                
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"%@/", folder.name];
        	    // TODO: include humanized size in folder object and detailText here
                if ([folder.files count] == 1) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i file", [folder.files count]];
                } else {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i files", [folder.files count]];
                }
                
                if ([currentFolderNavigation count] == offsetSection + 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
            }
            
        } else {
            // it's the files in the current folder
            ASICloudFilesFolder *folder = [currentFolderNavigation lastObject];
    		ASICloudFilesObject *file = [folder.files objectAtIndex:indexPath.row];
    		cell.textLabel.text = file.name;
    		cell.detailTextLabel.text = file.contentType;
            // TODO: restore when you have a device
            //if ([MFMailComposeViewController canSendMail]) {
            //    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //} else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            //}
        }		
	}
    
    return cell;
}

#pragma mark -
#pragma mark Action Sheet Delegate

- (void)emailLinkToFile {
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;		
    [vc setSubject:selectedFile.name];
    
    NSString *name = [NSString stringWithFormat:@"%@%@", [self currentPath], selectedFile.name];
    
    NSString *emailBody = [NSString stringWithFormat:@"%@/%@", self.container.cdnURL, [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [vc setMessageBody:emailBody isHTML:NO];

    vc.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

- (void)downloadFileToAttachSuccess:(ASICloudFilesObjectRequest *)request {
    [self hideSpinnerView];
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;
    [vc setSubject:selectedFile.name];
    
    //NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.container.cdnURL, [self.file.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSURL *url = [NSURL URLWithString:urlString];
    //NSData *attachmentData = [NSData dataWithContentsOfURL:url];
    
    ASICloudFilesObject *object = [request object];
    
    [vc addAttachmentData:object.data mimeType:selectedFile.contentType fileName:selectedFile.name];
    
    // Fill out the email body text
    NSString *emailBody = @"";
    [vc setMessageBody:emailBody isHTML:NO];
    
    vc.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentModalViewController:vc animated:YES];
    [vc release];    
}

- (void)emailFileAsAttachment {
    NSString *name = [NSString stringWithFormat:@"%@%@", [self currentPath], selectedFile.name];
    ASICloudFilesObjectRequest *request = [ASICloudFilesObjectRequest getObjectRequestWithContainer:self.container.name objectPath:[name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self request:request behavior:@"attaching your file" success:@selector(downloadFileToAttachSuccess:) showSpinner:showSpinner];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex >= 0) { // -1 means they tapped outside of the action sheet
        if (self.container.cdnEnabled) {
            if (buttonIndex == 0) {
                [self emailLinkToFile];
            } else {
                [self emailFileAsAttachment];
            }
        } else {
            [self emailFileAsAttachment];
        }
    }
}

#pragma mark -
#pragma mark Table view delegate

- (NSString *)currentPath {
    NSString *path = @"";
    int i = 0;
//    int i = 1;
//    if (self.container.cdnURL != nil) {
//        path = [path stringByAppendingString:[NSString stringWithFormat:@"%@", self.container.cdnURL]];
//        i = 0;
//    }
    for (; i < [currentFolderNavigation count]; i++) {
        ASICloudFilesFolder *folder = [currentFolderNavigation objectAtIndex:i];
        if (i == 0) {
            path = [path stringByAppendingString:folder.name];
        } else {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"%@/", folder.name]];
        }
    }
    return path;
}


- (void)didSelectFile:(ASICloudFilesObject *)file {
    //[self alert:@"File!" message:[NSString stringWithFormat:@"%@%@", [self currentPath], file.name]];
    selectedFile = file;
    UIActionSheet *as;
    NSString *title = file.name;    
    if (self.container.cdnEnabled) {
        as = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Email Link to File", @"Attach to Email", nil];				
    } else {
        as = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Attach to Email", nil];				
    }
    as.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [as showInView:self.view];
    
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	self.detailItem = @"Container Details";
	self.navigationItem.title = @"Container Details";
    
    // if the section is >= 2 and not the last section it's a folder.
    // either push it on the stack, or position the stack to that folder and reload
    
    
    // if it's the last section, it's a file, so show a modal dialog or action sheet
    
 	if (indexPath.section >= 2) {
        // either files or folders
        NSInteger offsetSection = indexPath.section - 2;

        if ([self numberOfSectionsInTableView:aTableView] == 3) {
            // it's a file!
            // TODO: restore when you have a device
            /*
            if ([MFMailComposeViewController canSendMail]) {
                ASICloudFilesFolder *fileFolder = [currentFolderNavigation objectAtIndex:offsetSection];
                ASICloudFilesObject *file = [fileFolder.files objectAtIndex:indexPath.row];
                [self didSelectFile:file];
            }
             */
        } else {            
            
            if (offsetSection < [currentFolderNavigation count]) {
                // it's a folder in the stack
                if (indexPath.row > 0) {
                    // it's a subfolder

                    ASICloudFilesFolder *folder = [currentFolderNavigation objectAtIndex:offsetSection];
                    
                    if ([folder.folders count] > 0) {
                    
                        ASICloudFilesFolder *currentFolder = [folder.folders objectAtIndex:indexPath.row - 1];
                        
                        if ([currentFolderNavigation count] == (offsetSection - 1)) {
                            // we're at the deepest folder, so push on the stack
                            //NSLog(@"adding to currentFolderNavigation");
                            [currentFolderNavigation addObject:currentFolder];
                            //NSLog(@"currentFolderNavigation now has %i items", [currentFolderNavigation count]);
                            [aTableView reloadData];
                            
                            // TODO: this is how to animate it
                            //NSIndexSet *sections = [NSIndexSet indexSetWithIndex:3];
                            //NSIndexSet *sections = [NSindexSet indexSetWithIndexesInRange:NSMakeRange(0, count)];                    
                            //[aTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationTop];
                            
                        } else {
                            // we need to adjust the stack since we're going up the tree                    
                            while (offsetSection < ([currentFolderNavigation count] - 1)) {
                                //NSLog(@"remove from folder nav");
                                [currentFolderNavigation removeLastObject];
                            }
                            //NSLog(@"adding to currentFolderNavigation");
                            [currentFolderNavigation addObject:currentFolder];
                            //NSLog(@"currentFolderNavigation now has %i items", [currentFolderNavigation count]);
                            [aTableView reloadData];
                        }
                    } else {
                        // it's a file!
                        // TODO: restore when you have a device
                        /*
                        if ([MFMailComposeViewController canSendMail]) {
                            ASICloudFilesFolder *fileFolder = [currentFolderNavigation objectAtIndex:offsetSection];
                            ASICloudFilesObject *file = [fileFolder.files objectAtIndex:indexPath.row];
                            [self didSelectFile:file];
                        }
                         */
                    }
                } else {
                    while (offsetSection < ([currentFolderNavigation count] - 1)) {
                        //NSLog(@"remove from folder nav");
                        [currentFolderNavigation removeLastObject];
                    }
                    //NSLog(@"currentFolderNavigation now has %i items", [currentFolderNavigation count]);
                    [aTableView reloadData];
                    // it's the root of the current folder in the section
                    // ASICloudFilesFolder *folder = [currentFolderNavigation objectAtIndex:offsetSection];            
                    // cell.textLabel.text = @"/";
                    // // TODO: include humanized size in folder object and detailText here
                    // cell.detailTextLabel.text = [NSString stringWithFormat:@"%i files", [folder.files count]];
                }
            } else {
                // it's a file!
                if ([MFMailComposeViewController canSendMail]) {
                    ASICloudFilesFolder *fileFolder = [currentFolderNavigation objectAtIndex:offsetSection - 1];
                    ASICloudFilesObject *file = [fileFolder.files objectAtIndex:indexPath.row];
                    [self didSelectFile:file];
                }
            }
        }
	}
}

#pragma mark -
#pragma mark Slider Handler

// - (void)setValue:(float)value animated:(BOOL)animated

- (void)ttlSliderFinished:(id)sender {
    ASICloudFilesCDNRequest *request = [ASICloudFilesCDNRequest postRequestWithContainer:self.container.name cdnEnabled:self.container.cdnEnabled ttl:self.container.ttl loggingEnabled:self.container.logRetention];
    [self request:request behavior:@"updating the TTL" success:@selector(ttlUpdateSuccess:) showSpinner:showSpinner];    
}

- (void)ttlSliderMoved:(id)sender {
	float newTTL = ttlSlider.value;
    self.container.ttl = [self ttlFromPercentage:newTTL];
    //[self.tableView reloadData];
    ttlLabel.text = [self ttlToHours];
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
    [rootFolder release];
    [noFilesView release];
    [noFilesImage release];
    [noFilesTitle release];
    [noFilesMessage release];
    [tableView release];
    [ttlSlider release];
    [currentFolderNavigation release];
    
    [super dealloc];
}


@end

