//
//  SecondTabRootViewController.h
//  Music01
//
//  Created by albert on 2009/6/18.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLXmlConnection.h"

@class SecondTabViewController01;
@class Music01AppDelegate;

@interface SecondTabRootViewController : UIViewController <UINavigationBarDelegate,UITableViewDelegate,UITableViewDataSource,URLXmlConnectionDelegate>{
	IBOutlet UITableView				*myTableView;
	SecondTabViewController01			*secondTabViewController01;
	NSMutableArray						*myTableSection;
	NSMutableArray						*mySectionRow;
	UIActivityIndicatorView				*activityIndicator;
	Music01AppDelegate					*appDelegate;

}

@property (nonatomic, retain) UITableView					*myTableView;
@property (nonatomic, retain) SecondTabViewController01		*secondTabViewController01;
@property (nonatomic, retain) NSMutableArray				*myTableSection;
@property (nonatomic, retain) NSMutableArray				*mySectionRow;
@property (nonatomic, retain) UIActivityIndicatorView		*activityIndicator;

-(void)initAppDelegate;
-(void)initDataSource;
-(void) startAnimation;
-(void) stopAnimation;
@end
