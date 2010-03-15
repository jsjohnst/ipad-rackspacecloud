//
//  FileViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASICloudFilesObject;

@interface FileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	ASICloudFilesObject *file;
	IBOutlet UITableView *tableView;
}

@property (nonatomic, retain) ASICloudFilesObject *file;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
