//
//  ASICloudServersImage.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/7/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ASICloudServersImage.h"


static UIImage *centosIcon = nil;
static UIImage *centosLogo = nil;
static UIImage *centosBackground = nil;

static UIImage *debianIcon = nil;
static UIImage *debianLogo = nil;
static UIImage *debianBackground = nil;

static UIImage *fedoraIcon = nil;
static UIImage *fedoraLogo = nil;
static UIImage *fedoraBackground = nil;

static UIImage *ubuntuIcon = nil;
static UIImage *ubuntuLogo = nil;
static UIImage *ubuntuBackground = nil;

static UIImage *gentooIcon = nil;
static UIImage *gentooLogo = nil;
static UIImage *gentooBackground = nil;

static UIImage *windowsIcon = nil;
static UIImage *windowsLogo = nil;
static UIImage *windowsBackground = nil;

static UIImage *archIcon = nil;
static UIImage *archLogo = nil;
static UIImage *archBackground = nil;

static UIImage *redhatIcon = nil;
static UIImage *redhatLogo = nil;
static UIImage *redhatBackground = nil;

@implementation ASICloudServersImage

@synthesize status, updated, name, imageId;

+(void)initialize {
	// TODO: should i release these at some point?
	centosIcon = [[UIImage imageNamed:@"centos-icon.png"] retain];
	centosLogo = [[UIImage imageNamed:@"centos-logo.png"] retain];
	centosBackground = [[UIImage imageNamed:@"centos-large.png"] retain];
	
	debianIcon = [[UIImage imageNamed:@"debian-icon.png"] retain];
	debianLogo = [[UIImage imageNamed:@"debian-logo.png"] retain];
	debianBackground = [[UIImage imageNamed:@"debian-large.png"] retain];

	fedoraIcon = [[UIImage imageNamed:@"fedora-icon.png"] retain];
	fedoraLogo = [[UIImage imageNamed:@"fedora-logo.png"] retain];
	fedoraBackground = [[UIImage imageNamed:@"fedora-large.png"] retain];

	ubuntuIcon = [[UIImage imageNamed:@"ubuntu-icon.png"] retain];
	ubuntuLogo = [[UIImage imageNamed:@"ubuntu-logo.png"] retain];
	ubuntuBackground = [[UIImage imageNamed:@"ubuntu-large.png"] retain];

	gentooIcon = [[UIImage imageNamed:@"gentoo-icon.png"] retain];
	gentooLogo = [[UIImage imageNamed:@"gentoo-logo.png"] retain];
	gentooBackground = [[UIImage imageNamed:@"gentoo-large.png"] retain];

	windowsIcon = [[UIImage imageNamed:@"windows-icon.png"] retain];
	windowsLogo = [[UIImage imageNamed:@"windows-logo.png"] retain];
	windowsBackground = [[UIImage imageNamed:@"windows-large.png"] retain];	

	archIcon = [[UIImage imageNamed:@"arch-icon.png"] retain];
	archLogo = [[UIImage imageNamed:@"arch-logo.png"] retain];
	archBackground = [[UIImage imageNamed:@"arch-large.png"] retain];	

	redhatIcon = [[UIImage imageNamed:@"redhat-icon.png"] retain];
	redhatLogo = [[UIImage imageNamed:@"redhat-logo.png"] retain];
	redhatBackground = [[UIImage imageNamed:@"redhat-large.png"] retain];	
}

