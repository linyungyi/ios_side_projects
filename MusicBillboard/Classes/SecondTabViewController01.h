//
//  SecondTabViewController01.h
//  Music01
//
//  Created by albert on 2009/6/18.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"

@class avTouchViewController;
@class Music01AppDelegate;

@interface SecondTabViewController01 : UIViewController <UITableViewDelegate,UITableViewDataSource,URLCacheConnectionDelegate>{
	IBOutlet UITableView		*myTableView;
	NSMutableArray				*myTableSection;
	NSMutableArray				*mySectionRow;
	NSInteger					categoryId;
	avTouchViewController		*avController;
	Music01AppDelegate			*appDelegate;
	NSData						*xmlData;
	NSMutableArray				*arrayData;
}
@property (nonatomic, retain) UITableView				*myTableView;
@property (nonatomic, retain) NSMutableArray			*myTableSection;
@property (nonatomic, retain) NSMutableArray			*mySectionRow;
@property (nonatomic, retain) avTouchViewController		*avController;
@property (nonatomic, retain) NSData					*xmlData;
@property (nonatomic, retain) NSMutableArray			*arrayData;

-(void)initDataSource;
-(void)setCategoryId:(NSInteger)theCategoryid;
-(void)initAppDelegate;
-(void) cacheImageWithURL:(NSURL *)theURL atIndex:(NSIndexPath *)index;
-(void)setData:(NSData *)theData;
@end
