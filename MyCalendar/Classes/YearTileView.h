//
//  YearTileView.h
//  MyCalendar
//
//  Created by app on 2010/3/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarRootViewController.h"

@interface YearTileView : UIControl {
	NSInteger days;
	NSInteger first;
	NSInteger yearMonth;
	NSInteger year;
	NSInteger month;
	NSMutableArray *colorCtrl;
	NSString *title;
	MonthEventViewController *viewController;
	NSString *text;
	int colors[32];
	CalendarRootViewController *calendarRootViewController;

	
}
@property(nonatomic, retain) NSString *title;
@property(nonatomic) NSInteger days;
@property(nonatomic) NSInteger first;
@property(nonatomic) NSInteger yearMonth;
@property(nonatomic) NSInteger year;
@property(nonatomic) NSInteger month;
@property(nonatomic, retain) NSMutableArray *colorCtrl;
@property(assign) MonthEventViewController *viewController;
@property(nonatomic, retain) NSString *text;
@property (nonatomic,retain) CalendarRootViewController *calendarRootViewController;


- (void)drawTextInContext:(CGContextRef)ctx;
- (void)setColors:(int) index value:(int)value;
-(void) setRootViewController:(id)root;

@end
