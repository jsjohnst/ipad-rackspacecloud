//
//  ASICloudServersFlavorXMLParserDelegate.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASICloudServersFlavor;

// Prevent warning about missing NSXMLParserDelegate on Leopard and iPhone
#if !TARGET_OS_IPHONE && MAC_OS_X_VERSION_10_5 < MAC_OS_X_VERSION_MAX_ALLOWED
@interface ASICloudServersFlavorXMLParserDelegate : NSObject <NSXMLParserDelegate> {
#else
@interface ASICloudServersFlavorXMLParserDelegate : NSObject {
#endif
	
	NSMutableArray *flavorObjects;
	
	// Internally used while parsing the response
	NSString *currentContent;
	NSString *currentElement;
	ASICloudServersFlavor *currentObject;
}

@property (retain) NSMutableArray *flavorObjects;

@property (retain) NSString *currentElement;
@property (retain) NSString *currentContent;
@property (retain) ASICloudServersFlavor *currentObject;

@end
