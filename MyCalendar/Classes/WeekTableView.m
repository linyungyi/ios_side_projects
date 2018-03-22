//
//  WeekTableView.m
//  MyCalendar
//
//  Created by app on 2010/3/18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeekTableView.h"
#import "ListTodoEvent.h"
#import "DateTimeUtil.h"
#import "DayEventViewController.h"
#import "RuleArray.h"
#import "picture.h"

@implementation WeekTableView
@synthesize eventArray,title;
@synthesize calendarRootViewController;
@synthesize year,month,day,weekday;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{ 
	[super touchesBegan:touches withEvent:event];
	[[self superview] touchesBegan:touches withEvent:event]; 
}
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event{	
	[super touchesEnded:touches withEvent:event];
	[[self superview] touchesEnded:touches withEvent:event];
}
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{	
	[super touchesMoved:touches withEvent:event];
	[[self superview] touchesMoved:touches withEvent:event];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.dataSource=self;
		self.delegate=self;
		self.eventArray = [[NSMutableArray alloc]init];
		self.backgroundColor = [UIColor clearColor];
		self.separatorStyle=UITableViewCellSeparatorStyleNone;
	}
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	[eventArray release];
	[title release];
	[calendarRootViewController release];
    [super dealloc];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.eventArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{ 
	return 25.0; 
} 


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSString *MyIdentifier = [NSString stringWithFormat:@"%d_WeekTableView",indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}

	
	for(UIView *view in cell.contentView.subviews)
		[view removeFromSuperview];	
	
	
    // Set up the cell...
	int row = [indexPath row];
	if([self.eventArray objectAtIndex:row] != nil){
		ListTodoEvent *listTodoEvent = [self.eventArray objectAtIndex:row];
		//cell.textLabel.text = [NSString stringWithFormat:@"%@",listTodoEvent.subject];
		
		NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];
		dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
		NSString *timeStr = @"";
		if(listTodoEvent.allDayEvent == 1){
			timeStr = @"整日";
		}else {
			timeStr =[NSString stringWithFormat:@"%02d:%02d",dateStrCmp.hour,dateStrCmp.minute];
		}
		
		cell.contentView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"weekly_listbg_%@.png",[RuleArray getColorDictionary:listTodoEvent.colorRgb]]]];
		
		UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 30.0f, 25.0f)];
		l.backgroundColor = [UIColor clearColor];
		l.font = [UIFont fontWithName:@"Arial" size:11];
		//l.textAlignment = UITextAlignmentCenter;
		l.text=[NSString stringWithFormat:@"%@",timeStr];
		l.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
		[cell.contentView addSubview:l];
		[l release];
		
		l = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 0.0f, 120.0f, 25.0f)];
		l.backgroundColor = [UIColor clearColor];
		l.font = [UIFont fontWithName:@"Arial" size:14];
		//l.textAlignment = UITextAlignmentCenter;
		l.text=[NSString stringWithFormat:@"%@",listTodoEvent.subject];
		l.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
		[cell.contentView addSubview:l];
		[l release];
		/*
		cell.textLabel.text=[NSString stringWithFormat:@"%@  %@",timeStr,listTodoEvent.subject];
		cell.textLabel.font=[UIFont fontWithName:@"Arial" size:14];
		cell.textLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
		//cell.imageView.image = [self createFolderImage:CGSizeMake(10.0f,10.0f) bgColor:listTodoEvent.colorRgb];
		*/
		
	}
	
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section       
{
    //UIView *v=[[UIView alloc] init];
    //[v setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"titlebg_weekday.png"]]];

	UILabel *t = [[UILabel alloc] init];
	t.text = self.title;
	t.font = [UIFont fontWithName:@"Helvetica"size:14.0f];
	
	if(self.weekday == 1 || self.weekday == 7){
		t.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[picture titlebg] objectAtIndex:3]]];
		t.textColor = [UIColor colorWithRed:234.0f/255.0f green:215.0f/255.0f blue:182.0f/255.0f alpha:1.0f];
	}else{
		t.textColor = [UIColor colorWithRed:100.0f/255.0f green:44.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
		t.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[picture titlebg] objectAtIndex:2]]];
	}
	
	
    return t;
}
/*
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{ 
	 return self.title; 

 } */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.calendarRootViewController.segmentedControl setSelectedSegmentIndex:3];
	[self.calendarRootViewController.dayEventViewController fromWeekViewToDayViewForYear:self.year	Month:self.month Day:self.day];
}



- (UIImage *) createFolderImage:(CGSize) mySize bgColor:(NSInteger) myColor	{
	UIImage *result;
	//UIGraphicsBeginImageContext (size); 
	UIGraphicsBeginImageContext(CGSizeMake(20.0, 20.0));
	
	CGRect myRect=CGRectMake(5, 5, mySize.width, mySize.height);
	
	NSInteger r = myColor/1000000;
	NSInteger g = (myColor%1000000)/1000;
	NSInteger b = (myColor%1000);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f] setFill];
	CGContextFillRect(context,myRect);
	
	result = UIGraphicsGetImageFromCurrentImageContext(); 
	UIGraphicsEndImageContext(); 
	return result; 
} 

@end
