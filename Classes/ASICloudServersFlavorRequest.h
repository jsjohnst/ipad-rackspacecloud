//
//  ASICloudServersFlavorRequest.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ASICloudFilesRequest.h"

@class ASICloudServersFlavorXMLParserDelegate, ASICloudServersFlavor;

@interface ASICloudServersFlavorRequest : ASICloudFilesRequest {
	ASICloudServersFlavorXMLParserDelegate *xmlParserDelegate;
}

@property (retain) ASICloudServersFlavorXMLParserDelegate *xmlParserDelegate;

+ (NSArray *)flavors;
+ (void)setFlavors:(NSArray *)newFlavors;
+ (ASICloudServersFlavor *)flavorForId:(NSUInteger)flavorId;

// GET /flavors/detail.xml
+ (id)listRequest;
- (NSArray *)flavors;

@end
