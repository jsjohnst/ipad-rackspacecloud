//
//  ASICloudServersImage.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/7/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ASICloudServersImage : NSObject {
	NSString *status;
	NSDate *updated;
	NSString *name;
	NSUInteger imageId;
}

@property (retain) NSString *status;
@property (retain) NSDate *updated;
@property (retain) NSString *name;
@property (assign) NSUInteger imageId;

+(id)image;

+(UIImage *)iconForImageId:(NSUInteger)imageId;
+(UIImage *)logoForImageId:(NSUInteger)imageId;
+(UIImage *)backgroundForImageId:(NSUInteger)imageId;

@end
