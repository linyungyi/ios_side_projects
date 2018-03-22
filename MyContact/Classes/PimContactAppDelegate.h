//
//  PimContactAppDelegate.h
//  PimContact
//
//  Created by bko on 2010/2/22.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PimContactViewController;
@class test;

@interface PimContactAppDelegate : NSObject <UIApplicationDelegate,UITableViewDelegate> {
    UIWindow *window;
    PimContactViewController *viewController;
	IBOutlet UINavigationController *navigationController;	
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) PimContactViewController *viewController;
@property(nonatomic,retain) IBOutlet UINavigationController *navigationController;

@end

