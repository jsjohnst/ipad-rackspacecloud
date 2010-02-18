//
//  SliderCell.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/17/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SliderCell.h"


@implementation SliderCell


@synthesize slider;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// place the text field where the text label belongs	
		CGRect rect = CGRectInset(self.contentView.bounds, 18, 12);
		rect.size.width += 220; // to account for ipad modal width
		//rect.origin.x += 75;
		//rect.size.width -= 75; // to prevent scrolling off the side
		//rect.size.height
		//labelFont
		
		
		self.slider = [[UISlider alloc] initWithFrame:rect];
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
