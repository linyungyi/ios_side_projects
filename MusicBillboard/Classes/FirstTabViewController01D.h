//
//  FirstTabViewController01D.h
//  Music01
//
//  Created by bko on 2009/8/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"

@class avTouchViewController,Music01AppDelegate;

@interface FirstTabViewController01D : UIViewController <UITableViewDataSource,UITableViewDelegate,URLCacheConnectionDelegate>{

	IBOutlet UITableView	*songsTableView;
	IBOutlet UILabel		*contentLabel;
	IBOutlet UIImageView	*picView;
	NSMutableArray			*mySectionRow;
	NSDictionary			*musicBoxDictionary;	
	avTouchViewController		*avController;
	Music01AppDelegate			*appDelegate;
	NSMutableData						*xmlData;
}
@property (nonatomic,retain) UITableView *songsTableView;
@property(nonatomic,retain) UILabel *contentLabel;
@property(nonatomic,retain) UIImageView *picView;
@property(nonatomic,retain) NSMutableArray *mySectionRow;
@property(nonatomic,retain) NSDictionary	   *musicBoxDictionary;
@property(nonatomic,retain) avTouchViewController *avController;
@property(nonatomic,retain) Music01AppDelegate *appDelegate;
@property (nonatomic, retain) NSMutableData					*xmlData;


-(void)initAppDelegate;
-(void)initDataSource;
-(void)initMusicBoxInfo;
-(void) cacheImageWithURL:(NSURL *)theURL atIndex:(NSIndexPath *)index;
-(void)setData:(NSMutableData *)theData;
@end
