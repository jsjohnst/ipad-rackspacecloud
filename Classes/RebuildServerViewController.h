//
//  RebuildServerViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerDetailViewController;

@interface RebuildServerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	ServerDetailViewController *serverDetailViewController;
	NSUInteger selectedImageId;
}

@property (nonatomic, retain) ServerDetailViewController *serverDetailViewController;

-(void)cancelButtonPressed:(id)sender;
-(void)saveButtonPressed:(id)sender;

@end
