//
//  ASICloudServersServerXMLParserDelegate.m
//
//  Created by Michael Mayo on 1/10/10.
//

#import "ASICloudServersServerXMLParserDelegate.h"
#import "ASICloudServersServer.h"

#define kPublicIPMode 1
#define kPrivateIPMode 2

@implementation ASICloudServersServerXMLParserDelegate

@synthesize serverObjects, currentElement, currentContent, currentObject, currentMetadataKey;

/*
<server xmlns="http://docs.rackspacecloud.com/servers/api/v1.0"
id="1235" name="new-server-test" imageId="2" flavorId="1"
hostId="e4d909c290d0fb1ca068ffaddf22cbd0" progress="0" status="BUILD" adminPass="GFf1j9aP">
<metadata>
<meta key="My Server Name">Apache1</meta>
</metadata>
<addresses>
<public>
<ip addr="67.23.10.138"/>
</public>
<private>
<ip addr="10.176.42.19"/>
</private>
</addresses>
</server> 
*/

#pragma mark -
#pragma mark XML Parser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	[self setCurrentElement:elementName];
	
	if ([elementName isEqualToString:@"server"]) {
		[self setCurrentObject:[ASICloudServersServer server]];
		currentObject.serverId = [[attributeDict objectForKey:@"id"] intValue];
		currentObject.name = [attributeDict objectForKey:@"name"];
		currentObject.imageId = [[attributeDict objectForKey:@"imageId"] intValue];
		currentObject.flavorId = [[attributeDict objectForKey:@"flavorId"] intValue];
		currentObject.hostId = [attributeDict objectForKey:@"hostId"];
		currentObject.progress = [[attributeDict objectForKey:@"progress"] intValue];
		currentObject.status = [attributeDict objectForKey:@"status"];
		currentObject.adminPass = [attributeDict objectForKey:@"adminPass"];
	} else if ([elementName isEqualToString:@"meta"]) {
		currentMetadataKey = [attributeDict objectForKey:@"key"];
	} else if ([elementName isEqualToString:@"public"]) {
		ipMode = kPublicIPMode;
	} else if ([elementName isEqualToString:@"private"]) {
		ipMode = kPrivateIPMode;
	} else if ([elementName isEqualToString:@"ip"]) {
		NSMutableArray *ipAddresses = nil;
		if (ipMode == kPublicIPMode) {
			ipAddresses = currentObject.publicIpAddresses;
		} else if (ipMode == kPrivateIPMode) {
			ipAddresses = currentObject.privateIpAddresses;
		}
		if (ipAddresses != nil) {
			[ipAddresses addObject:[attributeDict objectForKey:@"addr"]];
		}
	}
	
	[self setCurrentContent:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if ([elementName isEqualToString:@"meta"]) {
		// <meta key="My Server Name">Apache1</meta>
		[[self currentObject].metadata setObject:[self currentContent] forKey:currentMetadataKey];
	} else if ([elementName isEqualToString:@"addresses"]) {
		//[self currentObject].name = [self currentContent];
//	} else if ([elementName isEqualToString:@"count"]) {
//		[self currentObject].count = [[self currentContent] intValue];
//	} else if ([elementName isEqualToString:@"bytes"]) {
//		[self currentObject].bytes = [[self currentContent] intValue];
//	} else if ([elementName isEqualToString:@"cdn_enabled"]) {
//		[self currentObject].cdnEnabled = [[self currentObject] isEqual:@"True"];
//	} else if ([elementName isEqualToString:@"ttl"]) {
//		[self currentObject].ttl = [[self currentContent] intValue];
//	} else if ([elementName isEqualToString:@"cdn_url"]) {
//		[self currentObject].cdnURL = [self currentContent];
//	} else if ([elementName isEqualToString:@"log_retention"]) {
//		[self currentObject].logRetention = [[self currentObject] isEqual:@"True"];
//	} else if ([elementName isEqualToString:@"referrer_acl"]) {
//		[self currentObject].referrerACL = [self currentContent];
//	} else if ([elementName isEqualToString:@"useragent_acl"]) {
//		[self currentObject].useragentACL = [self currentContent];
	} else if ([elementName isEqualToString:@"server"]) {
		// we're done with this server.  time to move on to the next
		if (serverObjects == nil) {
			serverObjects = [[NSMutableArray alloc] init];
		}
		[serverObjects addObject:currentObject];
		[self setCurrentObject:nil];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self setCurrentContent:[[self currentContent] stringByAppendingString:string]];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[serverObjects release];
	[currentElement release];
	[currentContent release];
	[currentObject release];
	[currentMetadataKey release];
	[super dealloc];
}

@end
