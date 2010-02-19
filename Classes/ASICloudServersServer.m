//
//  ASICloudServersServer.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/7/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ASICloudServersServer.h"


@implementation ASICloudServersServer

@synthesize serverId, name, imageId, flavorId, hostId, publicIpAddresses, privateIpAddresses, metadata, status, progress, adminPass;

+ (id) server {
	ASICloudServersServer *server = [[[self alloc] init] autorelease];
	server.publicIpAddresses = [[NSMutableArray alloc] init];
	server.privateIpAddresses = [[NSMutableArray alloc] init];
	server.metadata = [[NSMutableDictionary alloc] init];
	return server;
}

- (NSString *)toXML {
	/*
	 <server xmlns="http://docs.rackspacecloud.com/servers/api/v1.0"
	 name="new-server-test" imageId="2" flavorId="1">
	 <metadata>
	 <meta key="My Server Name">Apache1</meta>
	 </metadata>
	 <personality>
	 <file path="/etc/banner.txt">
	 ICAgICAgDQoiQSBjbG91ZCBkb2VzIG5vdCBrbm93IHdoeSBp
	 dCBtb3ZlcyBpbiBqdXN0IHN1Y2ggYSBkaXJlY3Rpb24gYW5k
	 IGF0IHN1Y2ggYSBzcGVlZC4uLkl0IGZlZWxzIGFuIGltcHVs
	 c2lvbi4uLnRoaXMgaXMgdGhlIHBsYWNlIHRvIGdvIG5vdy4g
	 QnV0IHRoZSBza3kga25vd3MgdGhlIHJlYXNvbnMgYW5kIHRo
	 ZSBwYXR0ZXJucyBiZWhpbmQgYWxsIGNsb3VkcywgYW5kIHlv
	 dSB3aWxsIGtub3csIHRvbywgd2hlbiB5b3UgbGlmdCB5b3Vy
	 c2VsZiBoaWdoIGVub3VnaCB0byBzZWUgYmV5b25kIGhvcml6
	 b25zLiINCg0KLVJpY2hhcmQgQmFjaA==
	 </file>
	 </personality>
	 </server>
	 */
	NSString *xml = [NSString stringWithFormat:@"<server xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" name=\"%@\" imageId=\"%i\" flavorId=\"%i\"></server>", self.name, self.imageId, self.flavorId];	
	return xml;
}

-(NSString *)humanizedStatus {
    NSString *status = self.status;
    
    // Servers with an ACTIVE status are available for use. Other possible values for the status attribute include: 
    // BUILD, REBUILD, SUSPENDED, QUEUE_RESIZE, PREP_RESIZE, RESIZE, VERIFY_RESIZE, PASSWORD, RESCUE, REBOOT, HARD_REBOOT, SHARE_IP, SHARE_IP_NO_CONFIG, DELETE_IP, and UNKNOWN
    if ([status isEqualToString:@"ACTIVE"]) {
        status = @"Active";
    } else if ([status isEqualToString:@"BUILD"]) {
        status = [NSString stringWithFormat:@"Building... (%i%%)", self.progress];
    } else if ([status isEqualToString:@"REBUILD"]) {
        status = [NSString stringWithFormat:@"Rebuilding... (%i%%)", self.progress];
    } else if ([status isEqualToString:@"SUSPENDED"]) {
        status = @"Suspended";
    } else if ([status isEqualToString:@"QUEUE_RESIZE"]) {
        //pv.progress = ([self.server.progress intValue] / 3.0 * 0.01);
        status = [NSString stringWithFormat:@"Resizing... (%i%%)", self.progress / 3];
    } else if ([status isEqualToString:@"PREP_RESIZE"]) {
        //pv.progress = 0.333 + (([self.server.progress intValue] / 3.0) * 0.01);
        status = [NSString stringWithFormat:@"Resizing... (%i%%)", 33 + (self.progress / 3)];
    } else if ([status isEqualToString:@"RESIZE"]) {
        //pv.progress = 0.667 + (([self.server.progress intValue] / 3.0) * 0.01);
        status = [NSString stringWithFormat:@"Resizing... (%i%%)", 67 + (self.progress / 3)];
    } else if ([status isEqualToString:@"VERIFY_RESIZE"]) {
        status = @"Resize Complete"
    } else if ([status isEqualToString:@"PASSWORD"]) {
        status = @"Changing Password";
    } else if ([status isEqualToString:@"RESCUE"]) {
        status = @"Rescue Mode";
    } else if ([status isEqualToString:@"REBOOT"]) {
        status = @"Rebooting...";
    } else if ([status isEqualToString:@"HARD_REBOOT"]) {
        status = @"Rebooting...";
    } else if ([status isEqualToString:@"SHARE_IP"]) {
    } else if ([status isEqualToString:@"SHARE_IP_NO_CONFIG"]) {
    } else if ([status isEqualToString:@"DELETE_IP"]) {
    } else if ([status isEqualToString:@"UNKNOWN"]) {
        status = @"Unknown";
    }
    return status;
}

-(void) dealloc {
	[name release];
	[hostId release];
	[publicIpAddresses release];
	[privateIpAddresses release];
	[metadata release];
	[status release];
	[adminPass release];
	[super dealloc];
}

@end
