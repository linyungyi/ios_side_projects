//
//  EventDetailViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListTodoEvent.h"
@class TodoEvent;
@class TodoCategory;
@class EventRecurrence;

@interface EventDetailViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate> {
	TodoEvent *todoEvent;
	//ListTodoEvent *listTodoEvent;
	TodoCategory *todoCategory;
	EventRecurrence *eventRecurrence;
	UITableView *myTableView;
	NSMutableArray *tableArray;
	NSArray *redoArray;
	NSString *eId;
	NSString *sId;
	BOOL flag;
}

@property (nonatomic,retain) TodoEvent *todoEvent;
@property (nonatomic,retain) TodoCategory *todoCategory;
@property (nonatomic,retain) EventRecurrence *eventRecurrence;
@property (nonatomic,retain) NSMutableArray *tableArray;
@property (nonatomic,retain) IBOutlet UITableView *myTableView;
@property (nonatomic,retain) NSArray *redoArray;
//@property (nonatomic,retain) ListTodoEvent *listTodoEvent;
@property (nonatomic,retain) NSString *eId;
@property (nonatomic,retain) NSString *sId;
@property (nonatomic) BOOL flag;


//-(id)initWithEvent:(TodoEvent *)myEvent nib:(NSString *)nibNameOrNil;
//-(id)initWithListTodoEvent:(ListTodoEvent *)myEvent nib:(NSString *)nibNameOrNil;
-(void) doJob:(id)sender;
-(IBAction) doDel:(id)sender;
/*
-(NSDateComponents *) getDateFromLong:(NSUInteger) myDatetime;
-(NSDateComponents *) getDateFromString:(NSString *) myDatetime;
*/
@end
