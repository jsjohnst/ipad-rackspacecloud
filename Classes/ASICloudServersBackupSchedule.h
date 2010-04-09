//
//  ASICloudServersBackupSchedule.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/12/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ASICloudServersBackupSchedule : NSObject {
	//<backupSchedule xmlns="http://docs.rackspacecloud.com/servers/api/v1.0" enabled="true" weekly="THURSDAY" daily="H_0400_0600" />
	//enabled="true" weekly="THURSDAY" daily="H_0400_0600"
	BOOL enabled;
	NSString *weekly;
	NSString *daily;
}

@property (assign) BOOL enabled;
@property (retain) NSString *weekly;
@property (retain) NSString *daily;

+ (id)backupSchedule;
- (NSString *)toXML;

@end
