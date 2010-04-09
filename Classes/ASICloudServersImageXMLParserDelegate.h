//
//  ASICloudServersImageXMLParserDelegate.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASICloudServersImage;

// Prevent warning about missing NSXMLParserDelegate on Leopard and iPhone
#if !TARGET_OS_IPHONE && MAC_OS_X_VERSION_10_5 < MAC_OS_X_VERSION_MAX_ALLOWED
@interface ASICloudServersServerXMLParserDelegate : NSObject <NSXMLParserDelegate> {
#else
@interface ASICloudServersImageXMLParserDelegate : NSObject {
#endif
	
	NSMutableArray *imageObjects;
	
	// Internally used while parsing the response
	NSString *currentContent;
	NSString *currentElement;
	ASICloudServersImage *currentObject;
}

@property (retain) NSMutableArray *imageObjects;

@property (retain) NSString *currentElement;
@property (retain) NSString *currentContent;
@property (retain) ASICloudServersImage *currentObject;

@end
