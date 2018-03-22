//
//  FirstTabViewController01C.h
//  Music01
//
//  Created by bko on 2009/8/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"

@class avTouchViewController,Music01AppDelegate;

@interface FirstTabViewController01C : UIViewController <UITableViewDelegate,UITableViewDataSource,URLCacheConnectionDelegate>{
	
	IBOutlet UITableView		*songsTableView;
	IBOutlet UILabel			*albumNameLabel;
	IBOutlet UILabel			*dateLabel;
	IBOutlet UILabel			*artistLabel;
	IBOutlet UIImageView		*albumPicView;
	NSMutableArray				*mySectionRow;
	NSDictionary				*albumDictionary;	
	avTouchViewController		*avController;
	Music01AppDelegate			*appDelegate;
	NSMutableData				*xmlData;
}

@property (nonatomic,retain)	UITableView				*songsTableView;
@property(nonatomic,retain)		UILabel					*albumNameLabel;
@property(nonatomic,retain)		UILabel					*dateLabel;
@property(nonatomic,retain)		UILabel					*artistLabel;
@property(nonatomic,retain)		UIImageView				*albumPicView;
@property(nonatomic,retain)		NSMutableArray			*mySectionRow;
@property(nonatomic,retain)		avTouchViewController	*avController;
@property(nonatomic,retain)		Music01AppDelegate		*appDelegate;
@property(nonatomic,retain)		NSDictionary			*albumDictionary;
@property (nonatomic, retain)	NSMutableData			*xmlData;

-(void)initAppDelegate;
-(void)initDataSource;
-(void)initAlbumInfo;
-(void) cacheImageWithURL:(NSURL *)theURL atIndex:(NSIndexPath *)index;
-(void)setData:(NSMutableData *)theData;

@end
