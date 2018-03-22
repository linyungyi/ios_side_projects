//
//  LunarCalendar.h
//  MyCalendar
//
//  Created by app on 2010/4/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LunarCalendar : NSObject {
	/*//國曆
	int sYear;		//西元年4位數字
	int sMonth;		//西元月數字
	int sDay;		//西元日數字
	int week;		//星期, 1個中文
	//農曆
	int lYear;		//西元年4位數字
	int lMonth;		//農曆月數字
	int lDay;		//農曆日數字
	BOOL isLeap;	//是否為農曆閏月?
	//八字
	int cYear;		//年柱, 2個中文
	int cMonth;		//月柱, 2個中文
	int cDay;		//日柱, 2個中文
	
	
	NSMutableString *lunarFestival;	//農曆節日
	NSMutableString *solarFestival;	//國曆節日
	NSMutableString *solarTerms;	//節氣*/
	
}



+(void) test;
+(int) lYearDays:(int)y;
+(int) leapDays:(int)y ;
+(int) leapMonth:(int)y ;
+(int) monthDays:(int)y m:(int)m;
+(int) lunarAtDate:(NSDate *)date;
+ (NSArray*) solarTerm;	//Array("小寒","大寒","立春","雨水","驚蟄","春分","清明","穀雨","立夏","小滿","芒種","夏至","小暑","大暑","立秋","處暑","白露","秋分","寒露","霜降","立冬","小雪","大雪","冬至")
+ (NSArray*) nStr1;		//Array('日','一','二','三','四','五','六','七','八','九','十')
+ (NSArray*) nStr2;		//Array('初','十','廿','卅','卌')
+ (NSDictionary*) lFtv;
+ (int) getLunarYear;
+ (int) getLunarMonth;
+ (int) getLunarDay;

+ (int) sTerm:(int)y n:(int)n; 
+ (NSString *) getSolarTerms;
+ (NSString *) getLunarDayChinese;
+ (NSString *) getLunarMonthChinese;
+ (NSString *) getLunarFestival;
@end
