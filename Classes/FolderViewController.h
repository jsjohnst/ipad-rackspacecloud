//
//  FolderViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASICloudFilesFolder;

@interface FolderViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	ASICloudFilesFolder *folder;
	IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) ASICloudFilesFolder *folder;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
