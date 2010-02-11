//
//  RSSParser.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FeedItem;

@interface RSSParser : NSObject {
	NSMutableString *currentElementValue;
	NSString *currentDataType;
	FeedItem *feedItem;
	NSMutableArray *feedItems;
	BOOL parsingItem;
}

@property (nonatomic, retain) FeedItem *feedItem;
@property (nonatomic, retain) NSString *currentDataType;
@property (nonatomic, retain) NSMutableArray *feedItems;

@end
