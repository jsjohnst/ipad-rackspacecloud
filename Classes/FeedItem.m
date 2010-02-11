//
//  FeedItem.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "FeedItem.h"


@implementation FeedItem

@synthesize title, link, guid, description, content, creator, pubDate;

- (NSComparisonResult)compare:(FeedItem *)anotherFeedItem {
	return [self.pubDate compare:anotherFeedItem.pubDate];
}

-(void) dealloc {
	[title release];
	[link release];
	[guid release];
	[description release];
	[content release];
	[creator release];
	[pubDate release];
	[super dealloc];
}

@end
