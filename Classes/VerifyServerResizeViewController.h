//
//  VerifyServerResizeViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/21/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerDetailViewController;

@interface VerifyServerResizeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	ServerDetailViewController *serverDetailViewController;
}

@property (nonatomic, retain) ServerDetailViewController *serverDetailViewController;

-(void)cancelButtonPressed:(id)sender;

@end
