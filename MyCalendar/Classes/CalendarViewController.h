//
//  CalendarViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarRootViewController.h"
#import "SyncOperation.h"

@interface CalendarViewController : UIViewController <SyncOperationDelegate,UIActionSheetDelegate>{
	UINavigationController *navController;
	CalendarRootViewController *rootViewController;
	SyncOperation *syncOperation;
}
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet CalendarRootViewController *rootViewController;
@property (retain) SyncOperation *syncOperation;

-(void) firstTimeInstall;
@end
