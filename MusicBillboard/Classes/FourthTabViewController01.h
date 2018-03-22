//
//  FourthTabViewController01.h
//  Music01
//
//  Created by albert on 2009/6/29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"

@class avTouchViewController;
@class Music01AppDelegate;

@interface FourthTabViewController01 : UIViewController <UITableViewDelegate,UITableViewDataSource,URLCacheConnectionDelegate>{
	IBOutlet UITableView			*myTableView;
	NSMutableArray					*myTableSection;
	NSMutableArray					*mySectionRow;
	NSString						*myQuery;
	Music01AppDelegate				*appDelegate;
	
	avTouchViewController			*avController;
	
	NSData							*xmlData;
	NSArray							*songsArray;
	
}
@property (nonatomic, retain) UITableView				*myTableView;
@property (nonatomic, retain) NSMutableArray			*myTableSection;
@property (nonatomic, retain) NSMutableArray			*mySectionRow;
@property (nonatomic, retain) avTouchViewController		*avController;
@property (nonatomic, retain) NSString					*myQuery;
@property (nonatomic, retain) Music01AppDelegate		*appDelegate;
@property (nonatomic, retain) NSData					*xmlData;
@property (nonatomic, retain) NSArray					*songsArray;
-(void)initDataSource;
-(void)initAppDelegate;
-(void)setData:(NSData *)theData;
-(void) cacheImageWithURL:(NSURL *)theURL atIndex:(NSIndexPath *)index;
@end
