//
//  SubstitutableDetailViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/25/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SubstitutableDetailViewController

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;
- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem;

@end
