//
//  song.m
//  XML
//
//  Created by administrator on 2009/6/22.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Song.h"


@implementation Song

@synthesize song,singer,cpname,productid,img_album,img_artist,wav,price;

-(void) dealloc{
	[song release];
	[singer release];
	[productid release];
	//[sourcetype release];
	[img_album release];
	[img_artist release];
	[wav release];
	//[mv release];
	[cpname release];
	[super dealloc];
}
@end
