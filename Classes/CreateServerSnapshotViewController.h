//
//  CreateServerSnapshotViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerDetailViewController;

@interface CreateServerSnapshotViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	ServerDetailViewController *serverDetailViewController;
}

@property (nonatomic, retain) ServerDetailViewController *serverDetailViewController;

-(void)cancelButtonPressed:(id)sender;

@end
