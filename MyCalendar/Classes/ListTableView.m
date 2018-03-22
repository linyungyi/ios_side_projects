//
//  ListTableView.m
//  MyCalendar
//
//  Created by app on 2010/5/4.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ListTableView.h"
#import "ListTodoEvent.h"
#import "DateTimeUtil.h"
#import "EventDetailViewController.h"
#import "picture.h"
#import "RuleArray.h"


@implementation ListTableView
@synthesize data;
@synthesize calendarRootViewController;

- (id)initWithFrame:(CGRect)frame style:(NSInteger) s {
    if (self = [super initWithFrame:frame style:s]) {
        // Initialization code
		self.dataSource=self;
		self.delegate=self;
		//self.backgroundColor = [UIColor colorWithPatternImage:[UIImage	imageNamed:@"calen_notify_bg.png"]];
		
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [data count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[data objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{ 
	return 70.0f; 
} 

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSString *MyIdentifier = [NSString stringWithFormat:@"%d_ListTableView",indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	
	for(UIView *view in cell.contentView.subviews)
		[view removeFromSuperview];
	
	NSArray *nStr1 = [[NSArray alloc] initWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"十二",nil];
	CGFloat heght= 65.0;
	
	ListTodoEvent *listTodoEvent = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	if(listTodoEvent !=nil){
		NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];
		dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
		//NSDateComponents *dateStrCmp2=[[[NSDateComponents alloc] init] autorelease];
		NSDateComponents *dateStrCmp2 =[DateTimeUtil getDateComponentsFromString:listTodoEvent.endTime];
		//NSCalendar *cal= [NSCalendar currentCalendar];
		
		// how many days 
		NSDateComponents *cmp=[[[NSDateComponents alloc] init] autorelease];
		cmp = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit	fromDate:[NSDate date]];
		int dayCount = ([[[NSCalendar currentCalendar] dateFromComponents:dateStrCmp] timeIntervalSinceReferenceDate] - [[[NSCalendar currentCalendar] dateFromComponents:cmp] timeIntervalSinceReferenceDate])/86400;
		
		//get time string
		NSString *timeStr = @"";
		if(listTodoEvent.allDayEvent == 1){
			timeStr = @"整日";
		}else {
			timeStr =[NSString stringWithFormat:@"%02d:%02d-%02d:%02d",dateStrCmp.hour,dateStrCmp.minute,dateStrCmp2.hour,dateStrCmp2.minute];
		}
		NSString *dayStr = @"";
		dayStr = [NSString stringWithFormat:@"%d",dateStrCmp.day];
		NSString *monthStr = @"";
		if(dateStrCmp.month>0 && dateStrCmp.month<=13)
			monthStr = [NSString stringWithFormat:@"%@月",[nStr1 objectAtIndex:dateStrCmp.month]];
		
		//get location
		NSString *locationStr = @"";
		locationStr = listTodoEvent.location;
		//get subject
		NSString *subjectStr = @"";
		subjectStr = listTodoEvent.subject;
		
		//add background picture
		UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 305.0f, 70.0f)];
		[imgView setImage:[UIImage imageNamed:[[picture calenlist]objectAtIndex:1]]];
		[cell.contentView addSubview:imgView];
		[imgView release];
		
		//add month
		UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 5.0f, 58.0f, 18.0f)];
		l.backgroundColor = [UIColor clearColor];
		l.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
		l.textColor = [UIColor colorWithRed:129.0f/255.0f green:104.0f/255.0f blue:92.0f/255.0f alpha:1.0f];
		l.textAlignment = UITextAlignmentCenter;
		l.text=[NSString stringWithFormat:@"%@",monthStr];
		[cell.contentView addSubview:l];
		[l release];
		//add day
		l = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 23.0f, 58.0f, 47.0f)];
		l.backgroundColor = [UIColor clearColor];
		l.font = [UIFont fontWithName:@"Helvetica-Bold" size:36.0f];
		l.textColor = [UIColor colorWithRed:55.0f/255.0f green:48.0f/255.0f blue:43.0f/255.0f alpha:1.0f];
		l.textAlignment = UITextAlignmentCenter;
		l.text=[NSString stringWithFormat:@"%@",dayStr];
		[cell.contentView addSubview:l];
		[l release];
		
		//add folder bar
		imgView = [[UIImageView alloc] initWithFrame:CGRectMake(58.0f, 0.0f, 6.0f, 70.0f)];
		[imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"calen_colorbar_%@.png",[RuleArray getColorDictionary:listTodoEvent.colorRgb]]]];
		[cell.contentView addSubview:imgView];
		[imgView release];
		
		
		//add subject
		l = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 3.0f, 230.0f, heght*3.0f/5.0f)];
		l.backgroundColor = [UIColor clearColor];
		l.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
		l.textColor = [UIColor colorWithRed:50.0f/255.0f green:43.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
		//l.textAlignment = UITextAlignmentCenter;
		l.text=[NSString stringWithFormat:@"%@",subjectStr];
		[cell.contentView addSubview:l];
		[l release];
		//add location
		l = [[UILabel alloc] initWithFrame:CGRectMake(70.0f, 1.0f+heght*3.0f/5.0f, 230.0f, heght*1.0f/5.0f)];
		l.backgroundColor = [UIColor clearColor];
		l.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
		l.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
		//l.textAlignment = UITextAlignmentCenter;
		l.text=[NSString stringWithFormat:@"%@",locationStr];
		[cell.contentView addSubview:l];
		[l release];
		//add time
		l = [[UILabel alloc] initWithFrame:CGRectMake(70.0f,1.0f+heght*4.0f/5.0f, 230.0f, heght*1.0f/5.0f)];
		l.backgroundColor = [UIColor clearColor];
		l.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
		l.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
		//l.textAlignment = UITextAlignmentCenter;
		l.text=[NSString stringWithFormat:@"%@",timeStr];
		[cell.contentView addSubview:l];
		[l release];
		//add how many days;
		l = [[UILabel alloc] initWithFrame:CGRectMake(260.0f,1.0f+heght*4.0f/5.0f, 50.0f, heght*1.0f/5.0f)];
		l.backgroundColor = [UIColor clearColor];
		l.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
		l.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
		//l.textAlignment = UITextAlignmentCenter;
		if(dayCount == 0){
			l.text=[NSString stringWithFormat:@"今天"];
		}else if(dayCount ==1){
			l.text=[NSString stringWithFormat:@"明天"];
		}else if(dayCount ==2){
			l.text=[NSString stringWithFormat:@"後天"];
		}else{
			l.text=[NSString stringWithFormat:@"%d天",dayCount];
		}
		
		[cell.contentView addSubview:l];
		[l release];
		
		//add icon
		imgView = [[UIImageView alloc] initWithFrame:CGRectMake(250.0f, 8.0f, 40.0f, 40.0f)];
		[imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"eventicon_%@40.png",[RuleArray getEventIcon:[listTodoEvent.eventIcon intValue]]]]];
		[cell.contentView addSubview:imgView];
		[imgView release];

	}
    [nStr1 release];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section       
{
    //UIView *v=[[UIView alloc] init];
    //[v setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"titlebg_weekday.png"]]];
	
	UILabel *t = [[UILabel alloc] init];
	ListTodoEvent *listTodoEvent = [[data objectAtIndex:section] objectAtIndex:0];
	if(listTodoEvent !=nil){
		NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];
		dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
		t.text = [NSString stringWithFormat:@"%d年%d月",dateStrCmp.year,dateStrCmp.month];
		t.font = [UIFont fontWithName:@"Arial" size:14.0f];
		t.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
	}
	t.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[picture calenlist] objectAtIndex:2]]];
	
    return t;
}
/*
 - (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{ 
	 ListTodoEvent *listTodoEvent = [[data objectAtIndex:section] objectAtIndex:0];
	 if(listTodoEvent !=nil){
		NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];
		 dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
		 return [NSString stringWithFormat:@"%d年%d月",dateStrCmp.year,dateStrCmp.month];
	 }
	 return @"";
 } */
 
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor]; //must do here in willDisplayCell
    cell.textLabel.backgroundColor = [UIColor clearColor]; //must do here in willDisplayCell
    //cell.textLabel.textColor = [UIColor yellowColor]; //can do here OR in cellForRowAtIndexPath
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ListTodoEvent *listTodoEvent = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	//EventDetailViewController *next = [[[EventDetailViewController alloc]initWithListTodoEvent:listTodoEvent nib:@"EventDetailView" ] autorelease];
	EventDetailViewController *next = [[EventDetailViewController alloc]init];
	next.eId=listTodoEvent.calendarId;
	next.sId=listTodoEvent.serverId;
	if([self.calendarRootViewController.title length]<=0)
		self.calendarRootViewController.title=@"<<";
	
    [self.calendarRootViewController.navigationController  pushViewController:next animated:YES];
	DoLog(DEBUG,@"selected %@",[self.calendarRootViewController description]);

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
