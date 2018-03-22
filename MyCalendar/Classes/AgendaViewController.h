//
//  AgendaViewController.h
//  MyCalendar
//
//  Created by yvesho on 2010/4/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgendaViewController.h"
#import "AgendaTableViewController.h"
//#import "ListEventViewController.h"

@interface AgendaViewController : UIViewController {
	UINavigationController *navController;
	AgendaTableViewController *tableViewController;
}

@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet AgendaTableViewController *tableViewController;

-(IBAction) doAdd:(id)sender;

@end
