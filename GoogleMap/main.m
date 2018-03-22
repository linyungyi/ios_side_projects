//
//  main.m
//  GoogleMap
//
//  Created by Joshua Newnham on 17/03/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleMapAppDelegate.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"GoogleMapAppDelegate");
    [pool release];
    return retVal;
}
