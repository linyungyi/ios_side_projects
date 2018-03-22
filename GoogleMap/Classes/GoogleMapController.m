//
//  GoogleMapController.m
//  GoogleMap
//
//  Created by Joshua Newnham on 17/03/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GoogleMapController.h"

@interface GoogleMapController()

@property (nonatomic,retain) CLLocationManager *locationManager; 

@end

@implementation GoogleMapController

@synthesize locationManager;
@synthesize mapView;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}

- (void)loadView {
	
	CLLocationManager *tManager = [[CLLocationManager alloc] init];
	tManager.delegate = self; 
	[tManager setDesiredAccuracy:kCLLocationAccuracyBest];
	self.locationManager = tManager;
	[locationManager startUpdatingLocation];
	
	// load html into webview 
	NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"map" ofType:@"html"];
	NSData *htmlData = [NSData dataWithContentsOfFile:htmlPath];
	mapView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[mapView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"utf-8" 
		  baseURL:[NSURL URLWithString:@"http://maps.google.com/"]];
	[mapView setScalesPageToFit:YES];
	
	self.view = mapView;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	[locationManager stopUpdatingLocation];
	
	NSLog(@"Lat = %f and lon = %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude );
	NSString *js = [NSString stringWithFormat:
					@"var map = new GMap2(document.getElementById(\"map_canvas\"));"
					" map.setMapType(G_HYBRID_MAP);"
					" map.setCenter(new GLatLng(%f, %f), 19);"
					" map.panTo(map.getCenter());"
					" map.openInfoWindow(map.getCenter(),"
					" document.createTextNode(\"Loc: %i/%i\"));", newLocation.coordinate.latitude, newLocation.coordinate.longitude,
					newLocation.coordinate.latitude, newLocation.coordinate.longitude];
	[mapView stringByEvaluatingJavaScriptFromString:js];
	
}


- (void)dealloc {
	[mapView release];
	[locationManager release];
    [super dealloc];
}


@end
