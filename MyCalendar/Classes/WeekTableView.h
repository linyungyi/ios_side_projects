//
//  WeekTableView.h
//  MyCalendar
//
//  Created by app on 2010/3/18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarRootViewController.h"

@interface WeekTableView : UITableView<UITableViewDelegate,UITableViewDataSource>  {
	NSMutableArray *eventArray;
	NSString *title;
	CalendarRootViewController *calendarRootViewController;
	NSInteger year;
	NSInteger month;
	NSInteger day;
	NSInteger weekday;
}

@property (nonatomic,retain) NSMutableArray *eventArray;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) CalendarRootViewController *calendarRootViewController;
@property (nonatomic) NSInteger month;
@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger day;
@property (nonatomic) NSInteger weekday;


- (UIImage *) createFolderImage:(CGSize) mySize bgColor:(NSInteger) myColor;


@end
