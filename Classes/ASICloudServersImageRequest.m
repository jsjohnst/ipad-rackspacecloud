//
//  ASICloudServersImageRequest.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ASICloudServersImageRequest.h"
#import "ASICloudServersImageXMLParserDelegate.h"
#import "ASICloudServersImage.h"

static NSArray *images = nil;
static NSMutableDictionary *imageDict = nil;
static NSRecursiveLock *accessDetailsLock = nil;

@implementation ASICloudServersImageRequest

@synthesize xmlParserDelegate;

+ (NSArray *)images {
	return images;
}

+ (void)setImages:(NSArray *)newImages
{
	[accessDetailsLock lock];
	[images release];
	[imageDict release];
	images = [newImages retain];
	imageDict = [[NSMutableDictionary alloc] initWithCapacity:[newImages count]];
	for (int i = 0; i < [images count]; i++) {
		ASICloudServersImage *image = [images objectAtIndex:i];
		if ([image.status isEqualToString:@"ACTIVE"]) {
			[imageDict setObject:image forKey:[NSNumber numberWithInt:image.imageId]];
		}
	}
	[accessDetailsLock unlock];
}

+ (ASICloudServersImage *)imageForId:(NSUInteger)imageId {
	return [imageDict objectForKey:[NSNumber numberWithInt:imageId]];
}

#pragma mark -
#pragma mark GET - Image List

+ (id)listRequest {
	NSString *urlString = [NSString stringWithFormat:@"%@/images/detail.xml", [ASICloudFilesRequest serverManagementURL]];
	ASICloudServersImageRequest *request = [[[ASICloudServersImageRequest alloc] initWithURL:[NSURL URLWithString:urlString]] autorelease];
	[request setRequestMethod:@"GET"];
	[request addRequestHeader:@"X-Auth-Token" value:[ASICloudServersImageRequest authToken]];
	return request;
}

- (NSArray *)images {
	if (xmlParserDelegate.imageObjects) {
		return xmlParserDelegate.imageObjects;
	}
	
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:[self responseData]] autorelease];
	if (xmlParserDelegate == nil) {
		xmlParserDelegate = [[ASICloudServersImageXMLParserDelegate alloc] init];
	}
	
	[parser setDelegate:xmlParserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	
	return xmlParserDelegate.imageObjects;
}

- (void)dealloc {
	[xmlParserDelegate release];
	[super dealloc];
}



@end
