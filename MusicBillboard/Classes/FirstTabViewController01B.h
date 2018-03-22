//
//  FirstTabViewController01B.h
//  Music01
//
//  Created by albert on 2009/7/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class avTouchViewController;
@class Music01AppDelegate;

@interface FirstTabViewController01B : UIViewController {
	IBOutlet UITableView		*myTableView;
	NSMutableArray				*myTableSection;
	NSMutableArray				*mySectionRow;
	NSMutableDictionary			*myDictionary;
	avTouchViewController		*avController;
	Music01AppDelegate			*appDelegate;
}

@property (nonatomic, retain) UITableView				*myTableView;
@property (nonatomic, retain) NSMutableArray			*myTableSection;
@property (nonatomic, retain) NSMutableArray			*mySectionRow;
@property (nonatomic, retain) avTouchViewController		*avController;

-(void)initDataSource;
-(void)initAppDelegate;
-(void)setDictionary:(NSMutableDictionary *)theDictionary;

@end
