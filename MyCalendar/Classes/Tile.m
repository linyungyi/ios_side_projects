//
//  Tile.m
//  MyCalendar
//
//  Created by app on 2010/3/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Tile.h"
#import "MonthEventViewController.h"
#import "LunarCalendar.h"
#import "picture.h"



@implementation Tile
@synthesize text = _text;
@synthesize isToday,hasEvent,isWeekend;
@synthesize viewController;
@synthesize key;
@synthesize selectedView;
@synthesize revealLunarCalendar;
@synthesize textColor;






- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		selectedView = [[UIImageView alloc] initWithFrame:CGRectMake(0.5f, 0, 45.0f, 36.0f)];
		[selectedView setImage:[UIImage imageNamed:[[picture monthly] objectAtIndex:2]]];
		[selectedView setAlpha:0.8f];
		revealLunarCalendar = NO;
		/*
		CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
		CGFloat components[4] = {0.0f, 0.0f, 0.0f, 1.0f};
		textColor = CGColorCreate(colorspace, components);
		CGColorSpaceRelease(colorspace);
		 */
		textColor = [[UIColor alloc]initWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];


		           
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef	context = UIGraphicsGetCurrentContext();
	
	
	
	
	
	
/*	CGContextSetLineWidth(context, 5.0);
	CGContextMoveToPoint(context, 50, 100);
	CGContextAddLineToPoint(context, 200, 100);
	CGContextStrokePath(context);
	
	
	CGContextAddEllipseInRect(context, CGRectMake(70.0, 170.0, 50.0, 50.0));
	CGContextStrokePath(context);
	
	
	CGContextAddEllipseInRect(context, CGRectMake(150.0, 170.0, 50.0, 50.0));
	CGContextFillPath(context);*/
	
	

/*	
	CGContextSetLineWidth(context, 2.0);
	CGContextMoveToPoint(context, 91, 30);
	CGContextAddLineToPoint(context, 91, 91);
	CGContextStrokePath(context);	
*/
	
	//kGridDarkColor = CreateRGB(0.667f, 0.682f, 0.714f, 1.0f);
	//kGridLightColor = CreateRGB(0.953f, 0.953f, 0.961f, 1.0f);
	
	CGFloat width = self.bounds.size.width;
    //CGFloat height = self.bounds.size.height;
	//DoLog(DEBUG,@"width:%f,height:%f",width,height);
    CGFloat lineThickness = 1+floorf(0.02f * self.bounds.size.width);  // for grid shadow and highlight

	
	/*
	//draw tile 
	CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
	if( self.isToday == 1){
		CGContextSetRGBFillColor(context, 0.753f, 0.753f, 0.761f, 1.0f);
	}else if(self.isWeekend == 1){
		CGContextSetRGBFillColor(context, 0.953f, 0.953f, 0.0f, 1.0f);
	}else{
		CGContextSetRGBFillColor(context, 0.953f, 0.953f, 0.961f, 1.0f);
	}
	CGContextAddRect(context, CGRectMake(0.0, 0.0, width, height));
	CGContextFillPath(context);
	
    // dark grid line
    CGContextSetRGBFillColor(context, 0.667f, 0.682f, 0.714f, 1.0f);
    CGContextFillRect(context, CGRectMake(0, 0, width, lineThickness));                    // top
    CGContextFillRect(context, CGRectMake(width-lineThickness, 0, lineThickness, height)); // right
    
    // highlight
    CGContextSetRGBFillColor(context, 0.953f, 0.953f, 0.961f, 1.0f);
    CGContextFillRect(context, CGRectMake(0, lineThickness, width-lineThickness, lineThickness));                    // top
    CGContextFillRect(context, CGRectMake(width-2*lineThickness, lineThickness, lineThickness, height-lineThickness)); // right
	*/
	if( self.hasEvent == 1){
		
		CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 1.0f);
		CGContextAddEllipseInRect(context, CGRectMake(width-10*lineThickness,lineThickness*8, lineThickness*5, lineThickness*5));
		CGContextFillPath(context);

	}
	
