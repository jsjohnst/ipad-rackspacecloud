//
//  ASICloudServersBackupScheduleXMLParserDelegate.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/12/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "ASICloudServersBackupScheduleXMLParserDelegate.h"
#import "ASICloudServersBackupSchedule.h"
#import "ASICloudFilesRequest.h"


@implementation ASICloudServersBackupScheduleXMLParserDelegate


@synthesize currentElement, currentContent, currentObject;

//<images xmlns="http://docs.rackspacecloud.com/servers/api/v1.0"><image status="ACTIVE" updated="2009-08-26T14:59:51-05:00" name="Gentoo 2008.0" id="3"/>

#pragma mark -
#pragma mark XML Parser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	[self setCurrentElement:elementName];
	
	if ([elementName isEqualToString:@"backupSchedule"]) {
		[self setCurrentObject:[ASICloudServersBackupSchedule backupSchedule]];
		currentObject.enabled = [[attributeDict objectForKey:@"enabled"] boolValue];
		currentObject.weekly = [attributeDict objectForKey:@"weekly"];
		currentObject.daily = [attributeDict objectForKey:@"daily"];
	}
	[self setCurrentContent:@""];
}
//<backupSchedule xmlns="http://docs.rackspacecloud.com/servers/api/v1.0" enabled="true" weekly="THURSDAY" daily="H_0400_0600" />
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	// only one element, so nothing to do here
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self setCurrentContent:[[self currentContent] stringByAppendingString:string]];
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[currentElement release];
	[currentContent release];
	[currentObject release];
	[super dealloc];
}

@end
