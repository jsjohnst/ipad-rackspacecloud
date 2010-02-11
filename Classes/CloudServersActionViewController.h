//
//  CloudServersActionViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/11/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerDetailViewController;

@interface CloudServersActionViewController : UIViewController {
	ServerDetailViewController *serverDetailViewController;
}

@property (nonatomic, retain) ServerDetailViewController *serverDetailViewController;

-(void)cancelButtonPressed:(id)sender;

@end
