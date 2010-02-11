//
//  TextFieldCell.h
//  Rackspace
//
//  Created by Michael Mayo on 9/26/09.
//  Copyright 2009 Rackspace Hosting. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextFieldCell : UITableViewCell {
	UITextField *textField;
}

@property (nonatomic, retain) UITextField *textField;

@end
