//
//  CloudServersActionViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/11/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerDetailViewController;

@interface CloudServersActionViewController : UIViewController {
	ServerDetailViewController *serverDetailViewController;
}

@property (nonatomic, retain) ServerDetailViewController *serverDetailViewController;

-(void)cancelButtonPressed:(id)sender;

@end
