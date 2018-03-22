//
//  SettingRootViewController.h
//  MyCalendar
//
//  Created by yves ho on 2010/2/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingRootViewController : UIViewController<UITableViewDataSource , UITableViewDelegate>{
	/*
	UISwitch *mySwitch;
	UIButton *myButton;
	UIButton *myTestButton;
	*/
	UITableView *myTableView;
	NSMutableArray *tableDatas;
	//UINavigationBar *navigationBar;
}
/*
@property (nonatomic,retain) IBOutlet UISwitch *mySwitch;
@property (nonatomic,retain) IBOutlet UIButton *myButton;
@property (nonatomic,retain) IBOutlet UIButton *myTestButton;
*/
@property (nonatomic,retain) IBOutlet UITableView *myTableView;
@property (nonatomic,retain) NSMutableArray *tableDatas;
//@property (nonatomic,retain) IBOutlet UINavigationBar *navigationBar;

/*
-(IBAction) showCht:(id)sender;
-(IBAction) setEventNotify:(id)sender;
-(IBAction) showTest:(id)sender;
*/

- (void) updateSwitch:(UISwitch *) aSwitch forItem: (NSString *) anItem;
- (void) sendGlobalEnable:(NSString *)enableFlag;

@end
