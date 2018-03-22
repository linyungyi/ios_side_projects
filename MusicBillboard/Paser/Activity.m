//
//  Activity.m
//  MusicApp
//
//  Created by administrator on 2009/6/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Activity.h"



@implementation Activity

@synthesize beginDate,endDate,content,name,img,url;

-(void) dealloc{
	[beginDate release];
	[endDate release];
	[content release];
	[name release];
	[img release];
	[url release];
	[super dealloc];
}


@end
