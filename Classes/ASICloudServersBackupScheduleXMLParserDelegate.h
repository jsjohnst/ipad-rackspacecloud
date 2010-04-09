//
//  ASICloudServersBackupScheduleXMLParserDelegate.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/12/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASICloudServersBackupSchedule;

// Prevent warning about missing NSXMLParserDelegate on Leopard and iPhone
#if !TARGET_OS_IPHONE && MAC_OS_X_VERSION_10_5 < MAC_OS_X_VERSION_MAX_ALLOWED
@interface ASICloudServersBackupScheduleXMLParserDelegate : NSObject <NSXMLParserDelegate> {
#else
	@interface ASICloudServersBackupScheduleXMLParserDelegate : NSObject {
#endif
		
		// Internally used while parsing the response
		NSString *currentContent;
		NSString *currentElement;
		ASICloudServersBackupSchedule *currentObject;
	}
	
	@property (retain) NSString *currentElement;
	@property (retain) NSString *currentContent;
	@property (retain) ASICloudServersBackupSchedule *currentObject;
	
	@end
