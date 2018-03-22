//
//  CategoryDetailViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TodoCategory;
@class MySqlite;

@interface CategoryDetailViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>{
	TodoCategory *todoCategory;
	NSInteger colorRgb;
	UIImageView *myLabel;
	UITextField *myTextField;
	UISwitch *mySwitch;
	UITableView *myTableView;
	NSArray *tableDatas;
	UIButton *delButton;
}

@property (nonatomic,retain) TodoCategory *todoCategory;
@property NSInteger colorRgb;
@property (nonatomic,retain) IBOutlet UIImageView *myLabel;
@property (nonatomic,retain) IBOutlet UITextField *myTextField;
@property (nonatomic,retain) IBOutlet UISwitch *mySwitch;
@property (nonatomic,retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSArray *tableDatas;
@property (nonatomic, retain) IBOutlet UIButton *delButton;


-(id)initWithCategoryId:(NSString *)cId nib:(NSString *)nibNameOrNil;
-(IBAction) doJob:(id)sender;
-(IBAction) doDel:(id)sender;
//-(void)hiddenKeyboard;

@end
