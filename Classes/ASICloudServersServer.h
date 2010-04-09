//
//  ASICloudServersServer.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/7/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASICloudServersBackupSchedule;

@interface ASICloudServersServer : NSObject {
	NSUInteger serverId;
	NSString *name;
	NSUInteger imageId;
	NSUInteger flavorId;
	NSString *hostId;
	NSMutableArray *publicIpAddresses;
	NSMutableArray *privateIpAddresses;
	NSMutableDictionary *metadata;
	NSString *status;
	NSUInteger progress;
	NSString *adminPass;
	ASICloudServersBackupSchedule *backupSchedule;
}

+(id)server;
-(NSString *)toXML;
-(NSUInteger)humanizedProgress;
-(NSString *)humanizedStatus;
-(BOOL)shouldBePolled;

@property (assign) NSUInteger serverId;
@property (retain) NSString *name;
@property (assign) NSUInteger imageId;
@property (assign) NSUInteger flavorId;
@property (retain) NSString *hostId;
@property (retain) NSMutableArray *publicIpAddresses;
@property (retain) NSMutableArray *privateIpAddresses;
@property (retain) NSMutableDictionary *metadata;
@property (retain) NSString *status;
@property (assign) NSUInteger progress;
@property (retain) NSString *adminPass;
@property (retain) ASICloudServersBackupSchedule *backupSchedule;

@end
