//
//  RSSParser.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "RSSParser.h"
#import "FeedItem.h"


@implementation RSSParser

@synthesize feedItem, currentDataType, feedItems;

/*
<?xml version="1.0" encoding="utf-8"?>
<rss xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:content="http://purl.org/rss/1.0/modules/content/" version="2.0">
	<channel>
		<title>Cloud Servers Status</title>
		<link>http://status.rackspacecloud.com/cloudservers/</link>
		<description></description>
		<language>en-US</language>
		<lastBuildDate>Fri, 15 Jan 2010 16:16:59 -0600</lastBuildDate>
		<generator>http://www.typepad.com/</generator>
		<atom10:link xmlns:atom10="http://www.w3.org/2005/Atom" rel="self" href="http://status.rackspacecloud.com/cloudservers/rss.xml" type="application/rss+xml" />
		<docs>http://www.rssboard.org/rss-specification</docs>
		<item>
			<title>Huddle 16 Connectivity -Resolved</title>
			<link>http://status.rackspacecloud.com/cloudservers/2010/01/huddle-16-connectivity.html</link>
			<guid isPermaLink="true">http://status.rackspacecloud.com/cloudservers/2010/01/huddle-16-connectivity.html</guid>
			<description>Huddle 16 is currently experiencing network related issue, you may see issues connecting to your server and accessing the Cloud Servers section of the control panel. The control panel may be loading slowly or timing out completely. Our technicians are working to quickly resolve the issue. We will post another update once PHP 5 sites are back to normal speeds. Update: Connectivity is returning, and all issues should begin resolving.</description>
			<content:encoded>&lt;p&gt;Huddle 16 is currently experiencing network related issue, you may see issues connecting to your server and accessing the Cloud Servers section of the control panel.&amp;#0160; The control panel may be loading slowly or timing out completely. Our technicians are working to
			quickly resolve the issue. We will post another update once PHP 5 sites
			are back to normal speeds.&lt;/p&gt;&lt;p&gt;&lt;/p&gt;&lt;p&gt;Update: Connectivity is returning, and all issues should begin resolving.&lt;/p&gt;</content:encoded>
			<dc:creator>Jeremy Siefer</dc:creator>
			<pubDate>Fri, 15 Jan 2010 16:16:59 -0600</pubDate>
		</item>
	</channel>
</rss> 
*/

#pragma mark -
#pragma mark Date Parser

-(NSDate *)dateFromString:(NSString *)dateString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
	// <pubDate>Fri, 15 Jan 2010 16:16:59 -0600</pubDate>
	[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzzz"];
	NSDate *date = [dateFormatter dateFromString:dateString];
	[dateFormatter release];
	
	return date;
}


#pragma mark -
#pragma mark XML Parser Delegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
	//NSLog(@"Started Element: %@", elementName);
	
	//Extract the attribute here.
	//aBook.bookID = [[attributeDict objectForKey:@"id"] integerValue];
	
//	if (![elementName isEqualToString:@"uri"]) {
//		// if it's not the uri, it's a data type
//		currentDataType = [NSString stringWithString:elementName];
//	}
	
	if ([elementName isEqualToString:@"rss"]) {
		// we're getting started, so go ahead and alloc the array
		self.feedItems = [[NSMutableArray alloc] initWithCapacity:1];
	} else if ([elementName isEqualToString:@"item"]) {
		self.feedItem = [[FeedItem alloc] init];
		parsingItem = YES;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	//NSLog(@"Ended Element:   %@", elementName);
	
//	<pubDate>Fri, 15 Jan 2010 16:16:59 -0600</pubDate>
	
	if ([elementName isEqualToString:@"item"]) {
		[self.feedItems addObject:self.feedItem];
		parsingItem = NO;
	} else if ([elementName isEqualToString:@"title"]) {		
		feedItem.title = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"link"]) {
		feedItem.link = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"guid"]) {
		feedItem.guid = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"description"]) {
		feedItem.description = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"content:encoded"]) {
		feedItem.content = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// &lt;p&gt;Huddle 16 is currently experiencing network related issue, you may see issues connecting to your server and accessing the Cloud Servers section of the control panel.&amp;#0160; The control panel may be loading slowly or timing out completely. Our technicians are working to
        // quickly resolve the issue. We will post another update once PHP 5 sites
        // are back to normal speeds.&lt;/p&gt;&lt;p&gt;&lt;/p&gt;&lt;p&gt;Update: Connectivity is returning, and all issues should begin resolving.&lt;/p&gt;
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"&lt;/p&gt;&lt;p&gt;" withString:@"\n"];        
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"&lt;p&gt;" withString:@""];
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"&lt;/p&gt;" withString:@""];
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"</p><p>" withString:@"\n"];        
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        feedItem.content = [feedItem.content stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        
        NSLog(@"RSS Content: %@", feedItem.content);
		
	} else if ([elementName isEqualToString:@"dc:creator"]) {
		feedItem.creator = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"pubDate"]) {
		feedItem.pubDate = [self dateFromString:[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
		NSLog(@"Pub date: %@", feedItem.pubDate);
	}
	
	[currentElementValue release];
	currentElementValue = nil;	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (!currentElementValue) {
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		[currentElementValue appendString:string];
	}
	//NSLog(@"Processing Value: %@", currentElementValue);
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[feedItem release];
	[currentDataType release];
	[feedItems release];
	[super dealloc];
}


@end
