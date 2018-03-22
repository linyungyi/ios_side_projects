//
//  ListTodoEvent.m
//  MyCalendar
//
//  Created by app on 2010/3/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ListTodoEvent.h"


@implementation ListTodoEvent
@synthesize colorRgb,displayFlag;
@synthesize folderName;

- (id)init{
	self = [super init];
	return self;
}

- (void) dealloc{
	[folderName release];
	[super dealloc];
}
@end
