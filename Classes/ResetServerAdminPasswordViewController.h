//
//  ResetServerAdminPasswordViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerDetailViewController;

@interface ResetServerAdminPasswordViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	ServerDetailViewController *serverDetailViewController;
	UITextField *textField;
}

@property (nonatomic, retain) ServerDetailViewController *serverDetailViewController;

-(void)cancelButtonPressed:(id)sender;
-(void)saveButtonPressed:(id)sender;
	
@end
