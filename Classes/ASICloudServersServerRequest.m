//
//  ASICloudServersServerRequest.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/7/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ASICloudServersServerRequest.h"
#import "ASICloudServersServer.h"
#import "ASICloudServersServerXMLParserDelegate.h"
#import "ASICloudServersBackupSchedule.h"
#import "ASICloudServersBackupScheduleXMLParserDelegate.h"


@implementation ASICloudServersServerRequest

@synthesize serverXMLParserDelegate, backupScheduleXMLParserDelegate;

#pragma mark -
#pragma mark Constructors

+ (id)serverRequestWithMethod:(NSString *)method path:(NSString *)path {
	NSString *urlString = [NSString stringWithFormat:@"%@%@", [ASICloudFilesRequest serverManagementURL], path];
	
	ASICloudServersServerRequest *request = [[[ASICloudServersServerRequest alloc] initWithURL:[NSURL URLWithString:urlString]] autorelease];
	[request setRequestMethod:method];
	[request addRequestHeader:@"X-Auth-Token" value:[ASICloudFilesRequest authToken]];
	[request addRequestHeader:@"Content-Type" value:@"application/xml"];
	return request;
}

#pragma mark -
#pragma mark GET - Server List

+ (id)listRequest {
	NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *urlString = [NSString stringWithFormat:@"%@/servers/detail.xml?now=%@", [ASICloudFilesRequest serverManagementURL], now];
	ASICloudServersServerRequest *request = [[[ASICloudServersServerRequest alloc] initWithURL:[NSURL URLWithString:urlString]] autorelease];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"X-Auth-Token" value:[ASICloudFilesRequest authToken]];
	return request;
}

- (NSArray *)servers {
	if (serverXMLParserDelegate.serverObjects) {
		return serverXMLParserDelegate.serverObjects;
	}
	
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:[self responseData]] autorelease];
	if (serverXMLParserDelegate == nil) {
		serverXMLParserDelegate = [[ASICloudServersServerXMLParserDelegate alloc] init];
	}
	
	// TODO: if multiple servers have metadata, there's a bad access problem
	
	[parser setDelegate:serverXMLParserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	
	return serverXMLParserDelegate.serverObjects;
}

#pragma mark -
#pragma mark GET - Server Details

+ (id)getServerRequest:(NSUInteger)serverId {
	NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *urlString = [NSString stringWithFormat:@"%@/servers/%i.xml?now=%@", [ASICloudFilesRequest serverManagementURL], serverId, now];
	ASICloudServersServerRequest *request = [[[ASICloudServersServerRequest alloc] initWithURL:[NSURL URLWithString:urlString]] autorelease];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"X-Auth-Token" value:[ASICloudFilesRequest authToken]];
	return request;    
}

- (ASICloudServersServer *)server {
    return [[self servers] objectAtIndex:0];
}


#pragma mark -
#pragma mark POST - Create Server

