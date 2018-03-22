//
//  GoogleMapAppDelegate.h
//  GoogleMap
//
//  Created by Joshua Newnham on 17/03/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GoogleMapController;

@interface GoogleMapAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	GoogleMapController *googleMapController; 
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic,retain) GoogleMapController *googleMapController; 

@end

