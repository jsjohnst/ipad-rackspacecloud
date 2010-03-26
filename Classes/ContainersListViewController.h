//
//  ContainersListViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/31/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContainerViewController;

@interface ContainersListViewController : UITableViewController {
	NSMutableArray *containers;
	NSMutableDictionary *containersDict; // for quick id-based lookup
    ContainerViewController *containerViewController;
}

@property (nonatomic, retain) ContainerViewController *containerViewController;

- (void)loadContainers;
- (void)loadContainers:(BOOL)showSpinner;

@end
