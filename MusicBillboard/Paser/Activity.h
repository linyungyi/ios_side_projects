//
//  Activity.h
//  MusicApp
//
//  Created by administrator on 2009/6/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Activity : NSObject {
	NSString *beginDate;
	NSString *endDate;
	NSString *content;
	NSString *name;
	NSString *img;
	NSString *url;
}

@property (nonatomic,retain) NSString *beginDate;
@property (nonatomic,retain) NSString *endDate;
@property (nonatomic,retain) NSString *content;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *img;
@property (nonatomic,retain) NSString *url;

@end
