//
//  ASICloudServersBackupSchedule.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
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
	NSString *xml = [NSString stringWithFormat:@"<backupSchedule xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" enabled=\"%b\" weekly=\"%@\" daily=\"%@\" />", self.enabled, self.weekly, self.daily];	
	return xml;
}

-(void) dealloc {
	[weekly release];
	[daily release];
	[super dealloc];
}

@end
