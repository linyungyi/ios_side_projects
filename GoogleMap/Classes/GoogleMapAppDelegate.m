//
//  GoogleMapAppDelegate.m
//  GoogleMap
//
//  Created by Joshua Newnham on 17/03/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "GoogleMapAppDelegate.h"
#import "GoogleMapController.h"

@implementation GoogleMapAppDelegate

@synthesize window;
@synthesize googleMapController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	UIWindow *tWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.window = tWindow;
	[tWindow release];
	
    GoogleMapController *tController = [[GoogleMapController alloc] init];
	self.googleMapController = tController;
	[tController release];
	[window addSubview:googleMapController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
	[googleMapController release];
    [window release];
    [super dealloc];
}


@end
