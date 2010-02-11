//
//  ASICloudServersServer.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/7/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ASICloudServersServer.h"


@implementation ASICloudServersServer

@synthesize serverId, name, imageId, flavorId, hostId, publicIpAddresses, privateIpAddresses, metadata, status, progress, adminPass;

+ (id) server {
	ASICloudServersServer *server = [[[self alloc] init] autorelease];
	server.publicIpAddresses = [[NSMutableArray alloc] init];
	server.privateIpAddresses = [[NSMutableArray alloc] init];
	server.metadata = [[NSMutableDictionary alloc] init];
	return server;
}

- (NSString *)toXML {
	/*
	 <server xmlns="http://docs.rackspacecloud.com/servers/api/v1.0"
	 name="new-server-test" imageId="2" flavorId="1">
	 <metadata>
	 <meta key="My Server Name">Apache1</meta>
	 </metadata>
	 <personality>
	 <file path="/etc/banner.txt">
	 ICAgICAgDQoiQSBjbG91ZCBkb2VzIG5vdCBrbm93IHdoeSBp
	 dCBtb3ZlcyBpbiBqdXN0IHN1Y2ggYSBkaXJlY3Rpb24gYW5k
	 IGF0IHN1Y2ggYSBzcGVlZC4uLkl0IGZlZWxzIGFuIGltcHVs
	 c2lvbi4uLnRoaXMgaXMgdGhlIHBsYWNlIHRvIGdvIG5vdy4g
	 QnV0IHRoZSBza3kga25vd3MgdGhlIHJlYXNvbnMgYW5kIHRo
	 ZSBwYXR0ZXJucyBiZWhpbmQgYWxsIGNsb3VkcywgYW5kIHlv
	 dSB3aWxsIGtub3csIHRvbywgd2hlbiB5b3UgbGlmdCB5b3Vy
	 c2VsZiBoaWdoIGVub3VnaCB0byBzZWUgYmV5b25kIGhvcml6
	 b25zLiINCg0KLVJpY2hhcmQgQmFjaA==
	 </file>
	 </personality>
	 </server>
	 */
	NSString *xml = [NSString stringWithFormat:@"<server xmlns=\"http://docs.rackspacecloud.com/servers/api/v1.0\" name=\"%@\" imageId=\"%i\" flavorId=\"%i\"></server>", self.name, self.imageId, self.flavorId];	
	return xml;
}

-(void) dealloc {
	[name release];
	[hostId release];
	[publicIpAddresses release];
	[privateIpAddresses release];
	[metadata release];
	[status release];
	[adminPass release];
	[super dealloc];
}

@end
