//
//  TestAlert.m
//  Music01
//
//  Created by bko on 2009/8/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DetailAlert.h"
#define	TITLE_TAG	999
#define	MESSAGE_TAG	998

@implementation DetailAlert


- (id)initWithFrame:(CGRect)frame {
	frame.origin.y = 20.0f - frame.size.height; // Place above status bar
	self = [super initWithFrame:frame];
	
	[self setAlpha:0.9];
	//[self setBackgroundColor: sysBlueColor(0.4f)];
	
		
	// Add title
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 8.0f, 320.0f, 32.0f)];
	title.text = @"活動詳情";
	title.textAlignment = UITextAlignmentCenter;
	title.textColor = [UIColor brownColor];
	title.backgroundColor = [UIColor clearColor];
	title.font = [UIFont boldSystemFontOfSize:20.0f];
	[self addSubview:title];
	[title release];
	
	// Add message
	//UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 40.0f, 280.0f, 200.0f - 48.0f)];
	mLabel=[[UILabel alloc] initWithFrame:CGRectMake(20.0f, 40.0f, 280.0f, 200.0f - 48.0f)];
	mLabel.text = @"content";
	mLabel.textAlignment = UITextAlignmentLeft;	
	mLabel.numberOfLines = 999;
	mLabel.textColor = [UIColor whiteColor];
	mLabel.backgroundColor = [UIColor clearColor];
	mLabel.lineBreakMode = UILineBreakModeWordWrap;
	mLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
		
	[self addSubview:mLabel];
	//[mLabel release];	
	
	return self;
	
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	[mLabel release];
    [super dealloc];
}

- (void) setTitle: (NSString *)titleText
{
	[(UILabel *)[self viewWithTag:TITLE_TAG] setText:titleText];
}

- (void) setMessage: (NSString *)messageText
{
	//[(UILabel *)[self viewWithTag:MESSAGE_TAG] setText:messageText];
	mLabel.text=messageText;
}

- (void) removeView {
	// Scroll away the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	
	CGRect rect = [self frame];
	rect.origin.y = -10.0f - rect.size.height;
	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
}

- (void) presentView {
	// Scroll in the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	
	CGRect rect = [self frame];
	rect.origin.y = 0.0f;
	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
}

@end
