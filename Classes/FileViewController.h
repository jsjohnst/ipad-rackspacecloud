//
//  FileViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASICloudFilesObject, ASICloudFilesContainer;

@interface FileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    ASICloudFilesContainer *container;
	ASICloudFilesObject *file;
	IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) ASICloudFilesContainer *container;
@property (nonatomic, retain) ASICloudFilesObject *file;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
