//
//  RackspaceCloudSplitViewDelegate.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RackspaceCloudSplitViewDelegate : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    UIPopoverController *popoverController;
    UINavigationBar *navigationBar;
    id detailItem;
}

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) id detailItem;

@end
