//
//  TouchView.m
//  MyCalendar
//
//  Created by yves ho on 2010/3/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TouchView.h"
#import "EventDetailViewController.h"


@implementation TouchView
@synthesize calendarRootViewController;
@synthesize listTodoEvent;
//@synthesize title;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {DoLog(DEBUG,@"ddd"); [[self superview] touchesBegan:touches withEvent:event]; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { [[self superview] touchesMoved:touches withEvent:event]; }

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	//DoLog(DEBUG,@"dddccc");
	UITouch *touch = [touches anyObject];
    if ([touch tapCount] == 1){
        EventDetailViewController *next = [[EventDetailViewController alloc]init];
		next.eId=listTodoEvent.calendarId;
		next.sId=listTodoEvent.serverId;
		
		self.calendarRootViewController.title=@"<<";
		
		[self.calendarRootViewController.navigationController  pushViewController:next animated:YES];		
	}
}

- (void)dealloc {
	//[title release];
	[listTodoEvent release];
	[calendarRootViewController release];
    [super dealloc];
}

@end
