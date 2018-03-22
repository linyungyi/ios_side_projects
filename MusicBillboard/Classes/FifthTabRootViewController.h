//
//  FifthTabRootViewController.h
//  Music01
//
//  Created by albert on 2009/6/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"
#import "URLXmlConnection.h"

@class Music01AppDelegate;

@interface FifthTabRootViewController : UIViewController <UINavigationBarDelegate,UITableViewDelegate,UITableViewDataSource,URLCacheConnectionDelegate,URLXmlConnectionDelegate>{
	IBOutlet UITableView				*myTableView;
	NSMutableArray						*myTableSection;
	NSMutableArray						*mySectionRow;
	Music01AppDelegate					*appDelegate;
	NSDictionary						*titleMap;
	UIActivityIndicatorView				*activityIndicator;
	NSData								*xmlData;
	NSDictionary						*ruleMap;
}
@property (nonatomic, retain) UITableView					*myTableView;
@property (nonatomic, retain) NSMutableArray				*myTableSection;
@property (nonatomic, retain) NSMutableArray				*mySectionRow;
@property (nonatomic, retain) NSDictionary					*titleMap;
@property (nonatomic, retain) UIActivityIndicatorView		*activityIndicator;
@property (nonatomic, retain) NSData						*xmlData;
@property (nonatomic, retain) NSDictionary					*ruleMap;

-(void)initDataSource;
-(void)initAppDelegate;
-(void) startAnimation;
-(void) stopAnimation;
-(void) cacheImageWithURL:(NSURL *)theURL atIndex:(NSIndexPath *)index;
-(void)showResult;

@end
