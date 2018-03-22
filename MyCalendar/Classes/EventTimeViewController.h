//
//  EventTimeViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EventTimeViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>{
	UISwitch *notifySwitch;
	UIPickerView *datePicker;
	NSInteger days;
	NSInteger hours;
	NSInteger mins;
	NSArray *column1;
	NSArray *column2;
	NSArray *column3;
	NSArray *todoEvent;
}

@property (nonatomic,retain) IBOutlet UISwitch *notifySwitch;
@property (nonatomic,retain) IBOutlet UIPickerView *datePicker;
@property NSInteger days;
@property NSInteger hours;
@property NSInteger mins;
@property (nonatomic, retain) NSArray *column1;
@property (nonatomic, retain) NSArray *column2;
@property (nonatomic, retain) NSArray *column3;
@property (nonatomic, retain) NSArray *todoEvent;

-(IBAction) doJob:(id) sender;
-(IBAction) switchChange:(id) sender;
-(IBAction) pickerChange:(id) sender;

@end
