//
//  Cd.m
//  MusicApp
//
//  Created by administrator on 2009/6/30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Album.h"


@implementation Album
@synthesize AlbumName,Artist,IssueDate,Publisher,IconURL,ListURL,img_artist;

-(void)delloc{

	[AlbumName release];
	[Artist release];
	[IssueDate release];
	[Publisher release];
	[IconURL release];
	[ListURL release];
	[img_artist release];
	[super dealloc];

}

@end
