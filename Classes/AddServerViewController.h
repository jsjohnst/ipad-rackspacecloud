//
//  AddServerViewController.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddServerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

}

-(void)cancelButtonPressed:(id)sender;
-(void)saveButtonPressed:(id)sender;

@end
