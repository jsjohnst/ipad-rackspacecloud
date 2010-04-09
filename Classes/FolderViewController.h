//
//  FolderViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/11/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASICloudFilesContainer, ASICloudFilesFolder;

@interface FolderViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    ASICloudFilesContainer *container;
	ASICloudFilesFolder *folder;
	IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) ASICloudFilesContainer *container;
@property (nonatomic, retain) ASICloudFilesFolder *folder;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
