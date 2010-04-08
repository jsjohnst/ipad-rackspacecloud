//
//  AccountViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 4/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@interface AccountViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UINavigationItem *navigationItem;
    SettingsViewController *settingsViewController;
    BOOL primaryAccount;
    NSString *originalUsername;
	UITextField *usernameTextField;
	UITextField *apiKeyTextField;
}

@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) SettingsViewController *settingsViewController;
@property (nonatomic) BOOL primaryAccount;
@property (nonatomic, retain) NSString *originalUsername;

-(void)cancelButtonPressed:(id)sender;
-(void)saveButtonPressed:(id)sender;

@end
