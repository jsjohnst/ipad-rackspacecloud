//
//  ASICloudServersFlavorRequest.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ASICloudServersFlavorRequest.h"
#import "ASICloudServersFlavorXMLParserDelegate.h"
#import "ASICloudServersFlavor.h"

static NSArray *flavors = nil;
static NSMutableDictionary *flavorDict = nil;
static NSRecursiveLock *accessDetailsLock = nil;

@implementation ASICloudServersFlavorRequest

@synthesize xmlParserDelegate;

+ (NSArray *)flavors {
	return flavors;
}

+ (void)setFlavors:(NSArray *)newFlavors
{
	[accessDetailsLock lock];
	[flavors release];
	[flavorDict release];
	flavors = [newFlavors retain];
	flavorDict = [[NSMutableDictionary alloc] initWithCapacity:[newFlavors count]];
	for (int i = 0; i < [flavors count]; i++) {
		ASICloudServersFlavor *flavor = [flavors objectAtIndex:i];
		[flavorDict setObject:flavor forKey:[NSNumber numberWithInt:flavor.flavorId]];
	}
	[accessDetailsLock unlock];
}

+ (ASICloudServersFlavor *)flavorForId:(NSUInteger)flavorId {
	return [flavorDict objectForKey:[NSNumber numberWithInt:flavorId]];
}

#pragma mark -
#pragma mark GET - Image List

+ (id)listRequest {
	NSString *urlString = [NSString stringWithFormat:@"%@/flavors/detail.xml", [ASICloudFilesRequest serverManagementURL]];
	ASICloudServersFlavorRequest *request = [[[ASICloudServersFlavorRequest alloc] initWithURL:[NSURL URLWithString:urlString]] autorelease];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"X-Auth-Token" value:[ASICloudServersFlavorRequest authToken]];
	return request;
}

- (NSArray *)flavors {
	if (xmlParserDelegate.flavorObjects) {
		return xmlParserDelegate.flavorObjects;
	}
	
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:[self responseData]] autorelease];
	if (xmlParserDelegate == nil) {
		xmlParserDelegate = [[ASICloudServersFlavorXMLParserDelegate alloc] init];
	}
	
	[parser setDelegate:xmlParserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	
	return xmlParserDelegate.flavorObjects;
}

- (void)dealloc {
	[xmlParserDelegate release];
	[super dealloc];
}



@end
