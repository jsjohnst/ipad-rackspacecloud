//
//  ContainerViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RackspaceCloudSplitViewDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class ASICloudFilesContainer, ASICloudFilesFolder, ASICloudFilesObject;

@interface ContainerViewController : RackspaceCloudSplitViewDelegate <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {

    // data
    ASICloudFilesContainer *container;
    ASICloudFilesFolder *rootFolder;
    ASICloudFilesObject *selectedFile;
    
    // no files view
	IBOutlet UIView *noFilesView;
	IBOutlet UIImageView *noFilesImage;
	IBOutlet UILabel *noFilesTitle;
	IBOutlet UILabel *noFilesMessage;
    
    // ui elements
    IBOutlet UITableView *tableView;
    IBOutlet UISlider *ttlSlider;
    UILabel *ttlLabel;
    
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
@property (nonatomic, retain) IBOutlet UISlider *ttlSlider;

- (void)loadFiles;
- (void)ttlSliderMoved:(id)sender;
- (NSString *)currentPath;

@end
