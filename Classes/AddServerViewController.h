//
//  AddServerViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASICloudServersServer, ServerDetailViewController;

@interface AddServerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	UITextField *textField;
	UISlider *slider;
	ASICloudServersServer *server;
	ServerDetailViewController *serverDetailViewController;
}

@property (nonatomic, retain) ASICloudServersServer *server;
@property (nonatomic, retain) ServerDetailViewController *serverDetailViewController;

-(void)cancelButtonPressed:(id)sender;
-(void)saveButtonPressed:(id)sender;

@end
