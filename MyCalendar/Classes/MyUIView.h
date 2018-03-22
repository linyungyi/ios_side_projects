//
//  MyUIView.h
//  MyCalendar
//
//  Created by yvesho on 2010/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface MyUIView : UIView {
	id delegate;
	CGPoint startLocation, endLocation;
	NSTimeInterval startTime, endTime;
	STATE			state;
}

@property (nonatomic,retain) id delegate;

- (void)swipe;

@end
