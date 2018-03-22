//
//  SongSearch.h
//  MusicApp
//
//  Created by administrator on 2009/7/8.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SongSearch : NSObject {
	
	NSString *title;
	NSString *url;
	NSString *keyword;

}

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *url;
@property (nonatomic,retain) NSString *keyword;

@end
