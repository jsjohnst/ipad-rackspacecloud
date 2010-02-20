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

-(NSUInteger)humanizedProgress {
	NSUInteger p = self.progress;
	
	if ([self.status isEqualToString:@"QUEUE_RESIZE"]) {
		p = p / 3;
	} else if ([self.status isEqualToString:@"PREP_RESIZE"]) {
		p = 33 + p / 3;
	} else if ([self.status isEqualToString:@"RESIZE"]) {
		p = 67 + p / 3;
	}
	
	return p;
}

-(NSString *)humanizedStatus {
    NSString *theStatus = self.status;
    
    // Servers with an ACTIVE status are available for use. Other possible values for the status attribute include: 
    // BUILD, REBUILD, SUSPENDED, QUEUE_RESIZE, PREP_RESIZE, RESIZE, VERIFY_RESIZE, PASSWORD, RESCUE, REBOOT, HARD_REBOOT, SHARE_IP, SHARE_IP_NO_CONFIG, DELETE_IP, and UNKNOWN
    if ([theStatus isEqualToString:@"ACTIVE"]) {
        theStatus = @"Active";
    } else if ([theStatus isEqualToString:@"BUILD"]) {
        theStatus = @"Building..."; //[NSString stringWithFormat:@"Building... (%i%%)", self.progress];
    } else if ([theStatus isEqualToString:@"REBUILD"]) {
		theStatus = @"Rebuilding...";
    } else if ([theStatus isEqualToString:@"SUSPENDED"]) {
        theStatus = @"Suspended";
    } else if ([theStatus isEqualToString:@"QUEUE_RESIZE"]) {
		theStatus = @"Resizing...";
    } else if ([theStatus isEqualToString:@"PREP_RESIZE"]) {
		theStatus = @"Resizing...";
    } else if ([theStatus isEqualToString:@"RESIZE"]) {
		theStatus = @"Resizing...";
    } else if ([theStatus isEqualToString:@"VERIFY_RESIZE"]) {
        theStatus = @"Resize Complete";
    } else if ([theStatus isEqualToString:@"PASSWORD"]) {
        theStatus = @"Changing Password";
    } else if ([theStatus isEqualToString:@"RESCUE"]) {
        theStatus = @"Rescue Mode";
    } else if ([theStatus isEqualToString:@"REBOOT"]) {
        theStatus = @"Rebooting...";
    } else if ([theStatus isEqualToString:@"HARD_REBOOT"]) {
        theStatus = @"Rebooting...";
    } else if ([theStatus isEqualToString:@"SHARE_IP"]) {
    } else if ([theStatus isEqualToString:@"SHARE_IP_NO_CONFIG"]) {
    } else if ([theStatus isEqualToString:@"DELETE_IP"]) {
    } else if ([theStatus isEqualToString:@"UNKNOWN"]) {
        theStatus = @"Unknown";
    }
    return theStatus;
}

-(BOOL)shouldBePolled {	
	return ([status isEqualToString:@"BUILD"] || [status isEqualToString:@"UNKNOWN"] || [status isEqualToString:@"RESIZE"] || [status isEqualToString:@"QUEUE_RESIZE"] || [status isEqualToString:@"PREP_RESIZE"] || [status isEqualToString:@"REBUILD"]);
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