/*	
	CGContextAddArc(context, 260, 90, 40, 0.0*M_PI/180, 270*M_PI/180, 1);
	CGContextAddLineToPoint(context, 280, 350);
	CGContextStrokePath(context);
	
	CGContextMoveToPoint(context, 130, 300);
	CGContextAddLineToPoint(context, 80, 400);
	CGContextAddLineToPoint(context, 190, 400);
	CGContextAddLineToPoint(context, 130, 300);
	CGContextStrokePath(context);*/

	//float white[] = {1.0, 1.0, 1.0, 1.0};
	//CGContextRef context = UIGraphicsGetCurrentContext();
	//CGContextSetFillColor(context, white);
	//CGContextFillRect(context, [self bounds]);
	//CGContextSaveGState(context);
	/*CGContextSetTextDrawingMode(context, kCGTextFillStroke);
	CGContextSelectFont (context,
                         "Arial",
                         20,
                         kCGEncodingMacRoman);
    //CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
	//CGContextSelectFont(context, "Times", 12.0, kCGEncodingMacRoman);
	//CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    //CGContextSetTextMatrix(context, transform);
	CGContextShowTextAtPoint(context, 2.0, 2.0, "t", strlen("t"));
	//CGContextRestoreGState(context);
	*/
	[self drawTextInContext:context];
	if(revealLunarCalendar == YES){
		[self drawLunarTextInContext:context];
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
	//CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
	CGContextSetFillColorWithColor(ctx, textColor.CGColor );
	CGContextSetRGBStrokeColor(ctx, 0.3f, 0.3f, 0.3f, 1.0);
	//CGContextSetStrokeColorWithColor(ctx, textColor);
	
    //CGContextSetTextDrawingMode(ctx, kCGTextFillStrokeClip);
    for (NSInteger i = 0; i < [self.text length]; i++) {
        NSString *letter = [self.text substringWithRange:NSMakeRange(i, 1)];
        CGSize letterSize = [letter sizeWithFont:[UIFont fontWithName:@"Helvetica" size:numberFontSize]];
        
        CGContextSaveGState(ctx);  // I will need to undo this clip after the letter's gradient has been drawn
        [letter drawAtPoint:CGPointMake(4.0f+(letterSize.width*i), 0.0f) withFont:[UIFont fontWithName:@"Helvetica" size:numberFontSize]];
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

- (void)drawLunarTextInContext:(CGContextRef)ctx
{
	
	if([self.key length] ==8){
		NSDate *thisDay;
		NSCalendar *cal= [NSCalendar currentCalendar];
		NSDateComponents *cmp= [[NSDateComponents alloc] init];
		
		int y = [[self.key substringWithRange:NSMakeRange(0, 4)] intValue];
		int m = [[self.key substringWithRange:NSMakeRange(4, 2)] intValue];
		int d = [[self.key substringWithRange:NSMakeRange(6, 2)] intValue];
		[cmp setYear:y];
		[cmp setMonth:m];
		[cmp setDay:d];
		thisDay = [cal dateFromComponents:cmp];
		[LunarCalendar lunarAtDate:thisDay];
		NSString *lunarText = [LunarCalendar getSolarTerms];
		if(lunarText!=nil && [lunarText length]==0){
			lunarText = [LunarCalendar getLunarFestival];
			if(lunarText!=nil && [lunarText length]==0){
				lunarText = [LunarCalendar getLunarDayChinese];
			}
		}
		if([LunarCalendar getLunarDay] == 1){
			lunarText = [LunarCalendar getLunarMonthChinese];
		}
		DoLog(DEBUG,@"lunar text %@",lunarText);
		
		CGContextSaveGState(ctx);
		CGFloat width = self.bounds.size.width;
		CGFloat numberFontSize = floorf(0.2f * width);
		CGContextSetRGBFillColor(ctx, 0.0f, 0.0f, 0.0f, 1.0f);
		CGContextSetRGBStrokeColor(ctx, 0.3f, 0.3f, 0.3f, 1.0);
		
		for (NSInteger i = 0; i < [lunarText length]; i++) {
			NSString *letter = [lunarText substringWithRange:NSMakeRange(i, 1)];
			CGSize letterSize = [letter sizeWithFont:[UIFont boldSystemFontOfSize:numberFontSize]];
			
			CGContextSaveGState(ctx);  // I will need to undo this clip after the letter's gradient has been drawn
			[letter drawAtPoint:CGPointMake(self.bounds.size.width-(letterSize.width*[lunarText length])+(letterSize.width*i), self.bounds.size.height-letterSize.height) withFont:[UIFont boldSystemFontOfSize:numberFontSize]];
			CGContextRestoreGState(ctx);  // get rid of the clip for the current letter        
		}
		CGContextRestoreGState(ctx);
		[cmp release];
	}
	
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { [[self superview] touchesBegan:touches withEvent:event]; }
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { [[self superview] touchesMoved:touches withEvent:event]; }

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{	
	UITouch *touch = [touches anyObject];
    if ([touch tapCount] == 1){
        //DoLog(DEBUG,@"AAA:::%d",[touch tapCount]);
		if(self.viewController!=nil && self.key!=nil){
			
			[self.viewController setSelectedTile:self key:self.key];
			[self showSelectedView];
			//[self.viewController refreshTableView:self.key];
			
		}
		//[self sendActionsForControlEvents:UIControlEventTouchUpInside];
	}else{
		
        //[[self superview] touchesEnded:touches withEvent:event];
		//DoLog(DEBUG,@"BBB:::%d",[touch tapCount]);
	}
	[[self superview] touchesEnded:touches withEvent:event];
}

- (void) showSelectedView{
	[selectedView removeFromSuperview];
	[self addSubview:selectedView ];
}
- (void) removeSelectedView{
	[selectedView removeFromSuperview];
}




- (void)dealloc {
	[textColor release];
	[_text release];
	[key release];
	[selectedView release];
    [super dealloc];
}


@end
