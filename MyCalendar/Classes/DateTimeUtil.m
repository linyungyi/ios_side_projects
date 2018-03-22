//
//  DateTimeUtil.m
//  MyCalendar
//
//  Created by Admin on 2010/3/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DateTimeUtil.h"


@implementation DateTimeUtil


+(NSDateComponents *) getDateComponentsFromLong:(NSUInteger) myDatetime{
	/*
	 if(myDatetime<10000000000)
	 return nil;
	 */
	NSUInteger tmp=myDatetime;
	int year=tmp/10000000000;
	tmp=tmp%10000000000;
	int month=tmp/100000000;
	tmp=tmp%100000000;
	int day=tmp/1000000;
	tmp=tmp%1000000;
	int hour=tmp/10000;
	tmp=tmp%10000;
	int min=tmp/100;
	tmp=tmp%100;
	int sec=tmp;
	
	NSDateComponents *cmp=[[[NSDateComponents alloc]init]autorelease];
	[cmp setYear:year];
	[cmp setMonth:month];
	[cmp setDay:day];
	[cmp setHour:hour];
	[cmp setMinute:min];
	[cmp setSecond:sec];
	
	return cmp;
}

+(NSDateComponents *) getDateComponentsFromString:(NSString *) myDatetime{
	if([myDatetime length]!=14)
		return nil;
	
	NSRange range;
	
	range.location=0;
	range.length=4;
	int year=[[myDatetime substringWithRange:range]intValue];
	range.location=4;
	range.length=2;
	int month=[[myDatetime substringWithRange:range]intValue];
	range.location=6;
	int day=[[myDatetime substringWithRange:range]intValue];
	range.location=8;
	int hour=[[myDatetime substringWithRange:range]intValue];
	range.location=10;
	int min=[[myDatetime substringWithRange:range]intValue];
	range.location=12;
	int sec=[[myDatetime substringWithRange:range]intValue];
	
	NSDateComponents *cmp=[[[NSDateComponents alloc]init]autorelease];
	[cmp setYear:year];
	[cmp setMonth:month];
	[cmp setDay:day];
	[cmp setHour:hour];
	[cmp setMinute:min];
	[cmp setSecond:sec];
	
	NSCalendar *cal= [NSCalendar currentCalendar];
	NSDate *date = [cal dateFromComponents:cmp];
	cmp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
	
	return cmp;
}

+(NSString *) getStringFromDate:(NSDate *) myDate forKind:(NSInteger) kind{
	if(myDate == nil)
		return nil;
	
	NSDateFormatter *form=[[NSDateFormatter alloc]init];
	
	if(kind==1)
		[form setDateFormat:@"yyyy/MM/dd HH:mm"];
	else if(kind==2)
		[form setDateFormat:@"           HH:mm"];
	else
		[form setDateFormat:@"yyyyMMddHHmmss"];
	
	NSString *str=[form stringFromDate:myDate];
	
	[form release];
	
	return str;
}

+(NSDate *) getDateFromString:(NSString *) myDatetime{
	if([myDatetime length]!=14)
		return nil;
	
	NSRange range;
	
	range.location=0;
	range.length=4;
	int year=[[myDatetime substringWithRange:range]intValue];
	range.location=4;
	range.length=2;
	int month=[[myDatetime substringWithRange:range]intValue];
	range.location=6;
	int day=[[myDatetime substringWithRange:range]intValue];
	range.location=8;
	int hour=[[myDatetime substringWithRange:range]intValue];
	range.location=10;
	int min=[[myDatetime substringWithRange:range]intValue];
	range.location=12;
	int sec=[[myDatetime substringWithRange:range]intValue];
	
	NSDateComponents *cmp=[[NSDateComponents alloc]init];
	[cmp setYear:year];
	[cmp setMonth:month];
	[cmp setDay:day];
	[cmp setHour:hour];
	[cmp setMinute:min];
	[cmp setSecond:sec];
	
	NSCalendar *cal=[NSCalendar currentCalendar];
	NSDate *date=[cal dateFromComponents:cmp];
	[cmp release];
	return date;
}


