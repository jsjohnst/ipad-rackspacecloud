//
//  ASICloudServersServer.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/7/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ASICloudServersServer.h"


@implementation ASICloudServersServer

@synthesize serverId, name, imageId, flavorId, hostId, publicIpAddresses, privateIpAddresses, metadata, status, progress, adminPass, backupSchedule;

+ (id) server {
	ASICloudServersServer *server = [[[self alloc] init] autorelease];
	server.publicIpAddresses = [[NSMutableArray alloc] init];
	server.privateIpAddresses = [[NSMutableArray alloc] init];
	server.metadata = [[NSMutableDictionary alloc] init];
	return server;
}

- (NSString *)toXML {
	NSString *xml = @"";
	if (self.metadata && [self.metadata count] > 0) {
		NSString *metas = @"";
		NSArray *keys = [self.metadata allKeys];
		for (int i = 0; i < [keys count]; i++) {
			NSString *key = [keys objectAtIndex:i];
			metas = [NSString stringWithFormat:@"%@<meta key = \"%@\">%@</meta>", metas, key, [self.metadata objectForKey:key]];
		}
		NSString *meta = [NSString stringWithFormat:@"<metadata>%@</metadata>", metas];
		
		xml = [NSString stringWithFormat:@"<server xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" name=\"%@\" imageId=\"%i\" flavorId=\"%i\">%@</server>", self.name, self.imageId, self.flavorId, meta];	
	} else {
		xml = [NSString stringWithFormat:@"<server xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" name=\"%@\" imageId=\"%i\" flavorId=\"%i\"></server>", self.name, self.imageId, self.flavorId];	
	}
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
        theStatus = @"Building...";
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
	[backupSchedule release];
	[super dealloc];
}

@end
