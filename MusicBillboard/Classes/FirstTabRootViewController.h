//
//  FirstTabRootViewController.h
//  Music01
//
//  Created by albert on 2009/6/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLCacheConnection.h"
#import "URLXmlConnection.h"

@class FirstTabViewController01;
//@class FirstTabViewController01B;
@class avTouchViewController;
@class Music01AppDelegate;
@class FirstTabViewController01C;
@class FirstTabViewController01D;

@interface FirstTabRootViewController : UIViewController  <	UINavigationBarDelegate,UITableViewDelegate,UITableViewDataSource,URLCacheConnectionDelegate,URLXmlConnectionDelegate>
{
	IBOutlet UITableView			*myTableView;
	FirstTabViewController01		*firstTabViewController01;
	//FirstTabViewController01B		*firstTabViewController01B;
	FirstTabViewController01C		*firstTabViewController01C;
	FirstTabViewController01D		*firstTabViewController01D;
	int								selectedSegment;
	NSMutableArray					*myTableSection;
	//NSMutableArray				*mySectionRow00;
	//NSMutableArray				*mySectionRow01;
	//NSMutableArray				*mySectionRow02;
	NSMutableArray					*mySectionRow;

	avTouchViewController			*avController;
	UIColor							*defaultTintColor;
	UIActivityIndicatorView			*activityIndicator;
	
	Music01AppDelegate				*appDelegate;
	
	//for mysong---------------------------------
	UIBarButtonItem *addButton;
	UIBarButtonItem *cancelButton;
	Boolean editor;
	NSMutableDictionary *mySongsDic;
	NSMutableDictionary *tmpSongsDic;
	NSMutableDictionary *tmpRemoveSongsDic;
	NSMutableDictionary *tmpAddSongsDic;
	UISegmentedControl* segmentedControl;
	//--------------------------------------------
	
}
@property (nonatomic, retain) UITableView					*myTableView;
@property (nonatomic, retain) FirstTabViewController01		*firstTabViewController01;
//@property (nonatomic, retain) FirstTabViewController01B	*firstTabViewController01B;
@property (nonatomic, retain) FirstTabViewController01C		*firstTabViewController01C;
@property (nonatomic, retain) FirstTabViewController01D		*firstTabViewController01D;
@property (nonatomic, retain) NSMutableArray				*myTableSection;
@property (nonatomic, retain) NSMutableArray				*mySectionRow;
@property (nonatomic, retain) avTouchViewController			*avController;
@property (nonatomic, retain) UIActivityIndicatorView		*activityIndicator;

-(void)initAppDelegate;
-(void)initDataSource;
-(void) startAnimation;
-(void) stopAnimation;
-(void) cacheImageWithURL:(NSURL *)theURL atIndex:(NSIndexPath *)index;
@end
