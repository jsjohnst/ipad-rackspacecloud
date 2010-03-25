//
//  ContainerViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RackspaceCloudSplitViewDelegate.h"

@class ASICloudFilesContainer, ASICloudFilesFolder;

@interface ContainerViewController : RackspaceCloudSplitViewDelegate <UITableViewDataSource, UITableViewDelegate> {

    // data
    ASICloudFilesContainer *container;
    ASICloudFilesFolder *rootFolder;
    
    // no files view
	IBOutlet UIView *noFilesView;
	IBOutlet UIImageView *noFilesImage;
	IBOutlet UILabel *noFilesTitle;
	IBOutlet UILabel *noFilesMessage;
    
    // ui elements
    IBOutlet UITableView *tableView;
    
    NSMutableArray *currentFolderNavigation;
}

// data
@property (nonatomic, retain) ASICloudFilesContainer *container;
@property (nonatomic, retain) ASICloudFilesFolder *rootFolder;

// no files view
@property (nonatomic, retain) IBOutlet UIView *noFilesView;
@property (nonatomic, retain) IBOutlet UIImageView *noFilesImage;
@property (nonatomic, retain) IBOutlet UILabel *noFilesTitle;
@property (nonatomic, retain) IBOutlet UILabel *noFilesMessage;

// ui elements
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)loadFiles;

@end
