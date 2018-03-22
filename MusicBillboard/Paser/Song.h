//
//  song.h
//  XML
//
//  Created by administrator on 2009/6/22.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Song : NSObject {
	NSString *song;
	NSString *singer;
	NSString *cpname;
	NSString *productid;
	//NSString *sourcetype;
	NSString *img_album;	
	NSString *img_artist;
	NSString *wav;
	NSString *price;
	//NSURL *mv;
	//NSString *grade;
	//NSString *past;
}
@property (nonatomic,retain) NSString *song;
@property (nonatomic,retain) NSString *singer;
@property (nonatomic,retain) NSString *cpname;
@property (nonatomic,retain) NSString *productid;
//@property (nonatomic,retain) NSString *sourcetype;
@property (nonatomic,retain) NSString *img_album;
@property (nonatomic,retain) NSString *img_artist;
@property (nonatomic,retain) NSString *wav;
@property (nonatomic,retain) NSString *price;
//@property (nonatomic,retain) NSURL *mv;
//@property (nonatomic,retain) NSString *grade;
//@property (nonatomic,retain) NSString *past;

@end
