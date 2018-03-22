//
//  DayTableView.m
//  MyCalendar
//
//  Created by app on 2010/3/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DayTableView.h"
#import "ListTodoEvent.h"
#import "DateTimeUtil.h"



@implementation DayTableView

@synthesize eventArray;
@synthesize calendarRootViewController;;



- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.dataSource=self;
		self.delegate=self;
		self.eventArray = [[NSMutableArray alloc]init];
	}
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	[eventArray release];
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
	return 20.0; 
} 


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
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
		
		
		cell.textLabel.text=[NSString stringWithFormat:@"%@  %@",timeStr,listTodoEvent.subject];
		cell.textLabel.font=[UIFont fontWithName:@"Arial" size:16];
		cell.imageView.image = [self createFolderImage:CGSizeMake(10.0f,10.0f) bgColor:listTodoEvent.colorRgb];
		
		
	}
	
    return cell;
}


/*
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{ 
	return self.title; 
	
} */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//[self.calendarRootViewController.segmentedControl setSelectedSegmentIndex:3];
	if( [self.eventArray objectAtIndex:indexPath.row] !=nil){
		ListTodoEvent *listTodoEvent = [self.eventArray objectAtIndex:indexPath.row];
		//EventDetailViewController *next = [[[EventDetailViewController alloc]initWithListTodoEvent:listTodoEvent nib:@"EventDetailView" ] autorelease];
		EventDetailViewController *next = [[EventDetailViewController alloc]init];
		next.eId=listTodoEvent.calendarId;
		next.sId=listTodoEvent.serverId;
		
		self.calendarRootViewController.title=@"<<";
		
		[self.calendarRootViewController.navigationController  pushViewController:next animated:YES];
	}
	
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


