//
//  RackspaceCloudSplitViewDelegate.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/24/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "RackspaceCloudSplitViewDelegate.h"


@implementation RackspaceCloudSplitViewDelegate

@synthesize navigationBar, popoverController, detailItem;

#pragma mark -
#pragma mark Defined in SubstitutableDetailViewController protocol

- (void)showRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem 
{
    [navigationBar.topItem setLeftBarButtonItem:barButtonItem animated:NO];
}

- (void)invalidateRootPopoverButtonItem:(UIBarButtonItem *)barButtonItem
{
	[navigationBar.topItem setLeftBarButtonItem:nil animated:NO];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [popoverController release];
    [navigationBar release];
    [detailItem release];	
	[super dealloc];
}

@end
