//
//  UIViewController+RackspaceCloud.h
//
//  Created by Michael Mayo on 2/19/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASICloudFilesRequest;

@interface UIViewController (RackspaceCloud)

-(void)request:(ASICloudFilesRequest *)request behavior:(NSString *)behavior success:(SEL)success;
-(void)request:(ASICloudFilesRequest *)request behavior:(NSString *)behavior success:(SEL)success showSpinner:(BOOL)showSpinner;

@end
