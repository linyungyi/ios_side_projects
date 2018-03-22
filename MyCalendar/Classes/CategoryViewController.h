//
//  CategoryViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryTableViewController.h"

@interface CategoryViewController : UIViewController {
	//UIView *view;
	UINavigationController *navController;
	CategoryTableViewController *tableViewController;
}

//@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
@property (nonatomic, retain) IBOutlet CategoryTableViewController *tableViewController;

-(IBAction) addCategory:(id)sender;

@end
