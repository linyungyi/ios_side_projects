//
//  CalendarRootViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class ListEventViewController;
@class YearEventViewController;
@class MonthEventViewController;
@class WeekEventViewController;
@class DayEventViewController;




@interface CalendarRootViewController : UIViewController {
	NSInteger whichView;
	UISegmentedControl *segmentedControl;
	//ListEventViewController *listEventViewController;
	YearEventViewController *yearEventViewController;
	MonthEventViewController *monthEventViewController;
	WeekEventViewController *weekEventViewController;
	DayEventViewController *dayEventViewController;
}

@property (nonatomic) NSInteger whichView;
@property (nonatomic,retain) IBOutlet UISegmentedControl *segmentedControl;
//@property (nonatomic,retain) ListEventViewController *listEventViewController;
@property (nonatomic,retain) YearEventViewController *yearEventViewController;
@property (nonatomic,retain) MonthEventViewController *monthEventViewController;
@property (nonatomic,retain) WeekEventViewController *weekEventViewController;
@property (nonatomic,retain) DayEventViewController *dayEventViewController;

//-(IBAction) doList:(id)sender;
-(IBAction) doAdd:(id)sender;
-(IBAction) doSwitch:(id)sender;
-(IBAction) toToday:(id)sender;
-(void) changeView:(NSInteger) from toView:(NSInteger)to;

@end
