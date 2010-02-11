//
//  MMCommonLogEntry.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/4/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "MMCommonLogEntry.h"


@implementation MMCommonLogEntry

@synthesize fullLogEntry, ipAddress, date, httpMethod, urlString, httpVersion, 
			responseStatusCode, contentLength, referrer, userAgent, browser, browserVersion;

-(NSDate *)dateFromString:(NSString *)dateString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
	// example: 2009-11-04T19:46:20.192723
	//<publish  2010-01-28T10:57:11-06:00</published>
	//[01/Feb/2010:14:42:18 +0000]
	[dateFormatter setDateFormat:@"[dd/MMM/yyy:HH:mm:ss zzzz]"];
	//[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzzz"];
	NSDate *aDate = [dateFormatter dateFromString:dateString];
	[dateFormatter release];
	
	return aDate;
}

-(id)initWithLogEntryText:(NSString *)logEntryText {
	if (self = [super init]) {
		fullLogEntry = logEntryText;
		
		NSArray *spaceComponents = [fullLogEntry componentsSeparatedByString:@" "];
		NSArray *quoteComponents = [fullLogEntry componentsSeparatedByString:@"\""];
		
		ipAddress = [spaceComponents objectAtIndex:0];
		
		NSString *dateString = [NSString stringWithFormat:@"%@ %@", [spaceComponents objectAtIndex:3], [spaceComponents objectAtIndex:4]];
		date = [self dateFromString:dateString];
		
		httpMethod = [[spaceComponents objectAtIndex:5] substringFromIndex:1]; // index 1 is a "
		
		//94.125.16.11 - - [01/Feb/2010:14:42:18 +0000] "GET http://c0222312.origin.cdn.cloudfiles.rackspacecloud.com/rackcloudspanish-62.png HTTP/1.1" 200 169943 "http://overhrd.com/" "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.9.1.7) Gecko/20091221 Firefox/3.5.7 (.NET CLR 3.5.30729)"
		//151.193.220.27 - - [01/Feb/2010:15:13:28 +0000] "GET http://c0222312.origin.cdn.cloudfiles.rackspacecloud.com/IMG_0109-54.PNG HTTP/1.1" 200 26477 "http://overhrd.com/" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6 GTB6"
		
		urlString = [spaceComponents objectAtIndex:6];
		
		httpVersion = [spaceComponents objectAtIndex:7];

		//200 26477 "http://overhrd.com/" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6 GTB6"

		responseStatusCode = [[spaceComponents objectAtIndex:8] intValue];
		contentLength = [[spaceComponents objectAtIndex:9] intValue];
		
		referrer = [quoteComponents objectAtIndex:3];
		
		userAgent = [quoteComponents objectAtIndex:5];
		browser = [spaceComponents lastObject];
		
		NSArray *browserComponents = [browser componentsSeparatedByString:@"/"];
		
		browser = [browserComponents objectAtIndex:0];
		if ([browserComponents count] > 1) {
			browserVersion = [browserComponents objectAtIndex:1];
		}

//		NSLog(@"Log Entry: %@ %@ %@ %@ %i %i %@ %@ %@",
//			  ipAddress, date, httpMethod, urlString, responseStatusCode,
//			  contentLength, referrer, userAgent, browser);
	}
	return self;	
}

-(void)dealloc {
	[fullLogEntry release];
	[ipAddress release];
	[date release];
	[httpMethod	release];
	[urlString release];
	[httpVersion release];
	[referrer release];
	[userAgent release];
	[browser release];
	[browserVersion release];
	[super dealloc];
}

@end
