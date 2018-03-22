//
//  Tile.h
//  MyCalendar
//
//  Created by app on 2010/3/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MonthEventViewController;

@interface Tile : UIControl {
	NSString *_text;
	NSInteger isToday;
	NSInteger isWeekend;
	NSInteger hasEvent;
	MonthEventViewController *viewController;
	NSString *key;
	UIImageView *selectedView;
	BOOL revealLunarCalendar;
	UIColor *textColor;
}
@property(nonatomic, retain) NSString *text;
@property(nonatomic) NSInteger isToday;
@property(nonatomic) NSInteger hasEvent;
@property(nonatomic) NSInteger isWeekend;
@property(assign) MonthEventViewController *viewController;
@property(nonatomic, retain) NSString *key;
@property(nonatomic, retain) UIImageView *selectedView;
@property(nonatomic) BOOL revealLunarCalendar;
@property(nonatomic,retain) UIColor *textColor;

- (void)drawTextInContext:(CGContextRef)ctx;
- (void)drawLunarTextInContext:(CGContextRef)ctx;
- (void) showSelectedView;
- (void) removeSelectedView;
@end
