//
//  DateTimeUtil.h
//  MyCalendar
//
//  Created by Admin on 2010/3/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DateTimeUtil : NSObject {

}

+(NSDateComponents *) getDateComponentsFromLong:(NSUInteger) myDatetime;
+(NSDateComponents *) getDateComponentsFromString:(NSString *) myDatetime;
+(NSString *) getStringFromDate:(NSDate *) myDate forKind:(NSInteger) kind;
+(NSDate *) getDateFromString:(NSString *) myDatetime;
+(BOOL) chkAllDay:(NSString *)start endDate:(NSString *)end;
+(NSString *) getTodayString;
+(NSInteger) getDiffTimeZoneFromTaipei;
+(NSDate *) getDiffDate:(NSDate *)myDatetime mins:(NSInteger) mins;
+(NSDate *) getNewDate:(NSDate *)startTime days:(NSInteger) days;
+(NSInteger) getCountFromDate:(NSDate *)startTime endDate:(NSDate *)endTime days:(NSInteger) days;

+(NSString *) getUrlDateString;


@end
