//
//  MyLog.m
//  MyCalendar
//
//  Created by Admin on 2010/4/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyLog.h"
@implementation MyLog

+(void)doLog:(int)level filename:(char *)fname funcname:(char *)funcname line:(int)line format:(id)format , ...{

	if(level>=DEFAULTLEVEL){
		va_list arglist;
		if (!format) return;
		va_start(arglist, format);
		id outstring = [[[NSString alloc] initWithFormat:format arguments:arglist] autorelease];
		va_end(arglist);
	
		//NSString *filename = [[NSString stringWithCString:fname encoding:NSUTF8StringEncoding] lastPathComponent];
		//NSString *debugInfo = [NSString stringWithFormat:@"%@:%d",filename,line];
		NSString *debugInfo = [NSString stringWithFormat:@"%s%d", funcname, line];
    
		switch (level) {
			case DEBUG:
				NSLog(@"%@ DEBUG %@",debugInfo,outstring);
				break;
			case INFO:
				NSLog(@"%@ INFO %@",debugInfo,outstring);
				break;
			case WARNNING:
				NSLog(@"%@ WARNNING %@",debugInfo,outstring);
				break;
			case ERROR:
				NSLog(@"%@ ERROR %@",debugInfo,outstring);
				break;
			case FATAL:
				NSLog(@"%@ FATAL %@",debugInfo,outstring);
				break;
			default:
				NSLog(@"%@ %@",debugInfo,outstring);
				break;
		}
	}
	
}




@end
