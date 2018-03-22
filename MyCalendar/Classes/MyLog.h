//
//  MyLog.h
//  MyCalendar
//
//  Created by Admin on 2010/4/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyLog : NSObject {

}

+(void)doLog:(int)level filename:(char *)fname funcname:(char *)funcname line:(int)line format:(id)format , ...;

@end
