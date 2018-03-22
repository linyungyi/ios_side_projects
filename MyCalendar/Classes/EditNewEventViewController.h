//
//  EditNewEventViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/4/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewEventViewController.h"

@interface EditNewEventViewController : UIViewController {
	UINavigationController *navController;
	NewEventViewController *rootViewController;
}

@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet NewEventViewController *rootViewController;


@end
