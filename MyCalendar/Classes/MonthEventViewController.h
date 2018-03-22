//
//  MonthEventViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIView.h"

@class CalendarRootViewController;
@class Tile;
//#import "CalendarRootViewController.h"
/*
typedef enum  {
	S0,
	S1
} STATE;
*/
@interface MonthEventViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	NSInteger theDay;
	NSInteger year;
	NSInteger month;
	MyUIView *contentView;
	UITableView *myTableView;
	UIImageView *myCalendarBg;
	UILabel *headerTitleLabel;
	NSMutableArray *tileArray;
	NSDate *now;
	NSDate *today;
	NSCalendar *cal;
	CalendarRootViewController *calendarRootViewController;
	NSMutableDictionary *dictionary;
	NSString *dictionaryKey;
	Tile *selectedTile;
}

@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger month;
@property (nonatomic) NSInteger theDay;
@property (nonatomic,retain) MyUIView *contentView;
@property (nonatomic,retain) IBOutlet UITableView *myTableView;
@property (nonatomic,retain) UIImageView *myCalendarBg;
@property (nonatomic,retain) NSDate *now;
@property (nonatomic,retain) NSCalendar *cal;
@property (nonatomic,retain) NSDate *today;
@property (nonatomic,retain) NSMutableDictionary *dictionary;
@property (nonatomic,retain) NSString *dictionaryKey;
@property (nonatomic,retain) CalendarRootViewController *calendarRootViewController;

- (void) addSubviewsToHeaderView:(UIView *)headerView;
- (void) refreshViewWithPushDirection:(NSInteger) type;
- (void) clearAndDrawTile;
- (void)fromYearViewToMonthView:(NSInteger)iYear month:(NSInteger)iMonth;
- (void) refreshTableView:(NSString *) iKey;
- (UIImage *) createFolderImage:(CGSize) mySize bgColor:(NSInteger) myColor;
- (void) setSelectedTile:(Tile *) t key:(NSString *) iKey;

@end
