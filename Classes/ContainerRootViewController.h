//
//  ContainerRootViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RackspaceCloudSplitViewDelegate.h"

@class ASICloudFilesContainer, ASICloudFilesFolder;

//@interface ContainerRootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIDocumentInteractionControllerDelegate> {
@interface ContainerRootViewController : RackspaceCloudSplitViewDelegate <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIDocumentInteractionControllerDelegate> {
    
    UINavigationController *navigationController;
    
    //UINavigationBar *navigationBar;
	ASICloudFilesContainer *container;
    ASICloudFilesFolder *rootFolder;
	IBOutlet UITableView *tableView;
	
	// TODO: try out DTGridView for files view
	// TODO: multiple account support
	// TODO: fix silver navbar rotate problem
	// TODO: fix fedora/arch logo mismatch
	
	IBOutlet UIView *noFilesView;
	IBOutlet UIImageView *noFilesImage;
	IBOutlet UILabel *noFilesTitle;
	IBOutlet UILabel *noFilesMessage;
	
    //id detailItem;
	//UIPopoverController *popoverController;
    
}

@property (nonatomic, retain) ASICloudFilesContainer *container;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
//@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, retain) IBOutlet UIView *noFilesView;
@property (nonatomic, retain) IBOutlet UIImageView *noFilesImage;
@property (nonatomic, retain) IBOutlet UILabel *noFilesTitle;
@property (nonatomic, retain) IBOutlet UILabel *noFilesMessage;

//@property (nonatomic, retain) UIPopoverController *popoverController;
//@property (nonatomic, retain) id detailItem;

@property (nonatomic, retain) UINavigationController *navigationController;

-(id)initWithNoContainersView;

@end
