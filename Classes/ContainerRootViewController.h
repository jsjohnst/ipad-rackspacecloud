//
//  ContainerRootViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASICloudFilesContainer;

@interface ContainerRootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISplitViewControllerDelegate> {
	ASICloudFilesContainer *container;
}

@property (nonatomic, retain) ASICloudFilesContainer *container;

@end
