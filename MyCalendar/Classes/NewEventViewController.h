//
//  NewEventViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TodoEvent;
@class TodoCategory;
@class EventRecurrence;
@class CategoryTableViewController;
@class RedoDetailViewController;
@class EventDateViewController;
@class EventTimeViewController;

@interface NewEventViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource> {
	TodoEvent *todoEvent;
	TodoCategory *todoCategory;
	EventRecurrence *eventRecurrence;
	
	//UITextField *eventSubject;
	//UITextField *eventDesc;
	//UITextField *eventMemo;
	UITableView *myTableView;
	
	NSMutableArray *tableArray;
	//NSArray *redoArray;
	NSInteger fromFlag;
}

@property (nonatomic,retain) TodoEvent *todoEvent;
@property (nonatomic,retain) TodoCategory *todoCategory;
@property (nonatomic,retain) EventRecurrence *eventRecurrence;
@property (nonatomic,retain) NSMutableArray *tableArray;
//@property (nonatomic,retain) IBOutlet UITextField *eventSubject;
//@property (nonatomic,retain) IBOutlet UITextField *eventDesc;
//@property (nonatomic,retain) IBOutlet UITextField *eventMemo;
@property (nonatomic,retain) IBOutlet UITableView *myTableView;
//@property (nonatomic,retain) NSArray *redoArray;
@property NSInteger fromFlag;

-(id)initWithEventId:(NSString *)cId nib:(NSString *)nibNameOrNil;
-(IBAction) doJob:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil dateString:(NSString *)now;

/*
-(NSDateComponents *) getDateFromLong:(NSUInteger) myDatetime;
-(NSDateComponents *) getDateFromString:(NSString *) myDatetime;
*/

-(void) initNewTodoEvent:(NSString *)now;
-(void) resetTableDatas;
-(void) editTodoEvent:(NSString *)cId;

@end
