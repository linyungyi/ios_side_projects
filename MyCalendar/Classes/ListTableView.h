//
//  ListTableView.h
//  MyCalendar
//
//  Created by app on 2010/5/4.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarRootViewController.h"

@interface ListTableView : UITableView<UITableViewDelegate,UITableViewDataSource> {
	NSArray *data;
	
	//CalendarRootViewController *calendarRootViewController;
	UIViewController *calendarRootViewController;

}
@property (nonatomic,retain) NSArray *data;
//@property (nonatomic,retain) CalendarRootViewController *calendarRootViewController;
@property (nonatomic,retain) UIViewController *calendarRootViewController;


- (id)initWithFrame:(CGRect)frame style:(NSInteger) s;
- (UIImage *) createFolderImage:(CGSize) mySize bgColor:(NSInteger) myColor	;
@end
