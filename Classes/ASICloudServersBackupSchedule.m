//
//  ASICloudServersBackupSchedule.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/12/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ASICloudServersBackupSchedule.h"


@implementation ASICloudServersBackupSchedule

@synthesize enabled, weekly, daily;

+ (id)backupSchedule {
	ASICloudServersBackupSchedule *backupSchedule = [[[self alloc] init] autorelease];
	backupSchedule.enabled = NO;
	return backupSchedule;
}

- (NSString *)toXML {
	NSString *xml = [NSString stringWithFormat:@"<backupSchedule xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" enabled=\"true\" weekly=\"%@\" daily=\"%@\" />", self.weekly, self.daily];	
	return xml;
}

-(void) dealloc {
	[weekly release];
	[daily release];
	[super dealloc];
}

@end
