//
//  RackspaceCloudAppDelegate.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/27/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubstitutableDetailViewController.h"


@class MasterViewController;
@class DetailViewController;
@class AuthenticationViewController;

@interface RackspaceCloudAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    
    UISplitViewController *splitViewController;
    
    MasterViewController *masterViewController;
    //DetailViewController *detailViewController;
    UIViewController<SubstitutableDetailViewController> *detailViewController;
	AuthenticationViewController *authenticationViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic,retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic,retain) IBOutlet MasterViewController *masterViewController;
//@property (nonatomic,retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet UIViewController<SubstitutableDetailViewController> *detailViewController;

@property (nonatomic,retain) IBOutlet AuthenticationViewController *authenticationViewController;

- (NSString *)applicationDocumentsDirectory;

@end
