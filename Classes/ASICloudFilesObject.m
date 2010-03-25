//
//  ASICloudFilesObject.m
//
//  Created by Michael Mayo on 1/7/10.
//

#import "ASICloudFilesObject.h"


@implementation ASICloudFilesObject

@synthesize name, fullPath, hash, bytes, contentType, lastModified, data, metadata;

+ (id)object {
	ASICloudFilesObject *object = [[[self alloc] init] autorelease];
	return object;
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

-(void)dealloc {
	[name release];
    [fullPath release];
	[hash release];
	[contentType release];
	[lastModified release];
	[data release];
	[metadata release];
	[super dealloc];
}

@end
