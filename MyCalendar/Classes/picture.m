//
//  picture.m
//  MyCalendar
//
//  Created by app on 2010/4/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "picture.h"


@implementation picture



+ (NSArray*) arrow{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 @"",						//0
				 @"arrow_previous.png",		//1
				 @"arrow_next.png",			//2
				 nil];
    }
    return array;
}

+ (NSArray*) calenMonthly{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 @"",							//0
				 @"calen_monthly_bg4row.png",	//1
				 @"calen_monthly_bg5row.png",	//2
				 @"calen_monthly_bg6row.png",	//3
				 @"calen_monthly_week_bg.png",	//4
				 @"calenmonthly_date_bg.png",	//5
				 nil];
    }
    return array;
}


+ (NSArray*) calenOther{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 @"",							//0
				 @"calentoolbar_bg.png",		//1
				 @"calen_remind.png",			//2
				 @"calendate_bg.png",			//3
				 nil];
    }
    return array;
}


+ (NSArray*) calendar{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 @"",							//0
				 @"calendar_bg.png",			//1
				 @"calendar_monthly_bg.png",	//2
				 @"calendar_weekly_bg.png",		//3
				 nil];
    }
    return array;
}


+ (NSArray*) calenfolder{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 @"",							//0
				 @"calenfolder_320_blue.png",	//1
				 @"calenfolder_320_gray.png",	//2
				 @"calenfolder_320_green.png",	//3
				 @"calenfolder_320_purple.png",	//4
				 @"calenfolder_320_red.png",	//5
				 @"calenfolder_blue.png",		//6
				 @"calenfolder_gray.png",		//7
				 @"calenfolder_green.png",		//8
				 @"calenfolder_purple.png",		//9
				 @"calenfolder_red.png",		//10
				 nil];
    }
    return array;
}

+ (NSArray*) monthly{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 @"",							//0
				 @"monthly_more.png",			//1
				 @"monthly_sel_bg.png",			//2
				 @"monthly_today_bg.png",		//3
				 nil];
    }
    return array;
}

+ (NSArray*) weekly{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 
				 @"",							//0
				 @"weekly_listbg_blue.png",		//1
				 @"weekly_listbg_gray.png",		//2
				 @"weekly_listbg_green.png",	//3
				 @"weekly_listbg_purple.png",	//4
				 @"weekly_listbg_red.png",		//5
				 nil];
    }
    return array;
}

+ (NSArray*) titlebg{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 @"",							//0
				 @"titlebg_today.png",			//1
				 @"titlebg_weekday.png",		//2
				 @"titlebg_weekend.png",		//3
				 nil];
    }
    return array;
}


+ (NSArray*) calenNotify{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 @"",							//0
				 @"calen_notify_bg.png",		//1
				 @"calen_notify_s_bg.png",		//2
				 @"calen_notify_s_press_bg.png",//3
				 nil];
    }
    return array;
}

+ (NSArray*) calenlist{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 @"",							//0
				 @"calenlist_bg.png",			//1
				 @"calenlist_title_bg.png",		//2
				 nil];
    }
    return array;
}

+ (NSArray*) daily{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 @"",							//0
				 @"daily_timeaxis_bg.png",		//1
				 @"daily_timeline_bg.png",		//2
				 @"daily_titlebg_today.png",	//3
				 @"daily_titlebg_weekday.png",	//4
				 @"daily_titlebg_weekend.png",	//5
				 nil];
    }
    return array;
}

+ (NSArray*) icon{
	static NSArray* array= nil;
    if (array == nil) {
        array = [[NSArray alloc] initWithObjects:
				 @"",							//0
				 @"icon_location.png",			//1
				 @"icon_backup.png",			//2
				 @"icon_return.png",			//3
				 @"icon_sync.png",				//4
				 @"icon_work40.png",			//5
				 @"icon_work.png",				//6
				 nil];
    }
    return array;
}


@end
