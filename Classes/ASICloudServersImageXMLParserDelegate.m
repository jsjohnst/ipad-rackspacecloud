//
//  ASICloudServersImageXMLParserDelegate.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ASICloudServersImageXMLParserDelegate.h"
#import "ASICloudServersImage.h"
#import "ASICloudFilesRequest.h"


@implementation ASICloudServersImageXMLParserDelegate


@synthesize imageObjects, currentElement, currentContent, currentObject;

//<images xmlns="http://docs.rackspacecloud.com/servers/api/v1.0"><image status="ACTIVE" updated="2009-08-26T14:59:51-05:00" name="Gentoo 2008.0" id="3"/>

#pragma mark -
#pragma mark XML Parser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	[self setCurrentElement:elementName];
	
	if ([elementName isEqualToString:@"image"]) {
		[self setCurrentObject:[ASICloudServersImage image]];
		currentObject.imageId = [[attributeDict objectForKey:@"id"] intValue];
		currentObject.name = [attributeDict objectForKey:@"name"];
		currentObject.status = [attributeDict objectForKey:@"status"];
		currentObject.updated = [ASICloudFilesRequest dateFromString:[attributeDict objectForKey:@"updated"]];
	}
	[self setCurrentContent:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if ([elementName isEqualToString:@"image"]) {
		// we're done with this server.  time to move on to the next
		if (imageObjects == nil) {
			imageObjects = [[NSMutableArray alloc] init];
		}
		[imageObjects addObject:currentObject];
		[self setCurrentObject:nil];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self setCurrentContent:[[self currentContent] stringByAppendingString:string]];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[imageObjects release];
	[currentElement release];
	[currentContent release];
	[currentObject release];
	[super dealloc];
}

@end
