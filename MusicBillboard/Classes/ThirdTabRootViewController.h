//
//  ThirdTabRootViewController.h
//  Music01
//
//  Created by albert on 2009/6/22.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"
#import "URLXmlConnection.h"

@class ThirdTabViewController01;
@class Music01AppDelegate;
@class ThirdTabViewController01B;

@interface ThirdTabRootViewController : UIViewController <UINavigationBarDelegate,UITableViewDelegate,UITableViewDataSource,URLCacheConnectionDelegate,URLXmlConnectionDelegate>{
	IBOutlet UITableView			*myTableView;
	ThirdTabViewController01		*thirdTabViewController01;
	ThirdTabViewController01B		*thirdTabViewController01B;
	NSMutableArray					*myTableSection;
	NSMutableArray					*mySectionRow;
	Music01AppDelegate				*appDelegate;
	UIActivityIndicatorView			*activityIndicator;
	NSData							*xmlData;
}

@property (nonatomic, retain) UITableView					*myTableView;
@property (nonatomic, retain) ThirdTabViewController01		*thirdTabViewController01;
@property (nonatomic, retain) ThirdTabViewController01B		*thirdTabViewController01B;
@property (nonatomic, retain) NSMutableArray				*myTableSection;
@property (nonatomic, retain) NSMutableArray				*mySectionRow;
@property (nonatomic, retain) UIActivityIndicatorView		*activityIndicator;
@property (nonatomic, retain) NSData						*xmlData;

-(void)initDataSource;
-(void)initAppDelegate;
-(void) startAnimation;
-(void) stopAnimation;
-(void) cacheImageWithURL:(NSURL *)theURL atIndex:(NSIndexPath *)index;
-(void)showResult;
@end
