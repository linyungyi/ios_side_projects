//
//  Cd.h
//  MusicApp
//
//  Created by administrator on 2009/6/30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Album : NSObject {

	NSString *AlbumName;	
	NSString *Artist;
	NSString *IssueDate;
	NSString *Publisher;
	NSString *img_artist;
	NSString *IconURL;	
	NSString *ListURL;
}

@property (nonatomic,retain) NSString *AlbumName;
@property (nonatomic,retain) NSString *img_artist;
@property (nonatomic,retain) NSString *Artist;
@property (nonatomic,retain) NSString *IssueDate;
@property (nonatomic,retain) NSString *Publisher;
@property (nonatomic,retain) NSString *IconURL;
@property (nonatomic,retain) NSString *ListURL;


@end
