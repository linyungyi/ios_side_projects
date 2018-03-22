//
//  ListTodoEvent.h
//  MyCalendar
//
//  Created by app on 2010/3/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListTodoEvent.h"
#import "TodoEvent.h"


@interface ListTodoEvent : TodoEvent {
	NSInteger colorRgb;
	NSInteger displayFlag;
	NSString *folderName;
	
}

@property (nonatomic) NSInteger colorRgb;
@property (nonatomic) NSInteger displayFlag;
@property (nonatomic,retain) NSString *folderName;

@end
