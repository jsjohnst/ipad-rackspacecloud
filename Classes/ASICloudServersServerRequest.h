//
//  ASICloudServersServerRequest.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/7/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ASICloudFilesRequest.h"

@class ASICloudServersServerXMLParserDelegate, ASICloudServersBackupScheduleXMLParserDelegate, ASICloudServersServer, ASICloudServersBackupSchedule;

@interface ASICloudServersServerRequest : ASICloudFilesRequest {
	ASICloudServersServerXMLParserDelegate *serverXMLParserDelegate;
	ASICloudServersBackupScheduleXMLParserDelegate *backupScheduleXMLParserDelegate;
}

@property (retain) ASICloudServersServerXMLParserDelegate *serverXMLParserDelegate;
@property (retain) ASICloudServersBackupScheduleXMLParserDelegate *backupScheduleXMLParserDelegate;

// TODO: use hostId to tell the user if any other servers are on the same host

// GET /servers
// Create a request to list servers
+ (id)listRequest;
- (NSArray *)servers;
// TODO: limit and offset request

// POST /servers
// Create a server
+ (id)createServerRequest:(ASICloudServersServer *)server;

// PUT /servers/id
// Update a server's name and/or root password
+ (id)updateServerNameRequest:(NSUInteger)serverId name:(NSString *)name;
+ (id)updateServerAdminPasswordRequest:(NSUInteger)serverId adminPass:(NSString *)adminPass;

// DELETE /servers/id
// Delete a server
+ (id)deleteServerRequest:(NSUInteger)serverId;

// TODO: share/unshare IP?

// POST /servers/id/action.xml
// Reboot, Rebuild, Resize, Confirm Resize, Revert Resize
+ (id)rebootServerRequest:(NSUInteger)serverId rebootType:(NSString *)rebootType;
// POST <rebuild xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" imageId="2"/>
+ (id)rebuildServerRequest:(NSUInteger)serverId imageId:(NSUInteger)imageId;
// POST <resize xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" flavorId="3"/>
+ (id)resizeServerRequest:(NSUInteger)serverId flavorId:(NSUInteger)flavorId;
// POST <confirmResize xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" />
+ (id)confirmResizeServerRequest:(NSUInteger)serverId;
// POST <revertResize xmlns="http://docs.rackspacecloud.com/servers/api/v1.0" />
+ (id)revertResizeServerRequest:(NSUInteger)serverId;


// GET /servers/id/backup_schedule
// List backup schedule
+ (id)listBackupScheduleRequest:(NSUInteger)serverId;
- (ASICloudServersBackupSchedule *)backupSchedule;

// POST /servers/id/backup_schedule
// Create or update backup schedule
+ (id)updateBackupScheduleRequest:(NSUInteger)serverId daily:(NSString *)daily weekly:(NSString *)weekly;

// DELETE /servers/id/backup_schedule
// Disable the backup schedule
+ (id)disableBackupScheduleRequest:(NSUInteger)serverId;
//<backupSchedule xmlns="http://docs.rackspacecloud.com/servers/api/v1.0" enabled="true" weekly="THURSDAY" daily="H_0400_0600" />
// DISABLED for disabled :P

@end
