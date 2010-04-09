//
//  ASICloudServersFlavor.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/7/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


// <flavor disk="10" ram="256" name="256 server" id="1"/>

@interface ASICloudServersFlavor : NSObject {
	NSUInteger disk;
	NSUInteger ram;
	NSString *name;
	NSUInteger flavorId;
}

@property (assign) NSUInteger disk;
@property (assign) NSUInteger ram;
@property (retain) NSString *name;
@property (assign) NSUInteger flavorId;

+ (id)flavor;

@end
