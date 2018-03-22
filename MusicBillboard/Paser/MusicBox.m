//
//  MusicBox.m
//  MusicApp
//
//  Created by administrator on 2009/6/30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MusicBox.h"


@implementation MusicBox
@synthesize MUSICBOXID,MUSICBOXNAME,PRICE,CONTENTSHORT,CPNAME,BigIcon,SmallIcon,ListURL;

-(void) dealloc{
	[MUSICBOXID release];
	[MUSICBOXNAME release];
	[PRICE release];
	[CONTENTSHORT release];
	[CPNAME release];
	[BigIcon release];
	[SmallIcon release];
	[ListURL release];
	[super dealloc];
}

@end
