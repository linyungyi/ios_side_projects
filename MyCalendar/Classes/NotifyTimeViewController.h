//
//  NotifyTimeViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/4/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NotifyTimeViewController : UITableViewController {
	NSArray *tableDatas;
	NSArray *todoEvent;

}

@property (nonatomic, retain) NSArray *tableDatas;
@property (nonatomic, retain) NSArray *todoEvent;

@end
