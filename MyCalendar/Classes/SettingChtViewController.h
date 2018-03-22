//
//  SettingChtViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/5.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingChtViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>{
	//UISwitch *serviceSwitch;
	//UISwitch *syncSwitch;
	//UITextField *idTextField;
	//UITextField *pwdTextField;
	//UIButton *syncButton;
	//UILabel *syncLabel;
	UITableView *myTableView;
	NSMutableArray *syncDatas;
}

//@property (nonatomic, retain)IBOutlet UISwitch *serviceSwitch;
//@property (nonatomic, retain)IBOutlet UISwitch *syncSwitch;
//@property (nonatomic, retain)IBOutlet UITextField *idTextField;
//@property (nonatomic, retain)IBOutlet UITextField *pwdTextField;
//@property (nonatomic, retain)IBOutlet UIButton *syncButton;
//@property (nonatomic, retain)IBOutlet UILabel *syncLabel;
@property (nonatomic,retain) IBOutlet UITableView *myTableView;
@property (nonatomic,retain) NSMutableArray *syncDatas;

//-(IBAction) showDetail:(id)sender;
//-(IBAction) setChtService:(id)sender;
//-(IBAction) setAutoSync:(id)sender;
//-(IBAction) setChtId:(id)sender;
//-(IBAction) setChtPwd:(id)sender;

//- (void) updateSwitch:(UISwitch *) aSwitch forItem: (NSString *) anItem;

- (void) firstTimeEnable;

@end
