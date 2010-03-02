//
//  ASICloudFilesContainer.m
//
//  Created by Michael Mayo on 1/7/10.
//

#import "ASICloudFilesContainer.h"


@implementation ASICloudFilesContainer

// regular container attributes
@synthesize name, count, bytes;

// CDN container attributes
@synthesize cdnEnabled, ttl, cdnURL, logRetention, referrerACL, useragentACL;

+ (id)container {
	ASICloudFilesContainer *container = [[[self alloc] init] autorelease];
	return container;
}

-(NSString *)humanizedBytes {
	NSString *result;	
	if (self.bytes >= 1024000000) {
		result = [NSString stringWithFormat:@"%.2f GB", self.bytes / 1024000000.0];
	} else if (self.bytes >= 1024000) {
		result = [NSString stringWithFormat:@"%.2f MB", self.bytes / 1024000.0];
	} else if (self.bytes >= 1024) {
		result = [NSString stringWithFormat:@"%.2f KB", self.bytes / 1024.0];
	} else {
		result = [NSString stringWithFormat:@"%i bytes", self.bytes];
	}
	return result;
}

-(NSString *)humanizedCount {
	NSString *noun = NSLocalizedString(@"files", @"files");
	if (self.count == 1) {
		noun = NSLocalizedString(@"file", @"file");
	}
	return [NSString stringWithFormat:@"%i %@", self.count, noun];
}


-(NSString *)humanizedSize {
	return [NSString stringWithFormat:@"%@, %@", [self humanizedCount], [self humanizedBytes]];
}

-(void) dealloc {
	[name release];
	[super dealloc];
}

@end
