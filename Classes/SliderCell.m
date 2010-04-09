//
//  SliderCell.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/17/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "SliderCell.h"


@implementation SliderCell


@synthesize slider;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// place the text field where the text label belongs	
		//CGRect rect = CGRectInset(self.contentView.bounds, 18, 12);
        CGRect rect = CGRectMake(247.0, 9.0, 330.0, 27.0);
		//rect.size.width += 220; // to account for ipad modal width
		
		//rect.size.width = self.contentView.frame.size.width + 50;
		
		
		//rect.origin.x += 75;
		//rect.size.width -= 75; // to prevent scrolling off the side
		//rect.size.height
		//labelFont
		
        
		
		self.slider = [[UISlider alloc] initWithFrame:rect];


		self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
        self.slider.backgroundColor = [UIColor clearColor];
		//self.backgroundColor = [UIColor clearColor];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
//		self.textField.returnKeyType = UIReturnKeyDone;
//		self.textField.adjustsFontSizeToFitWidth = NO;
//		self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
//		self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//		self.textField.font = [UIFont fontWithName:self.textField.font.fontName size:17.0];
		[self addSubview:self.slider];		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}


- (void)dealloc {
	[slider release];
    [super dealloc];
}


@end
