//
//  DayTableView.h
//  MyCalendar
//
//  Created by app on 2010/3/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DayEventViewController.h";
#import "EventDetailViewController.h";
#import "CalendarRootViewController.h"


@interface DayTableView : UITableView<UITableViewDelegate,UITableViewDataSource> {
	NSMutableArray *eventArray;
	CalendarRootViewController *calendarRootViewController;
	

}
@property (nonatomic,retain) NSMutableArray *eventArray;
@property (nonatomic,retain) CalendarRootViewController *calendarRootViewController;

- (UIImage *) createFolderImage:(CGSize) mySize bgColor:(NSInteger) myColor;
@end
