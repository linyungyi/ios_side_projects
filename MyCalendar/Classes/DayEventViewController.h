//
//  DayEventViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIView.h"
@class CalendarRootViewController;

@interface DayEventViewController : UIViewController<UIScrollViewDelegate> {
//@interface DayEventViewController : UIViewController <UIScrollViewDelegate>	{
	NSInteger year;
	NSInteger month;
	NSInteger day;
	NSInteger theDay;
	MyUIView *contentView;
	UILabel *headerTitleLabel;
	CalendarRootViewController *calendarRootViewController;
	NSDate *now;
	NSMutableArray *dataArray;
	NSMutableDictionary *dictionary;
	UIScrollView *sv;
	NSMutableArray *labelArray;
	NSMutableArray *touchViewArray;
	UIView *allDayEventView;
	NSMutableArray *allDayEventArray;
}

@property (nonatomic) NSInteger theDay;
@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger day;
@property (nonatomic) NSInteger month;
@property (nonatomic,retain) MyUIView *contentView;
@property (nonatomic,retain) CalendarRootViewController *calendarRootViewController;
@property (nonatomic,retain) NSDate *now;
@property (nonatomic,retain) NSMutableArray *dataArray;
@property (nonatomic,retain) NSMutableDictionary *dictionary;
@property (nonatomic,retain) UIScrollView *sv;
@property (nonatomic,retain) NSMutableArray *labelArray;
@property (nonatomic,retain) NSMutableArray *touchViewArray;
@property (nonatomic,retain) UIView *allDayEventView;
@property (nonatomic,retain) NSMutableArray *allDayEventArray;

- (void)addSubviewsToHeaderView:(UIView *)headerView;
- (void) showPreviousDay;
- (void) showFollowingDay;
- (void) refreshViewWithPushDirection:(NSInteger) type;
- (void) fromWeekViewToDayViewForYear:(NSInteger)iYear Month:(NSInteger)iMonth Day:(NSInteger)iDay;
- (void) clearAndDraw;

@end