+(UIImage *)iconForImageId:(NSUInteger)imageId {
	if (imageId == 2) {
		return centosIcon;
	} else if (imageId == 3) {
		return gentooIcon;
	} else if (imageId == 4) {
		return debianIcon;
	} else if (imageId == 5) {
		return fedoraIcon;
	} else if (imageId == 7) {
		return centosIcon;
	} else if (imageId == 8) {
		return ubuntuIcon;
	} else if (imageId == 9) {
		return archIcon;
	} else if (imageId == 10) {
		return ubuntuIcon;
	} else if (imageId == 11) {
		return ubuntuIcon;
	} else if (imageId == 12) {
		return redhatIcon;
	} else if (imageId == 13) {
		return archIcon;
	} else if (imageId == 4056) {
		return fedoraIcon;
	} else if (imageId == 14362) {
		return ubuntuIcon;
	} else if (imageId == 23) {
		return windowsIcon;
	} else if (imageId == 24) {
		return windowsIcon;
	} else if (imageId == 28) {
		return windowsIcon;
	} else if (imageId == 29) {
		return windowsIcon;
	} else if (imageId == 31) {
		return windowsIcon;
	} else if (imageId == 14) {
		return redhatIcon;
	} else if (imageId == 17) {
		return fedoraIcon;
	} else if (imageId == 19) {
		return gentooIcon;
	} else if (imageId == 14362) {
		return ubuntuIcon;
	} else if (imageId == 187811) {
		return centosIcon;
	} else {

	}
	
	return nil;
}
+(UIImage *)logoForImageId:(NSUInteger)imageId {
	if (imageId == 2) {
		return centosLogo;
	} else if (imageId == 3) {
		return gentooLogo;
	} else if (imageId == 4) {
		return debianLogo;
	} else if (imageId == 5) {
		return fedoraLogo;
	} else if (imageId == 7) {
		return centosLogo;
	} else if (imageId == 8) {
		return ubuntuLogo;
	} else if (imageId == 9) {
		return archLogo;
	} else if (imageId == 10) {
		return ubuntuLogo;
	} else if (imageId == 11) {
		return ubuntuLogo;
	} else if (imageId == 12) {
		return redhatLogo;
	} else if (imageId == 13) {
		return archLogo;
	} else if (imageId == 4056) {
		return fedoraLogo;
	} else if (imageId == 14362) {
		return ubuntuLogo;
	} else if (imageId == 23) {
		return windowsLogo;
	} else if (imageId == 24) {
		return windowsLogo;
	} else if (imageId == 28) {
		return windowsLogo;
	} else if (imageId == 29) {
		return windowsLogo;
	} else if (imageId == 31) {
		return windowsLogo;
	} else if (imageId == 14) {
		return redhatLogo;
	} else if (imageId == 17) {
		return fedoraLogo;
	} else if (imageId == 19) {
		return gentooLogo;
	} else if (imageId == 14362) {
		return ubuntuLogo;
	} else if (imageId == 187811) {
		return centosLogo;
	} else {

	}
	
	return nil;
}
+(UIImage *)backgroundForImageId:(NSUInteger)imageId {
	if (imageId == 2) {
		return centosBackground;
	} else if (imageId == 3) {
		return gentooBackground;
	} else if (imageId == 4) {
		return debianBackground;
	} else if (imageId == 5) {
		return fedoraBackground;
	} else if (imageId == 7) {
		return centosBackground;
	} else if (imageId == 8) {
		return ubuntuBackground;
	} else if (imageId == 9) {
		return archBackground;
	} else if (imageId == 10) {
		return ubuntuBackground;
	} else if (imageId == 11) {
		return ubuntuBackground;
	} else if (imageId == 12) {
		return redhatBackground;
	} else if (imageId == 13) {
		return archBackground;
	} else if (imageId == 4056) {
		return fedoraBackground;
	} else if (imageId == 14362) {
		return ubuntuBackground;
	} else if (imageId == 23) {
		return windowsBackground;
	} else if (imageId == 24) {
		return windowsBackground;
	} else if (imageId == 28) {
		return windowsBackground;
	} else if (imageId == 29) {
		return windowsBackground;
	} else if (imageId == 31) {
		return windowsBackground;
	} else if (imageId == 14) {
		return redhatBackground;
	} else if (imageId == 17) {
		return fedoraBackground;
	} else if (imageId == 19) {
		return gentooBackground;
	} else if (imageId == 14362) {
		return ubuntuBackground;
	} else if (imageId == 187811) {
		return centosBackground;
	} else {

	}
	
	return nil;
}

+ (id) image {
	ASICloudServersImage *image = [[[self alloc] init] autorelease];
	return image;
}


-(void) dealloc {
	[status release];
	[updated release];
	[name release];
	[super dealloc];
}

@end
