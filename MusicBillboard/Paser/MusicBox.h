//
//  MusicBox.h
//  MusicApp
//
//  Created by administrator on 2009/6/30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MusicBox : NSObject {

	NSString *MUSICBOXID;
	NSString *MUSICBOXNAME;
	NSString *PRICE;
	NSString *CONTENTSHORT;
	NSString *CPNAME;
	NSString *BigIcon;
	NSString *SmallIcon;
	NSString *ListURL;
	
}
@property (nonatomic,retain) NSString *MUSICBOXID;
@property (nonatomic,retain) NSString *MUSICBOXNAME;
@property (nonatomic,retain) NSString *PRICE;
@property (nonatomic,retain) NSString *CONTENTSHORT;
@property (nonatomic,retain) NSString *CPNAME;
@property (nonatomic,retain) NSString *BigIcon;
@property (nonatomic,retain) NSString *SmallIcon;
@property (nonatomic,retain) NSString *ListURL;



@end
