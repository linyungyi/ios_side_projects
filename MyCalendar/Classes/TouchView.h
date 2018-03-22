//
//  TouchView.h
//  MyCalendar
//
//  Created by yves ho on 2010/3/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListTodoEvent.h"
#import "CalendarRootViewController.h"

@interface TouchView : UIImageView {
	CalendarRootViewController *calendarRootViewController;
	ListTodoEvent *listTodoEvent;
	//NSString *title;
}
@property (nonatomic,retain) CalendarRootViewController *calendarRootViewController;
@property (nonatomic,retain) ListTodoEvent *listTodoEvent;
//@property (nonatomic,retain) NSString *title;
@end
