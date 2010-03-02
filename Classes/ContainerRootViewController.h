//
//  ContainerRootViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASICloudFilesContainer;

@interface ContainerRootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISplitViewControllerDelegate, UIDocumentInteractionControllerDelegate> {
	ASICloudFilesContainer *container;
	NSArray *files;
	IBOutlet UITableView *tableView;
	
	// TODO: try out DTGridView for files view
}

@property (nonatomic, retain) ASICloudFilesContainer *container;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
