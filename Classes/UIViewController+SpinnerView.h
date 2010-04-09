//
//  UIViewController+SpinnerView.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/10/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpinnerViewController;

@interface UIViewController (SpinnerView)

-(void)showSpinnerView:(NSString *)text;
-(void)showSpinnerView;
-(void)hideSpinnerView;

-(void)alert:(NSString *)title message:(NSString *)message;
-(void)alertForCloudServersResponseStatusCode:(NSUInteger)responseStatusCode behavior:(NSString *)behavior;

@end
