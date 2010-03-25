//
//  RackspaceCloudSplitViewDelegate.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
#pragma mark Managing the popover controller

// When setting the detail item, update the view and dismiss the popover controller if it's showing.
- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
        
        // Update the view.
        navigationBar.topItem.title = [detailItem description];
    }
    
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Services";
    [navigationBar.topItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    [navigationBar.topItem setLeftBarButtonItem:nil animated:YES];
    self.popoverController = nil;
}

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    self.popoverController = nil;
}

- (void)dealloc {
    [popoverController release];
    [navigationBar release];
    [detailItem release];	
	[super dealloc];
}

@end
