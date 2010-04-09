//
//  ASICloudServersFlavorXMLParserDelegate.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/8/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ASICloudServersFlavorXMLParserDelegate.h"
#import "ASICloudServersFlavor.h"
#import "ASICloudFilesRequest.h"


@implementation ASICloudServersFlavorXMLParserDelegate


@synthesize flavorObjects, currentElement, currentContent, currentObject;

//<images xmlns="http://docs.rackspacecloud.com/servers/api/v1.0"><image status="ACTIVE" updated="2009-08-26T14:59:51-05:00" name="Gentoo 2008.0" id="3"/>

#pragma mark -
#pragma mark XML Parser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	[self setCurrentElement:elementName];
	
	if ([elementName isEqualToString:@"flavor"]) {
		[self setCurrentObject:[ASICloudServersFlavor flavor]];
		currentObject.flavorId = [[attributeDict objectForKey:@"id"] intValue];
		currentObject.name = [attributeDict objectForKey:@"name"];
		currentObject.disk = [[attributeDict objectForKey:@"disk"] intValue];
		currentObject.ram = [[attributeDict objectForKey:@"ram"] intValue];
	}
	[self setCurrentContent:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if ([elementName isEqualToString:@"flavor"]) {
		// we're done with this server.  time to move on to the next
		if (flavorObjects == nil) {
			flavorObjects = [[NSMutableArray alloc] init];
		}
		[flavorObjects addObject:currentObject];
		[self setCurrentObject:nil];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self setCurrentContent:[[self currentContent] stringByAppendingString:string]];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[flavorObjects release];
	[currentElement release];
	[currentContent release];
	[currentObject release];
	[super dealloc];
}

@end
