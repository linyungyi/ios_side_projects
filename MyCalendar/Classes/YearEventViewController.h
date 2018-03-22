//
//  YearEventViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIView.h"

@class CalendarRootViewController;

@interface YearEventViewController : UIViewController {
	NSInteger theDay;
	NSInteger year;
	MyUIView *contentView;
	UILabel *headerTitleLabel;
	NSMutableArray *tileArray;
	NSDate *now;
	CalendarRootViewController *calendarRootViewController;
}

@property (nonatomic) NSInteger theDay;
@property (nonatomic) NSInteger year;
@property (nonatomic,retain) MyUIView *contentView;
@property (nonatomic,retain) CalendarRootViewController *calendarRootViewController;
@property (nonatomic,retain) NSDate *now;

- (void)addSubviewsToHeaderView:(UIView *)headerView;
- (void) clearAndDrawTile;
- (void) refreshViewWithPushDirection:(NSInteger) type;
- (void) showPreviousMonth;
- (void) showFollowingMonth;

@end
