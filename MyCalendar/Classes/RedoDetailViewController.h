//
//  RedoDetailViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TodoEvent;

@interface RedoDetailViewController : UITableViewController {
	NSArray *redoDatas;
	NSArray *todoEvent;
}
@property (nonatomic, retain) NSArray *redoDatas;
@property (nonatomic, retain) NSArray *todoEvent;
//- (id)initWithRedoArray:(NSArray *)myArray nib:(NSString *)nibNameOrNil;
@end
