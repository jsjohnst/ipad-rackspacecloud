//
//  ASICloudFilesFolder.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/10/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ASICloudFilesFolder : NSObject {
	NSString *name;
	ASICloudFilesFolder *parent;
	NSMutableArray *folders;
	NSMutableArray *files;
}

@property (retain) NSString *name;
@property (retain) ASICloudFilesFolder *parent;
@property (retain) NSMutableArray *folders;
@property (retain) NSMutableArray *files;

+ (id)folder;

@end
