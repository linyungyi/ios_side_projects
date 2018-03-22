//
//  SettingViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/5.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingRootViewController.h"

@interface SettingViewController : UIViewController {
	UINavigationController *navController;
	SettingRootViewController *rootViewController;
	//UINavigationBar *navigationBar;
}
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet SettingRootViewController *rootViewController;
//@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

@end
