//
//  MMCommonLogEntry.h
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/4/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

//94.125.16.11 - - [01/Feb/2010:14:42:18 +0000] "GET http://c0222312.origin.cdn.cloudfiles.rackspacecloud.com/rackcloudspanish-62.png HTTP/1.1" 200 169943 "http://overhrd.com/" "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.9.1.7) Gecko/20091221 Firefox/3.5.7 (.NET CLR 3.5.30729)"
//151.193.220.27 - - [01/Feb/2010:15:13:28 +0000] "GET http://c0222312.origin.cdn.cloudfiles.rackspacecloud.com/IMG_0109-54.PNG HTTP/1.1" 200 26477 "http://overhrd.com/" "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6 GTB6"


@interface MMCommonLogEntry : NSObject {
	NSString *fullLogEntry;
	NSString *ipAddress;
	NSDate *date;
	NSString *httpMethod;
	NSString *urlString;
	NSString *httpVersion;
	NSUInteger responseStatusCode;
	NSUInteger contentLength;
	NSString *referrer;
	NSString *userAgent;
	NSString *browser;
	NSString *browserVersion;
}

@property (nonatomic, retain) NSString *fullLogEntry;
@property (nonatomic, retain) NSString *ipAddress;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *httpVersion;
@property (nonatomic) NSUInteger responseStatusCode;
@property (nonatomic) NSUInteger contentLength;
@property (nonatomic, retain) NSString *referrer;
@property (nonatomic, retain) NSString *userAgent;
@property (nonatomic, retain) NSString *browser;
@property (nonatomic, retain) NSString *browserVersion;

-(id)initWithLogEntryText:(NSString *)logEntryText;

@end
