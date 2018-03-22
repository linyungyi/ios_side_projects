//
//  RedoDateViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RedoDateViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
	UIDatePicker *datePicker;
	UITableView *myTableView;
	NSInteger flag;
	NSArray *todoEvent;
	NSMutableArray *tableDatas;
}

@property (nonatomic,retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic,retain) IBOutlet UITableView *myTableView;
@property (nonatomic) NSInteger flag;
@property (nonatomic, retain) NSArray *todoEvent;
@property (nonatomic, retain) NSMutableArray *tableDatas; 

-(IBAction) doJob:(id)sender;
/*
-(NSString *) getStringFromDate:(NSDate *) myDate forKind:(NSInteger) kind;
-(NSDate *) getDateFromString:(NSString *) myDatetime;
*/
-(IBAction) pickerChange:(id) sender;
@end
