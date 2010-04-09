//
//  LogoutViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LogoutViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSUserDefaults *defaults;
    NSUInteger accountCount;
    NSMutableArray *accounts;
    NSUInteger selectedIndex;
	NSUInteger imageLoadAttempts;
	NSUInteger flavorLoadAttempts;

    NSString *initialUsername;
    NSString *initialApiKey;
    NSArray *initialFlavors;
    NSArray *initialImages;
    NSString *initialStorageURL;
    NSString *initialCdnManagementURL;
    NSString *initialServerManagementURL;
}

-(void)cancelButtonPressed:(id)sender;
-(void)loginButtonPressed:(id)sender;

@end
