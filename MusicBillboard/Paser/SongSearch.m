//
//  SongSearch.m
//  MusicApp
//
//  Created by administrator on 2009/7/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SongSearch.h"


@implementation SongSearch

@synthesize title,url,keyword;

-(void)dealloc{

	[title release];
	[url release];
	[keyword release];
	[super dealloc];
}

@end
