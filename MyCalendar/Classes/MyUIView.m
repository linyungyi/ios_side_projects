//
//  MyUIView.m
//  MyCalendar
//
//  Created by yvesho on 2010/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyUIView.h"



@implementation MyUIView

@synthesize delegate;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	int noTouchesInEvent  = ((NSSet*)[event allTouches]).count;
	int noTouchesBegan	  = touches.count;
	if((state == S0) && (noTouchesBegan== 1) && (noTouchesInEvent==1)){
		startLocation  = [(UITouch*)[touches anyObject] locationInView:self];
		startTime	   = [(UITouch*)[touches anyObject] timestamp];
		state = S1;
	}
	else{
		state = S0;
		[self swipe];
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	int noTouchesInEvent  = ((NSSet*)[event allTouches]).count;
	int noTouchesEnded	  = touches.count;
	if( (state==S1) && (noTouchesEnded == 1) && (noTouchesInEvent==1)){
		endLocation = [(UITouch*)[touches anyObject] locationInView:self];
		endTime		= [(UITouch*)[touches anyObject] timestamp];
		[self swipe];
	}
}

- (void)swipe{
	if(state == S1){
		
		if( (fabs(startLocation.y - endLocation.y) <= Y_TOLERANCE)  &&
		   (fabs(startLocation.x - endLocation.x) >= X_TOLERANCE)
		   ){
			int direction;
			direction = (endLocation.x > startLocation.x) ? 1 : 2;
			if(direction ==1){
				if (self.delegate && [self.delegate respondsToSelector:@selector(showPrevious)])
					[self.delegate performSelector:@selector(showPrevious) withObject:nil];
				
			}else if(direction ==2){
				if (self.delegate && [self.delegate respondsToSelector:@selector(showFollowing)])
					[self.delegate performSelector:@selector(showFollowing) withObject:nil];
			}
			
		}
		state = S0;
	}
	
}

- (void)dealloc {
	[delegate release];
    [super dealloc];
}


@end
