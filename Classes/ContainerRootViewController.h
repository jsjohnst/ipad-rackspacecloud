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
    UINavigationBar *navigationBar;
	ASICloudFilesContainer *container;
	NSArray *files;
	IBOutlet UITableView *tableView;
	
	// TODO: try out DTGridView for files view
	// TODO: multiple account support
	// TODO: fix silver navbar rotate problem
	// TODO: fix fedora/arch logo mismatch
	
	IBOutlet UIView *noFilesView;
	IBOutlet UIImageView *noFilesImage;
	IBOutlet UILabel *noFilesTitle;
	IBOutlet UILabel *noFilesMessage;
	
}

@property (nonatomic, retain) ASICloudFilesContainer *container;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UINavigationBar *navigationBar;

@property (nonatomic, retain) IBOutlet UIView *noFilesView;
@property (nonatomic, retain) IBOutlet UIImageView *noFilesImage;
@property (nonatomic, retain) IBOutlet UILabel *noFilesTitle;
@property (nonatomic, retain) IBOutlet UILabel *noFilesMessage;

-(id)initWithNoContainersView;

@end