+ (id)createServerRequest:(ASICloudServersServer *)server {
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest serverRequestWithMethod:@"POST" path:@"/servers"];
	NSData* data = [[server toXML] dataUsingEncoding:NSASCIIStringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

#pragma mark -
#pragma mark PUT - Update Server Name or Password

+ (id)updateServerNameRequest:(NSUInteger)serverId name:(NSString *)name {
	NSString *body = [NSString stringWithFormat:@"<server xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" name=\"%@\" />", name];
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest serverRequestWithMethod:@"PUT" path:[NSString stringWithFormat:@"/servers/%i.xml", serverId]];
	NSData *data = [body dataUsingEncoding:NSASCIIStringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

+ (id)updateServerAdminPasswordRequest:(NSUInteger)serverId adminPass:(NSString *)adminPass {
	NSString *body = [NSString stringWithFormat:@"<server xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" adminPass=\"%@\" />", adminPass];
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest serverRequestWithMethod:@"PUT" path:[NSString stringWithFormat:@"/servers/%i.xml", serverId]];
	NSData *data = [body dataUsingEncoding:NSASCIIStringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

#pragma mark -
#pragma mark DELETE - Delete Server

+ (id)deleteServerRequest:(NSUInteger)serverId {
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest serverRequestWithMethod:@"DELETE" path:[NSString stringWithFormat:@"/servers/%i.xml", serverId]];
	return request;
}

#pragma mark -
#pragma mark PUT - Server Actions

+ (id)rebootServerRequest:(NSUInteger)serverId rebootType:(NSString *)rebootType {
	NSString *body = [NSString stringWithFormat:@"<reboot xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" type=\"%@\"/>", rebootType];
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest serverRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"/servers/%i/action.xml", serverId]];
	NSData *data = [body dataUsingEncoding:NSASCIIStringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

// POST <rebuild xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" imageId="2"/>
+ (id)rebuildServerRequest:(NSUInteger)serverId imageId:(NSUInteger)imageId {
	NSString *body = [NSString stringWithFormat:@"<rebuild xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" imageId=\"%u\"/>", imageId];
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest serverRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"/servers/%i/action.xml", serverId]];
	NSData *data = [body dataUsingEncoding:NSASCIIStringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

// POST <resize xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" flavorId="3"/>
+ (id)resizeServerRequest:(NSUInteger)serverId flavorId:(NSUInteger)flavorId {
	NSString *body = [NSString stringWithFormat:@"<resize xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" flavorId=\"%u\"/>", flavorId];
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest serverRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"/servers/%i/action.xml", serverId]];
	NSData *data = [body dataUsingEncoding:NSASCIIStringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

// POST <confirmResize xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" />
+ (id)confirmResizeServerRequest:(NSUInteger)serverId {
	NSString *body = @"<confirmResize xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" />";
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest serverRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"/servers/%i/action.xml", serverId]];
	NSData *data = [body dataUsingEncoding:NSASCIIStringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

// POST <revertResize xmlns="http://docs.rackspacecloud.com/servers/api/v1.0" />
+ (id)revertResizeServerRequest:(NSUInteger)serverId {
	NSString *body = @"<revertResize xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" />";
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest serverRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"/servers/%i/action.xml", serverId]];
	NSData *data = [body dataUsingEncoding:NSASCIIStringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

// GET /servers/id/backup_schedule
// List backup schedule
+ (id)listBackupScheduleRequest:(NSUInteger)serverId {
	NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *urlString = [NSString stringWithFormat:@"%@/servers/%u/backup_schedule.xml?now=%@", [ASICloudFilesRequest serverManagementURL], serverId, now];
	ASICloudServersServerRequest *request = [[[ASICloudServersServerRequest alloc] initWithURL:[NSURL URLWithString:urlString]] autorelease];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"X-Auth-Token" value:[ASICloudFilesRequest authToken]];
	return request;
	
	// response:
	// <backupSchedule xmlns="http://docs.rackspacecloud.com/servers/api/v1.0" enabled="true" weekly="THURSDAY" daily="H_0400_0600" />
}

- (ASICloudServersBackupSchedule *)backupSchedule {
	if (backupScheduleXMLParserDelegate.currentObject) {
		return backupScheduleXMLParserDelegate.currentObject;
	}
	
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:[self responseData]] autorelease];
	if (backupScheduleXMLParserDelegate == nil) {
		backupScheduleXMLParserDelegate = [[ASICloudServersBackupScheduleXMLParserDelegate alloc] init];
	}
	
	[parser setDelegate:backupScheduleXMLParserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	
	return backupScheduleXMLParserDelegate.currentObject;
}


// POST /servers/id/backup_schedule
// Create or update backup schedule
+ (id)updateBackupScheduleRequest:(NSUInteger)serverId daily:(NSString *)daily weekly:(NSString *)weekly {
	NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *urlString = [NSString stringWithFormat:@"%@/servers/%u/backup_schedule.xml?now=%@", [ASICloudFilesRequest serverManagementURL], serverId, now];
	ASICloudServersServerRequest *request = [[[ASICloudServersServerRequest alloc] initWithURL:[NSURL URLWithString:urlString]] autorelease];
	[request setRequestMethod:@"POST"];
	[request addRequestHeader:@"X-Auth-Token" value:[ASICloudFilesRequest authToken]];
	[request addRequestHeader:@"Content-Type" value:@"application/xml"];
	
	ASICloudServersBackupSchedule *schedule = [ASICloudServersBackupSchedule backupSchedule];
	schedule.daily = daily;
	schedule.weekly = weekly;

	NSData* data = [[schedule toXML] dataUsingEncoding:NSASCIIStringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}

// DELETE /servers/id/backup_schedule
// Disable the backup schedule
+ (id)disableBackupScheduleRequest:(NSUInteger)serverId {
	return nil;
}
//<backupSchedule xmlns="http://docs.rackspacecloud.com/servers/api/v1.0" enabled="true" weekly="THURSDAY" daily="H_0400_0600" />
// DISABLED for disabled :P

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[serverXMLParserDelegate release];
	[backupScheduleXMLParserDelegate release];
	[super dealloc];
}

@end
