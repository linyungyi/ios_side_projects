//
//  InterfaceUtil.h
//  MyCalendar
//
//  Created by Admin on 2010/4/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface InterfaceUtil : NSObject {

}

+(NSInteger) updGlobalNotification:(BOOL)enableFlag;
+(NSInteger) updDeviceToken:(NSString *)dToken;
+(NSInteger) feedbackNotification:(NSString *)cId;
+(NSMutableDictionary *) doProvision:(NSString *)force;
+(NSInteger) doLogin:(NSString *)userId passWd:(NSString *) passWd;
+(NSMutableDictionary *) getVersion;

+(BOOL) setHeader:(NSMutableURLRequest *)request;

@end
