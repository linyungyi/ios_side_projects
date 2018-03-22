//
//  Music01AppDelegate.h
//  Music01
//
//  Created by albert on 2009/6/17.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Music01AppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
    UIWindow				*window;
	UITabBarController		*tabBarController;
	
	NSMutableDictionary		*imgCacheDictionary;
	NSMutableArray			*WSArray;
	
	NSArray					*singleList;
	NSArray					*cdList;
	NSArray					*musicboxList;
	NSArray					*rTotalList;
	NSArray					*rMaleList;
	NSArray					*rFemaleList;
	NSArray					*rGroupList;
	NSArray					*rTaiwanList;
	NSArray					*rJapanList;
	NSArray					*rWesternList;
	NSArray					*rMoodList;
	NSArray					*activityList;
	NSDictionary			*userProfile;
	
	NSMutableDictionary		*searchTopicList;
	NSMutableDictionary		*cdSongsList;
	NSMutableDictionary		*musicboxSongsList;
	NSMutableDictionary		*activitySongList;
	
	NSString				*dataPath;
	NSError					*error;
	NSString				*rbtMember;
	NSString				*mediaPlayerPath;
	
	//mysong----------------------------
	NSMutableDictionary     *playlistDic;
	NSMutableDictionary		*serverlistDic;
	//----------------------------------
}

@property (nonatomic, retain)IBOutlet	UIWindow				*window;
@property (nonatomic, retain)IBOutlet	UITabBarController		*tabBarController;
@property (nonatomic, retain)			NSMutableDictionary		*imgCacheDictionary;
@property (nonatomic, copy)				NSString				*dataPath;
@property (nonatomic, retain)			NSMutableArray			*WSArray;
@property (nonatomic,retain)			NSArray					*singleList;
@property (nonatomic,retain)			NSArray					*cdList;
@property (nonatomic,retain)			NSArray					*musicboxList;
@property (nonatomic, retain)			NSArray					*rTotalList;
@property (nonatomic, retain)			NSArray					*rMaleList;
@property (nonatomic, retain)			NSArray					*rFemaleList;
@property (nonatomic, retain)			NSArray					*rGroupList;
@property (nonatomic, retain)			NSArray					*rTaiwanList;
@property (nonatomic, retain)			NSArray					*rJapanList;
@property (nonatomic, retain)			NSArray					*rWesternList;
@property (nonatomic, retain)			NSArray					*rMoodList;
@property (nonatomic, retain)			NSArray					*activityList;
@property (nonatomic, retain)			NSDictionary			*userProfile;

@property (nonatomic, retain)			NSMutableDictionary		*searchTopicList;
@property (nonatomic, retain)			NSMutableDictionary		*cdSongsList;
@property (nonatomic, retain)			NSMutableDictionary		*musicboxSongsList;
@property (nonatomic, retain)			NSMutableDictionary		*activitySongList;

@property (nonatomic, retain)			NSString				*rbtMember;
@property (nonatomic, retain)			NSString				*mediaPlayerPath;

//for mysong------
@property (nonatomic, retain)			NSMutableDictionary		*playlistDic;
@property (nonatomic,retain)			NSMutableDictionary		*serverlistDic;
//----------------

-(void)initApp;
-(void)initDataSource:(int)forKey orLink:(NSString *)strLink withData:(NSData *)theData;
-(BOOL)imgExistsAtCache:(NSString *)imgFile;
-(void) initPlayerCache;
-(void) clearPlayerCache;

//修改for接Parser第三層
//-(NSArray *)initSongsDataSource:(NSString *)strLink;
@end

