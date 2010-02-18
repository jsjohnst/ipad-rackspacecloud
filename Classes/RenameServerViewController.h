//
//  RenameServerViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "CloudServersActionViewController.h"

@class ServerDetailViewController;

@interface RenameServerViewController : CloudServersActionViewController <UITableViewDelegate, UITableViewDataSource> {
	UITextField *textField;
}

-(void)saveButtonPressed:(id)sender;

@end
