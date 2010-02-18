//
//  AtomParser.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "AtomParser.h"
#import "FeedItem.h"


@implementation AtomParser

@synthesize feedItem, currentDataType, feedItems;

/*
<entry>
	<title>Cloud Sites | WC2.DFW1 | MA Cache | Online</title>
	<link rel="alternate" type="text/html" href="http://status.mosso.com/2010/01/cloud-sites-wc2dfw1-ma-cache-degraded.html" />
	<link rel="replies" type="text/html" href="http://status.mosso.com/2010/01/cloud-sites-wc2dfw1-ma-cache-degraded.html" />
	<id>tag:typepad.com,2003:post-6a00d8346d38b053ef01287720a82a970c</id>
	<published>2010-01-28T10:57:11-06:00</published>
	<updated>2010-01-28T12:25:54-06:00</updated>
	<summary>As of 10:50 AM CST, The Rackspace Cloud engineers have identified a problem causing degraded performance on our MA CACHE servers in our WC2.DFW1 data center. This is an isolated issue and we've repaired the issue. You may still see...</summary>
	<author>
		<name>Jeremy Siefer</name>
	</author>
	<content type="xhtml" xml:lang="en-US" xml:base="http://status.mosso.com/">
		<div xmlns="http://www.w3.org/1999/xhtml"><p>As of 10:50 AM CST, The Rackspace Cloud engineers have identified a problem causing degraded performance on our MA CACHE servers in our WC2.DFW1 data center.  This is an isolated issue and we've repaired the issue.  You may still see slowness as the cache rebuilds on this node.  If you have any questions, please contact
		a member of our support team via live-chat.</p><p>AS of 11:19 AM CST The Rackspace Cloud engineers havecorrected the problem causing
		degraded performance on our MA CACHE servers in our WC2.DFW1 data
		center. We apologize for
		this inconvenience and if you have any other questions,
		please contact a member of our support team
		via live-chat or at the following telephone numbers: 24-our toll free
		1.877.934.0407 and INTL +1.210.581.0407.</p></div>
	</content>
</entry> 
*/

#pragma mark -
#pragma mark Date Parser

-(NSDate *)dateFromString:(NSString *)dateString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
	// example: 2009-11-04T19:46:20.192723
	//<publish  2010-01-28T10:57:11-06:00</published>
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:sszzzz"];
	//[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzzz"];
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
	
	if ([elementName isEqualToString:@"feed"]) {
		// we're getting started, so go ahead and alloc the array
		self.feedItems = [[NSMutableArray alloc] initWithCapacity:1];
	} else if ([elementName isEqualToString:@"entry"]) {
		self.feedItem = [[FeedItem alloc] init];
		parsingItem = YES;
	} else if ([elementName isEqualToString:@"content"]) {
        self.feedItem.content = @"";
        parsingContent = YES;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	//NSLog(@"Ended Element:   %@", elementName);
	
	//	<pubDate>Fri, 15 Jan 2010 16:16:59 -0600</pubDate>
	
	if ([elementName isEqualToString:@"entry"]) {
		[self.feedItems addObject:self.feedItem];
		parsingItem = NO;
	} else if ([elementName isEqualToString:@"title"]) {
		feedItem.title = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//	} else if ([elementName isEqualToString:@"link"]) {
//		feedItem.link = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"id"]) {
		feedItem.guid = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"summary"]) {
		feedItem.description = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"content"]) {
		//feedItem.content = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"content = %@", feedItem.content);
        parsingContent = NO;        
	} else if ([elementName isEqualToString:@"name"]) {
		feedItem.creator = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else if ([elementName isEqualToString:@"published"]) {
		feedItem.pubDate = [self dateFromString:[currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}
	
	if (parsingContent) {
	    if ([elementName isEqualToString:@"div"]) {
	        // the div is just a wrapper for the rackcloud status item
	    } else if ([elementName isEqualToString:@"p"]) {
            NSString *newLine = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            feedItem.content = [feedItem.content stringByAppendingString:[NSString stringWithFormat:@"\n%@", newLine]];
	    }
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
