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
        CGRect rect = CGRectMake(247.0, 9.0, 330.0, 27.0);
		self.slider = [[UISlider alloc] initWithFrame:rect];
		self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.25];
        self.slider.backgroundColor = [UIColor clearColor];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
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
