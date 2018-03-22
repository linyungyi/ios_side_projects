//
//  WeekEventViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIView.h"
@class CalendarRootViewController;

@interface WeekEventViewController : UIViewController {
	NSInteger theDay;
	MyUIView *contentView;
	UILabel *headerTitleLabel;
	CalendarRootViewController *calendarRootViewController;
	NSDate *now;
	NSMutableArray *tableArray;
	NSMutableDictionary *dictionary;
}

@property (nonatomic) NSInteger theDay;
@property (nonatomic,retain) MyUIView *contentView;
@property (nonatomic,retain) CalendarRootViewController *calendarRootViewController;
@property (nonatomic,retain) NSMutableArray *tableArray;
@property (nonatomic,retain) NSDate *now;
@property (nonatomic,retain) NSMutableDictionary *dictionary;

- (void) addSubviewsToHeaderView:(UIView *)headerView;
- (void) refreshViewWithPushDirection:(NSInteger) type;
- (void) clearAndDrawTable;
- (void) showPreviousWeek;
- (void) showFollowingWeek;
@end
