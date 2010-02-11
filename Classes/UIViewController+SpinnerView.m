//
//  UIViewController+SpinnerView.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "UIViewController+SpinnerView.h"
#import "SpinnerViewController.h"


@implementation UIViewController (SpinnerView)

-(void) showSpinnerView:(NSString *)text {
	SpinnerViewController *vc = [[SpinnerViewController alloc] initWithNibName:@"SpinnerViewController" bundle:nil];
	vc.view.center = self.view.center;
	vc.label.text = text;
	[self.view addSubview:vc.view];	
	[vc release];
}

-(void) showSpinnerView {
	[self showSpinnerView:@"Saving..."];
}

// actually removes all spinner views, but you shouldn't use more than one at a time anyway
-(void) hideSpinnerView {
	NSArray *subviews = self.view.subviews;
	for (int i = 0; i < [subviews count]; i++) {
		id subview = [subviews objectAtIndex:i];
		if ([subview class] == NSClassFromString(@"SpinnerViewController")) {
			[((UIView *)subview) removeFromSuperview];
		}
	}
}

@end
