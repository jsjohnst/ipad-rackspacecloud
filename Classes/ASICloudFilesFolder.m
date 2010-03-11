//
//  ASICloudFilesFolder.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 3/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ASICloudFilesFolder.h"


@implementation ASICloudFilesFolder

@synthesize name, parent, folders, files;

+ (id)folder {
	ASICloudFilesFolder *folder = [[[self alloc] init] autorelease];
	folder.files = [[NSMutableArray alloc] init];
	folder.folders = [[NSMutableArray alloc] init];
	return folder;
}

-(void)dealloc {
	[name release];
	[parent release];
	[folders release];
	[files release];	
	[super dealloc];
}

@end
