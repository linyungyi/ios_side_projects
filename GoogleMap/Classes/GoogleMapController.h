//
//  GoogleMapController.h
//  GoogleMap
//
//  Created by Joshua Newnham on 17/03/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface GoogleMapController : UIViewController <CLLocationManagerDelegate> {
	CLLocationManager *locationManager; 
	UIWebView *mapView; 
}

@property (nonatomic,retain) UIWebView *mapView;

@end
