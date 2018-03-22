//
//  PimContactAppDelegate.m
//  PimContact
//
//  Created by bko on 2010/2/22.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "PimContactAppDelegate.h"
#import "PimContactViewController.h"

@implementation PimContactAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    //[window addSubview:viewController.view];
	[window addSubview:navigationController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
