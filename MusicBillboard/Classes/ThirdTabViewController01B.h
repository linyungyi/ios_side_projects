//
//  ThirdTabViewContorller01B.h
//  Music01
//
//  Created by bko on 2009/8/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"

@class Music01AppDelegate,avTouchViewController,DetailAlert;

@interface ThirdTabViewController01B : UIViewController <UITableViewDataSource,UITableViewDelegate,URLCacheConnectionDelegate>{
	IBOutlet UITableView			*songsTableView;
	IBOutlet UILabel				*contentLabel;
	//IBOutlet UILabel				*dateLabel;
	IBOutlet UIImageView			*picView;
	NSMutableArray					*mySectionRow;
	NSDictionary					*activityDictionary;	
	avTouchViewController			*avController;
	Music01AppDelegate				*appDelegate;
	NSData							*xmlData;
	UIActivityIndicatorView			*activityIndicator;
	//UILabel *infoTitle,				*message;
	DetailAlert						*detailView;
	Boolean							clicked;
	
}
@property (nonatomic,retain) UITableView				*songsTableView;
@property(nonatomic,retain) UILabel						*contentLabel;
//@property(nonatomic,retain) UILabel						*dateLabel;
@property(nonatomic,retain) UIImageView					*picView;
@property(nonatomic,retain) NSMutableArray				*mySectionRow;
@property(nonatomic,retain) NSDictionary				*activityDictionary;
@property(nonatomic,retain) avTouchViewController		*avController;
@property(nonatomic,retain) Music01AppDelegate			*appDelegate;
@property (nonatomic, retain) NSData					*xmlData;
@property (nonatomic, retain) UIActivityIndicatorView	*activityIndicator;

-(void)initAppDelegate;
-(void)initDataSource;
-(void)initActivityInfo;
-(void)setData:(NSData *)theData;
-(void) startAnimation;
-(void) stopAnimation;
-(void) cacheImageWithURL:(NSURL *)theURL atIndex:(NSIndexPath *)index;
-(void) showInfo:(id)sender;
@end
