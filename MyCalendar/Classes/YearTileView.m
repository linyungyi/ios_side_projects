//
//  YearTileView.m
//  MyCalendar
//
//  Created by app on 2010/3/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YearTileView.h"
#import "MonthEventViewController.h"


@implementation YearTileView
@synthesize title,days,first,colorCtrl;
@synthesize viewController;
@synthesize text;
@synthesize calendarRootViewController;
@synthesize yearMonth;
@synthesize year;
@synthesize month;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	
	
	
	CGContextRef	context = UIGraphicsGetCurrentContext();

	
	
	int i=0,j=0;
	int draw =0;
	int rows= ceil((self.first-1+self.days)/7.0f);
	//DoLog(DEBUG,@"ROWS:%d,first:%d,length:%d",rows,self.first,self.days);
	
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
	
	CGFloat headerHeight = height/7.0;
	CGFloat calendarHeight = (height-2*height/7.0)/rows;
	CGFloat calendarWidth = width/7.0;
	CGFloat numberFontSize = floorf(0.83f * headerHeight);
	//CGFloat lineThickness = 1+floorf(0.02f * headerHeight);  // for grid shadow and highlight
	
	NSArray *weekdayNames = [[NSArray alloc] initWithObjects:@"日", @"一", @"二", @"三", @"四", @"五", @"六", nil];
	
	//1. draw header
	CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
	CGContextSetRGBFillColor(context, 0.753f, 0.753f, 0.761f, 1.0f);
	//CGContextAddRect(context, CGRectMake(0.0, 0.0, width, headerHeight));
	CGContextFillPath(context);
	// dark grid line
	CGContextSetRGBFillColor(context, 0.667f, 0.682f, 0.714f, 1.0f);
	//CGContextFillRect(context, CGRectMake(0, 0, width, lineThickness));                    // top
	//CGContextFillRect(context, CGRectMake(width-lineThickness, 0, lineThickness, headerHeight)); // right
	//CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
	CGContextSetRGBFillColor(context, 129.0f/255.0f,104.0f/255.0f,92.0f/255.0f,1.0f);
	[self.title drawAtPoint:CGPointMake(50.0f, 0.0f) withFont:[UIFont boldSystemFontOfSize:numberFontSize]];
	
	//2. draw week name
	for(int k=0;k<7;k++){
		CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
		CGContextSetRGBFillColor(context, 0.953f, 0.953f, 0.961f, 1.0f);
		//CGContextAddRect(context, CGRectMake(calendarWidth*k, headerHeight, calendarWidth, headerHeight));
		CGContextFillPath(context);
		// dark grid line
		CGContextSetRGBFillColor(context, 0.667f, 0.682f, 0.714f, 1.0f);
		//CGContextFillRect(context, CGRectMake(calendarWidth*k, headerHeight, calendarWidth, lineThickness));                    // top
		//CGContextFillRect(context, CGRectMake(calendarWidth*k-lineThickness, headerHeight, lineThickness, headerHeight)); // right
		//CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
		CGContextSetRGBFillColor(context, 181.0f/255.0f, 149.0f/255.0f, 133.0f/255.0f, 1.0f);
		[[weekdayNames objectAtIndex:k] drawAtPoint:CGPointMake(4.0f+calendarWidth*k, 0.0f+headerHeight) withFont:[UIFont boldSystemFontOfSize:numberFontSize]];
		
	}
	[weekdayNames release];
	
	for(int k=0;k<rows*7;k++)
	{
		if(i==(self.first-1) && draw==0)
		{
			draw = 1;
		}
		
		
		CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
		if(i == 0 || i == 6){
			//weekend color
			CGContextSetRGBFillColor(context, 0.953f, 0.953f, 0.0f, 1.0f);
		}else{
			CGContextSetRGBFillColor(context, 0.953f, 0.953f, 0.961f, 1.0f);
		}
		
		if(draw >= 1 && draw <= self.days)
		{
			//DoLog(DEBUG,@"colors:%d",colors[draw]);
			
			if(colors[draw] !=0)
			{
				CGContextSetRGBFillColor(context, 169.0f/255.0f,144.0f/255.0f,132.0f/255.0f,1.0f);
				///////////////////////////ADD
				CGContextAddRect(context, CGRectMake(calendarWidth*i, headerHeight*2+calendarHeight*j, calendarWidth, calendarHeight));
			}
		}
		//CGContextAddRect(context, CGRectMake(calendarWidth*i, headerHeight*2+calendarHeight*j, calendarWidth, calendarHeight));
		CGContextFillPath(context);
		// dark grid line
		CGContextSetRGBFillColor(context, 0.667f, 0.682f, 0.714f, 1.0f);
		//CGContextFillRect(context, CGRectMake(calendarWidth*i, headerHeight*2+calendarHeight*j, calendarWidth, lineThickness));                    // top
		//CGContextFillRect(context, CGRectMake(calendarWidth*(i+1)-lineThickness, calendarHeight, lineThickness, calendarHeight)); // right
		//CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
		CGContextSetRGBFillColor(context, 129.0f/255.0f,104.0f/255.0f,92.0f/255.0f,1.0f);
		if(i==0){
			CGContextSetRGBFillColor(context, 244.0f/255.0f,96.0f/255.0f,0.0f/255.0f,1.0f);
		}
		if(i==6){
			CGContextSetRGBFillColor(context, 111.0f/255.0f,131.0f/255.0f,11.0f/255.0f,1.0f);
		}
		if(draw >= 1 && draw <= self.days)
		{
			self.text=[NSString stringWithFormat:@"%d",draw];
			[self.text drawAtPoint:CGPointMake(4.0f+calendarWidth*i, 0.0f+headerHeight*2+calendarHeight*j) withFont:[UIFont boldSystemFontOfSize:numberFontSize]];
			draw++;
		}
		//DoLog(DEBUG,@"YYY:%@,%d,%d,%d",text,i,j,draw);
		//DoLog(DEBUG,@"width:%f,height:%f",width,height);

		i++;
		if(i==7){
			i=0;
			j++;
		}
		
	}
	
	
}
- (void)drawTextInContext:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    CGFloat width = self.bounds.size.width;
    //CGFloat height = self.bounds.size.height;
    
    CGFloat numberFontSize = floorf(0.5f * width);
    
    // create a clipping mask from the text for the gradient
    // NOTE: this is a pain in the ass because clipping a string with more than one letter
    //       results in the clip of each letter being superimposed over each other,
    //       so instead I have to manually clip each letter and draw the gradient
    //CGContextSetRGBFillColor(ctx, 0.667f, 0.682f, 0.714f, 1.0f);
	CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
    //CGContextSetTextDrawingMode(ctx, kCGTextFillStrokeClip);
    for (NSInteger i = 0; i < [self.text length]; i++) {
        NSString *letter = [self.text substringWithRange:NSMakeRange(i, 1)];
        CGSize letterSize = [letter sizeWithFont:[UIFont boldSystemFontOfSize:numberFontSize]];
        
        CGContextSaveGState(ctx);  // I will need to undo this clip after the letter's gradient has been drawn
        [letter drawAtPoint:CGPointMake(4.0f+(letterSize.width*i), 0.0f) withFont:[UIFont boldSystemFontOfSize:numberFontSize]];
/*	
        if (NO) {
            CGContextSetRGBFillColor(ctx,0.0f, 0.0f, 0.0f, 1.0f);
            CGContextFillRect(ctx, self.bounds);  
        } else {
            // nice gradient fill for all tiles except today
            CGContextDrawLinearGradient(ctx, TextFillGradient, CGPointMake(0,0), CGPointMake(0, height/3), kCGGradientDrawsAfterEndLocation);
        }
	*/	
        CGContextRestoreGState(ctx);  // get rid of the clip for the current letter        
    }
    
    CGContextRestoreGState(ctx);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { [[self superview] touchesBegan:touches withEvent:event]; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { [[self superview] touchesMoved:touches withEvent:event]; }

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch *touch = [touches anyObject];
    if ([touch tapCount] == 1){
        DoLog(DEBUG,@"AAA:::%d",[touch tapCount]);
		[self.calendarRootViewController.segmentedControl setSelectedSegmentIndex:1];
		//mark first load
		//self.calendarRootViewController.monthEventViewController.theDay=11111;
		//[self.calendarRootViewController.monthEventViewController viewWillAppear:YES];
		[self.calendarRootViewController.monthEventViewController fromYearViewToMonthView:self.year month:self.month];
		//[self.calendarRootViewController.segmentedControl setSelectedSegmentIndex:1];
		//[self.calendarRootViewController changeView:self.yearMonth toView:2];
		
		//[self sendActionsForControlEvents:UIControlEventTouchUpInside];
	}else{
        //[[self superview] touchesEnded:touches withEvent:event];
		DoLog(DEBUG,@"BBB:::%d",[touch tapCount]);
	}
	[[self superview] touchesEnded:touches withEvent:event];
}

- (void)setColors:(int) index value:(int)value {
	if(index>=0 && index<32){
		colors[index]=value;
	}
} 


- (void)dealloc {
	[text release];
	[title release];
	[colorCtrl release];
	[viewController release];
    [super dealloc];
}
-(void) setRootViewController:(id)root{
	calendarRootViewController=root;
}

@end
