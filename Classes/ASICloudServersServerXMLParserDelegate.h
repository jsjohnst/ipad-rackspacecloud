//
//  ASICloudServersServerXMLParserDelegate.h
//
//  Created by Michael Mayo on Feb 7, 2010.
//

#import "ASICloudFilesRequest.h"

@class ASICloudServersServer;

// Prevent warning about missing NSXMLParserDelegate on Leopard and iPhone
#if !TARGET_OS_IPHONE && MAC_OS_X_VERSION_10_5 < MAC_OS_X_VERSION_MAX_ALLOWED
@interface ASICloudServersServerXMLParserDelegate : NSObject <NSXMLParserDelegate> {
#else
@interface ASICloudServersServerXMLParserDelegate : NSObject {
#endif
		
	NSMutableArray *serverObjects;
	
	// Internally used while parsing the response
	NSString *currentContent;
	NSString *currentElement;
	ASICloudServersServer *currentObject;
	NSString *currentMetadataKey;
	
	NSUInteger ipMode;
}

@property (retain) NSMutableArray *serverObjects;

@property (retain) NSString *currentElement;
@property (retain) NSString *currentContent;
@property (retain) ASICloudServersServer *currentObject;
@property (retain) NSString *currentMetadataKey;

	
@end