+(BOOL) chkAllDay:(NSString *)start endDate:(NSString *)end{
	if([start length]!=14 || [end length]!=14)
		return NO;
	
	NSRange range;
	range.location=0;
	range.length=8;
	NSInteger startDate=[[start substringWithRange:range]intValue];
	NSInteger endDate=[[end substringWithRange:range]intValue];
	
	range.location=8;
	range.length=6;
	NSInteger startTime=[[start substringWithRange:range]intValue];
	NSInteger endTime=[[end substringWithRange:range]intValue];
	
	if(endDate==startDate && (endTime-startTime)==235900)
		return YES;
	else
		return NO;
}

+ (NSString *) getTodayString{
	NSDate *now=[NSDate date];
	NSDateFormatter *form=[[NSDateFormatter alloc]init];
	NSInteger kind=0;
	
	if(kind!=0)
		[form setDateFormat:@"yyyy/MM/dd HH:mm"];
	else
		[form setDateFormat:@"yyyyMMddHHmmss"];
	
	NSString *str=[form stringFromDate:now];
	[form release];
	
	return str;
}

+(NSInteger) getDiffTimeZoneFromTaipei{
	NSDate *sDate = [NSDate date];
	NSTimeZone *sTimeZone = [NSTimeZone defaultTimeZone];
	NSInteger sSeconds = [sTimeZone secondsFromGMTForDate:sDate];
	NSInteger dMins = (sSeconds-TAIPEITIMEZONE)/60;
	
	return dMins;
}

+(NSDate *) getDiffDate:(NSDate *)myDatetime mins:(NSInteger) mins{

	NSTimeInterval timeInterval=mins*60;
	return [myDatetime addTimeInterval:timeInterval];
	
}

+(NSDate *) getNewDate:(NSDate *)startTime days:(NSInteger) days{//年|月|日
	NSInteger j=0;
	NSCalendar *cal=[NSCalendar currentCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	if(days>=365){
		[components setYear:(days/365)];
		j=days%365;
		if(j>=30){
			[components setMonth:(j/30)];
			j=j%30;
			if(j>0)
				[components setDay:j];
		}
	}else if(days>=30){
		[components setMonth:(days/30)];
		j=days%30;
		if(j>0)
			[components setDay:j];
	}else
		[components setDay:days];
	
	NSDate *now=[cal dateByAddingComponents:components toDate:startTime options:0];
	
	[components release];
	
	return now;
}

+(NSInteger) getCountFromDate:(NSDate *)startTime endDate:(NSDate *)endTime days:(NSInteger) days{//年|月|日
	NSInteger i=0,j=0;
	NSCalendar *cal=[NSCalendar currentCalendar];
	NSDateComponents *components = [[NSDateComponents alloc] init];
	
	//DoLog(DEBUG,@"%d",days);
	
	if(days>=365){
		[components setYear:(days/365)];
		j=days%365;
		if(j>=30){
			[components setMonth:(j/30)];
			j=j%30;
			if(j>0)
				[components setDay:j];
		}
	}else if(days>=30){
		[components setMonth:(days/30)];
		j=days%30;
		if(j>0)
			[components setDay:j];
	}else
		[components setDay:days];
	
	NSDate *now=[cal dateByAddingComponents:components toDate:startTime options:0];
	
	while([now compare:endTime]!=NSOrderedDescending){
		++i;
		now=[cal dateByAddingComponents:components toDate:now options:0];	
	}
	
	[components release];
	
	//DoLog(DEBUG,@"%d",i);
	return i;
}


+ (NSString *) getUrlDateString{
	NSDate *now=[NSDate date];
	NSDateFormatter *form=[[NSDateFormatter alloc]init];
	
	[form setDateFormat:@"yyyyMMddHHmmssSSS"];
	
	NSString *str=[form stringFromDate:now];
	[form release];
	
	//DoLog(DEBUG,@"test=%@",str);
	return str;
}


@end
