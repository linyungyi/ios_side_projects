//
//  MySongsViewController.h
//  Music01
//
//  Created by bko on 2009/8/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Music01AppDelegate;
@class avTouchViewController;
@class XMLParser;
@interface MySongsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,URLXmlConnectionDelegate,URLCacheConnectionDelegate>{

	IBOutlet UITableView			*mysongTableView;
	NSDictionary					*mysongDic;	
	NSMutableArray					*mySectionRow;	
	avTouchViewController			*avController;
	Music01AppDelegate				*appDelegate;
	NSData							*xmlData;
	UIActivityIndicatorView			*activityIndicator;
	UIBarButtonItem					*uploadButton;
	Boolean							addfinish;
	Boolean							deletefinish;
	
}
@property (nonatomic,retain) UITableView				*mysongTableView;
@property(nonatomic,retain) NSMutableArray				*mySectionRow;
@property(nonatomic,retain) NSDictionary				*mysongDic;
@property(nonatomic,retain) avTouchViewController		*avController;
@property(nonatomic,retain) Music01AppDelegate			*appDelegate;
@property (nonatomic, retain) NSData					*xmlData;
@property (nonatomic, retain) UIActivityIndicatorView	*activityIndicator;


-(void)initAppDelegate;
-(void)initDataSource:(NSArray *) tArray;
-(void)viewWillAppear:(BOOL)animated;
-(void) startAnimation;
-(void) stopAnimation;
-(void) cacheImageWithURL:(NSURL *)theURL atIndex:(NSIndexPath *)index;
-(void) synMySong:(id)sender;
-(NSArray *) parseXml:(NSData *) data;




@end
