//
//  MonthEventViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MonthEventViewController.h"
#import "CalendarRootViewController.h"
#import "DateTimeUtil.h"
#import "ListTodoEvent.h"
#import "MySqlite.h"

#import "Tile.h"
#import <QuartzCore/QuartzCore.h>
#import "EventDetailViewController.h"
#import	"picture.h"
#import "RuleArray.h"


/*
#define Y_TOLERANCE 20
#define X_TOLERANCE 100
*/


@interface MyUITableView : UITableView

@end
@implementation MyUITableView

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
@end

@interface MonthEventViewController ()
- (void)showPreviousMonth;
- (void)showFollowingMonth;
@end


@implementation MonthEventViewController
@synthesize theDay,contentView;
@synthesize year;
@synthesize month;
@synthesize myTableView;
@synthesize now,cal,today;

@synthesize calendarRootViewController;
@synthesize dictionary;
@synthesize dictionaryKey;
@synthesize myCalendarBg;


/*
 +--------------------------+
 |Header (320,50)           |
 |                          |
 +--------------------------+
 |Calendar (320,37*row)		|
 |                          |
 |                          |
 |                          |
 +--------------------------+
 |tableView                 |
 |(320,372-50-tileH*row)	|
 |							|
 +--------------------------+
 */

-(void) showPrevious{
	[self showPreviousMonth];
}
-(void) showFollowing{
	[self showFollowingMonth];
}

- (void)loadView {
	
	self.dictionary = [[NSMutableDictionary alloc] init];
	
	CGRect appFrame = CGRectMake(0, 0, 320, 372);
	contentView = [[MyUIView alloc] initWithFrame:appFrame];
	contentView.delegate=self;
	contentView.backgroundColor=[UIColor grayColor];
	
	// Header
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320, 50)] autorelease];
    //headerView.backgroundColor = [UIColor grayColor];
	headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[picture calenMonthly] objectAtIndex:4]]];
	
    [self addSubviewsToHeaderView:headerView];
	[contentView addSubview:headerView];
	


	
	myTableView = [[MyUITableView alloc] initWithFrame:CGRectMake(0, 230, 320, 142) style:UITableViewStylePlain];
	myTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[picture calendar] objectAtIndex:2]]];
	//tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	myTableView.dataSource = self;
	myTableView.delegate = self;
	myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[contentView addSubview:myTableView];
	
	myCalendarBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 142)];
	[contentView addSubview:myCalendarBg];
	
	//tileArray 
	tileArray = [[NSMutableArray alloc] init];
	[self refreshViewWithPushDirection:0];

}
/*
- (void)viewWillAppear:(BOOL)animated {
    
	DoLog(DEBUG,@"XXXdd=%d",self.theDay);
	DoLog(DEBUG,@"XXXXXXXX=%@",self.now);
	[self refreshViewWithPushDirection:3]; 
	DoLog(DEBUG,@"DDDDDDDDD=%@",self.now);
	//self.calendarRootViewController.whichView=
	//[self.calendarRootViewController.segmentedControl setSelectedSegmentIndex:1];

	
}*/

- (void)fromYearViewToMonthView:(NSInteger)iYear month:(NSInteger)iMonth {
    
	DoLog(DEBUG,@"fromYearViewToMonthView=%d,%d",iYear,iMonth);
	self.year=iYear;
	self.month=iMonth;
	[self refreshViewWithPushDirection:4];	
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	DoLog(DEBUG,@"Month");
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[myCalendarBg release];
	[contentView release];
	[myTableView release];
	[headerTitleLabel release];
	[tileArray release];
	[now release];
	[cal release];
	[today release];
	[calendarRootViewController release];
	[dictionary release];
	[dictionaryKey release];
    [super dealloc];
}


- (void)addSubviewsToHeaderView:(UIView *)headerView
{
	const CGFloat buttonWidth = 46.0f;
	const CGFloat buttonHeight = 25.0f;
	const CGFloat headerVerticalAdjust = 3.f;
	
	// Header background gradient
	/*
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kal_grid_background.png"]];
	CGRect imageFrame = headerView.frame;
	imageFrame.origin = CGPointZero;
	backgroundView.frame = imageFrame;
	[headerView addSubview:backgroundView];
	[backgroundView release];*/
	
	// Create the previous month button on the left side of the view
	CGRect previousMonthButtonFrame = CGRectMake(0,
												 headerVerticalAdjust,
												 buttonWidth,
												 buttonHeight);
	UIButton *previousMonthButton = [[UIButton alloc] initWithFrame:previousMonthButtonFrame];
	[previousMonthButton setImage:[UIImage imageNamed:[[picture arrow]objectAtIndex:1]] forState:UIControlStateNormal];
	//[previousMonthButton setTitle:@"<" forState:UIControlStateNormal];
	previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	//previousMonthButton.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	//[previousMonthButton setBackgroundColor:[UIColor colorWithRed:0 green:50 blue:50 alpha:1.0f] forState:UIControlStateNormal];
	[previousMonthButton addTarget:self action:@selector(showPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:previousMonthButton];
	[previousMonthButton release];
	
	// Draw the selected month name centered and at the top of the view
	
	CGRect monthLabelFrame = CGRectMake(100,
										0,
										100,
										30);
	headerTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
	headerTitleLabel.backgroundColor = [UIColor clearColor];
	headerTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
	headerTitleLabel.textAlignment = UITextAlignmentCenter;
	headerTitleLabel.textColor = [UIColor colorWithRed:100.0f/255.0f green:44.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
	headerTitleLabel.shadowColor = [UIColor whiteColor];
	headerTitleLabel.shadowOffset = CGSizeMake(0.f, 1.f);
	//[self setHeaderTitleText:[logic selectedMonthNameAndYear]];
	headerTitleLabel.text=@"201001";
	[headerView addSubview:headerTitleLabel];
	
	// Create the next month button on the right side of the view
	CGRect nextMonthButtonFrame = CGRectMake(320 - buttonWidth,
											 headerVerticalAdjust,
											 buttonWidth,
											 buttonHeight);
	UIButton *nextMonthButton = [[UIButton alloc] initWithFrame:nextMonthButtonFrame];
	
	[nextMonthButton setImage:[UIImage imageNamed:[[picture arrow]objectAtIndex:2]] forState:UIControlStateNormal]; 
	//[nextMonthButton setTitle:@">" forState:UIControlStateNormal];
	nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	//nextMonthButton.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	[nextMonthButton addTarget:self action:@selector(showFollowingMonth) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:nextMonthButton];
	[nextMonthButton release];
	/*
	// Add column labels for each weekday (adjusting based on the current locale's first weekday)
	NSArray *weekdayNames = [[NSArray alloc] initWithObjects:@"日", @"一", @"二", @"三", @"四", @"五", @"六", nil];
	//NSUInteger firstWeekday = [[NSCalendar currentCalendar] firstWeekday];
	//NSUInteger i = 0;
	for (CGFloat xOffset = 0; xOffset < 7; xOffset ++) {
		CGRect weekdayFrame = CGRectMake(xOffset*(320/7), 31.0f, 320/7, 20.0f);
		UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
		weekdayLabel.backgroundColor = [UIColor clearColor];
		weekdayLabel.font = [UIFont boldSystemFontOfSize:11.f];
		weekdayLabel.textAlignment = UITextAlignmentCenter;
		weekdayLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.f];
		weekdayLabel.shadowColor = [UIColor whiteColor];
		weekdayLabel.shadowOffset = CGSizeMake(0.f, 1.f);
		weekdayLabel.text = [weekdayNames objectAtIndex:xOffset];
		[headerView addSubview:weekdayLabel];
		[weekdayLabel release];
	}
	[weekdayNames release];*/
	//NSLog(@"SSSSSSS:::%@",[UIFont fontNamesForFamilyName:@"Helvetica"]);
}

- (void) refreshViewWithPushDirection:(NSInteger) type {
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	NSInteger flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
	
	if(type == 0){
		//init
		[self setNow:[NSDate date]];
		[self setCal:[NSCalendar currentCalendar]];
		[self setToday:[NSDate date]];
		
		NSInteger flags=NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
		NSDateComponents *components = [ self.cal components:flags fromDate:self.now];
		[components setDay:1];
		// set now to first day
		[self setNow:[self.cal dateFromComponents:components]];
		
		//NSRange range = [self.cal rangeOfUnit:NSDayCalendarUnit
		//						  inUnit:NSMonthCalendarUnit
		//						 forDate:[self.cal dateFromComponents:cmp]];
		//DoLog(DEBUG,@"%d", range.length);
		//DoLog(DEBUG,@"NOW:%@,CAL:%@,CMP:%@,DAY:%d",self.now,self.cal,cmp,range.length);
	}
	else if(type == 1){
		//to the following month
		NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
		[components setMonth:1];
		[self setNow:[self.cal dateByAddingComponents:components toDate:self.now options:0]];
	}else if(type ==2){
		//to the previous month
		NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
		[components setMonth:-1];
		[self setNow:[self.cal dateByAddingComponents:components toDate:self.now options:0]];
		
	}else if(type == 3){
		// for view will appear 
		
	}else if(type == 4){
		//assign date
		NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
		components = [ self.cal components:flags fromDate:self.now];
		[components setYear:self.year];
		[components setMonth:self.month];

		[self setNow:[self.cal dateFromComponents:components]];
	}

	components= [ self.cal components:flags fromDate:self.now];
	//set header text
	headerTitleLabel.text=[NSString stringWithFormat:@"%d年%d月",components.year,components.month ];
	[self clearAndDrawTile];
	
	// refresh tableView data by type
	if(type == 0){
	}
	else if(type == 1){
		[self refreshTableView:nil];
	}else if(type ==2){
		[self refreshTableView:nil];
		
	}else if(type == 3){
		//viewWillAppear
		if(self.dictionaryKey != nil)
			[self refreshTableView:self.dictionaryKey];
	}else if(type == 4){//assign date
		[self refreshTableView:nil];
	}
}

- (void) clearAndDrawTile {
	
	//clear all tile from view
	for(Tile *t in tileArray){
		[t removeFromSuperview];
	}
	[tileArray removeAllObjects];
	selectedTile =nil;
	
	
	NSInteger flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
	NSDateComponents *cmp = [[[NSDateComponents alloc]init]autorelease];
	NSDateComponents *cmpToday = [[[NSDateComponents alloc]init]autorelease];
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];
	cmp = [self.cal components:flags fromDate:self.now];
	cmpToday = [self.cal components:flags fromDate:self.today];
	
	NSRange range = [self.cal rangeOfUnit:NSDayCalendarUnit
							  inUnit:NSMonthCalendarUnit
							 forDate:[self.cal dateFromComponents:cmp]];
	//DoLog(DEBUG,@"PPP:%@",self.now);
	int first=[cmp weekday];
	//DoLog(DEBUG,@"first:%d",first);

	//# get sqlite data
	components = [self.cal components:flags fromDate:self.now];
	[components setDay: 1];
	[components setHour: 0];
	[components setMinute: 0];
	[components setSecond: 0];
	NSString *startDateTimeString=[DateTimeUtil getStringFromDate:[cal dateFromComponents:components] forKind:0];
	
	[components setDay: range.length];
	[components setHour: 23];
	[components setMinute: 59];
	[components setSecond: 59];
	NSString *endDateTimeString=[DateTimeUtil getStringFromDate:[cal dateFromComponents:components] forKind:0];
	//DoLog(DEBUG,@"start: %@, end: %@",startDateTimeString,endDateTimeString);
	
	MySqlite *mySqlite=[[MySqlite alloc] init];
	NSArray *listEventData=[mySqlite getListTodoEventFrom:startDateTimeString to:endDateTimeString];
	
	[mySqlite release];
	[self.dictionary removeAllObjects];
	for(int i=0;i<[listEventData count];i++){
		ListTodoEvent *listTodoEvent = [listEventData objectAtIndex:i];
		dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
		NSMutableString *tempString = [NSString stringWithFormat:@"%04d%02d%02d",dateStrCmp.year,dateStrCmp.month,dateStrCmp.day];
		if([self.dictionary objectForKey:tempString] == nil ){
			NSMutableArray *mArray = [[NSMutableArray alloc] init];
			[mArray addObject:listTodoEvent];
			[self.dictionary setObject:mArray forKey:tempString];
			[mArray release];
		}else{
			NSMutableArray *mArray = [self.dictionary objectForKey:tempString];
			[mArray addObject:listTodoEvent];
		}
	}
	
	
	/*
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	MySqlite *mySqlite=[[MySqlite alloc] init];
	NSArray *strArray=[mySqlite getTodoEventStartTimeFrom:startDateTimeString to:endDateTimeString];
	[mySqlite release];
	
	
	
	NSMutableString *tempString;
	for(int i=0;i<[strArray count];i++){
		//DoLog(DEBUG,@"starttime:%@",[strArray objectAtIndex:i]);
		NSDateComponents *dateStrcmp = [[[NSDateComponents alloc]init]autorelease];
		dateStrcmp = [DateTimeUtil getDateComponentsFromString:[strArray objectAtIndex:i]];
		tempString = [NSString stringWithFormat:@"%04d%02d%02d",dateStrcmp.year,dateStrcmp.month,dateStrcmp.day];
		// yyyyMMDD => value 0;
		[dictionary setObject:@"0" forKey:tempString];
	}*/
	
	/* for(int i=0;i<[listEventData count];i++){
	 ListTodoEvent *listTodoEvent = [listEventData objectAtIndex:i];
	 DoLog(DEBUG,@"---------------------");
	 DoLog(DEBUG,@"CalendarId:%@",listTodoEvent.calendarId);
	 DoLog(DEBUG,@"user_id:%@",listTodoEvent.userId);
	 DoLog(DEBUG,@"folder_id:%@",listTodoEvent.folderId);
	 DoLog(DEBUG,@"is_synced:%d",listTodoEvent.isSynced);
	 DoLog(DEBUG,@"status:%d",listTodoEvent.status);
	 DoLog(DEBUG,@"AllDayEvent:%d",listTodoEvent.allDayEvent);
	 DoLog(DEBUG,@"DtStamp:%@",listTodoEvent.dtStamp);
	 DoLog(DEBUG,@"EndTime:%@",listTodoEvent.endTime);
	 DoLog(DEBUG,@"Location:%@",listTodoEvent.location);
	 DoLog(DEBUG,@"Reminder:%d",listTodoEvent.reminder);
	 DoLog(DEBUG,@"Subject:%@",listTodoEvent.subject);
	 DoLog(DEBUG,@"event_desc:%@",listTodoEvent.eventDesc);
	 DoLog(DEBUG,@"starttime:%@",listTodoEvent.startTime);
	 DoLog(DEBUG,@"UID:%@",listTodoEvent.uid);
	 DoLog(DEBUG,@"cal_recurrence_id:%@",listTodoEvent.calRecurrenceId);
	 DoLog(DEBUG,@"IsException:%d",listTodoEvent.isException);
	 DoLog(DEBUG,@"Deleted:%d",listTodoEvent.deleted);
	 DoLog(DEBUG,@"memo:%@",listTodoEvent.memo);
	 DoLog(DEBUG,@"server_id:%@",listTodoEvent.serverId);
	 DoLog(DEBUG,@"folder_name:%@",listTodoEvent.folderName);
	 DoLog(DEBUG,@"color_rgb:%d",listTodoEvent.colorRgb);
	 DoLog(DEBUG,@"display_flag:%d",listTodoEvent.displayFlag);
	 
	 }*/
	[listEventData release];
	
	int i=0,j=0;
	int draw =0;
	int rows= ceil((first-1+range.length)/7.0f);
	
	CGFloat tileWidth = 320.0f / 7.0f;
	CGFloat tileHeight = 37.0f;
	
	if(rows == 4){
		myCalendarBg.frame=CGRectMake(0,50,320,148);
		[myCalendarBg setImage:[UIImage imageNamed:[[picture calenMonthly]objectAtIndex:1]]];
	}else if (rows == 5){
		myCalendarBg.frame=CGRectMake(0,50,320,185);
		[myCalendarBg setImage:[UIImage imageNamed:[[picture calenMonthly]objectAtIndex:2]]];
	}else{
		myCalendarBg.frame=CGRectMake(0,50,320,222);
		[myCalendarBg setImage:[UIImage imageNamed:[[picture calenMonthly]objectAtIndex:3]]];
		
	}
	//DoLog(DEBUG,@"ROWS:%d,first:%d,length:%d",rows,first,range.length);
	for(int k=0;k<rows*7;k++)
	{
		if(i==(first-1) && draw==0)
		{
			draw = 1;
		}
		Tile *tile = [[Tile alloc]initWithFrame:CGRectMake(0+i*tileWidth, 50.0+j*tileHeight, tileWidth, tileHeight)];
		tile.viewController=self;
		tile.revealLunarCalendar = YES;
		tile.backgroundColor = [UIColor clearColor];
		tile.textColor= [UIColor colorWithRed:100.0f/255.0f green:44.0f/255.0f blue:0.0f/255.0f alpha:1.0f] ;
		if(draw >= 1 && draw <= range.length){
			tile.text=[NSString stringWithFormat:@"%d",draw];
			//CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
			//CGFloat components[4] = {1.0f, 0.0f, 0.0f, 1.0f};
			//CGColorRef textColor = CGColorCreate(colorspace, components);
			//CGColorSpaceRelease(colorspace);
			//tile.textColor= textColor;
			
			//DoLog(DEBUG,@"%d,%d;%d,%d;%d,%d",cmp.year , cmpToday.year , cmp.month , cmpToday.month , cmp.day , cmpToday.day);
			NSMutableString *tempString = [NSString stringWithFormat:@"%04d%02d%02d",cmp.year,cmp.month,draw];
			if(cmp.year == cmpToday.year && cmp.month == cmpToday.month && draw == cmpToday.day){
				tile.isToday = 1;
				
				UIImageView *a = [[UIImageView alloc] initWithFrame:CGRectMake(0.5f, 0, 45.0f, 36.0f)];
				[a setImage:[UIImage imageNamed:[[picture monthly] objectAtIndex:3]]];
				[tile addSubview:a];
				[a release];
				//tile.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"monthly_today_bg.png"]];
			}
			else{
				
				tile.isToday = 0;
			}
			
			tile.key = tempString;
			if([self.dictionary objectForKey:tempString] !=nil){
				tile.hasEvent = 1;
			}else {
				tile.hasEvent = 0;
			}
			

			
			draw++;
		}
		if(i == 0){
			tile.textColor= [UIColor colorWithRed:254.0f/255.0f green:60.0f/255.0f blue:0.0f/255.0f alpha:1.0f] ;
			tile.isWeekend = 1;
		}
		if(i == 6){
			tile.textColor= [UIColor colorWithRed:111.0f/255.0f green:131.0f/255.0f blue:11.0f/255.0f alpha:1.0f] ;
			tile.isWeekend = 1;
		}
		
		
		//DoLog(DEBUG,@"YYY:%@,%d,%d,%d",tile.text,i,j,draw);
		[contentView addSubview:tile];
		[tileArray addObject:tile];
		
		[tile release];
		
		i++;
		if(i==7){
			i=0;
			j++;
		}
		
	}


	
	myTableView.frame = CGRectMake(0, 50.0f+tileHeight*rows, 320.0f, 372.0f-50.0f-tileHeight*rows);
	
	self.view = contentView;	
	
}


- (void)showPreviousMonth{
	DoLog(DEBUG,@"type left");
	[self refreshViewWithPushDirection:2];
	
}

- (void)showFollowingMonth{
	DoLog(DEBUG,@"type right");
	[self refreshViewWithPushDirection:1];

	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if( [self.dictionary objectForKey:self.dictionaryKey] !=nil){
		NSMutableArray *mArray = [self.dictionary objectForKey:self.dictionaryKey];
		DoLog(DEBUG,@"count:%d",[mArray count]);
		return [mArray count];
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{ 
	return 55.0f; 
} 

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSString *MyIdentifier = [NSString stringWithFormat:@"%d_MonthTableView",indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	
	for(UIView *view in cell.contentView.subviews)
		[view removeFromSuperview];
    
    // Set up the cell...
	NSInteger row=[indexPath row];

	
	if( [self.dictionary objectForKey:self.dictionaryKey] !=nil){
		NSMutableArray *mArray = [self.dictionary objectForKey:self.dictionaryKey];
		ListTodoEvent *listTodoEvent = [mArray objectAtIndex:row];
		//cell.textLabel.text = [NSString stringWithFormat:@"Event %@", listTodoEvent.subject];
		
		
		NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];
		dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
		NSString *timeStr = @"";
		if(listTodoEvent.allDayEvent == 1){
			timeStr = [NSString stringWithFormat:@"整日"];

		}else {
			timeStr =[NSString stringWithFormat:@"%02d:%02d",dateStrCmp.hour,dateStrCmp.minute];
		}
		
		//backgroud picture
		UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 55.0f)];
		[imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"calenfolder_320_%@.png",[RuleArray getColorDictionary:listTodoEvent.colorRgb]]]];
		[cell.contentView addSubview:imgView];
		[imgView release];
		
		
		//add subject
		UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 270.0f, 55.0f)];
		l.backgroundColor = [UIColor clearColor];
		l.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
		l.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
		//l.textAlignment = UITextAlignmentCenter;
		l.text=[NSString stringWithFormat:@"%@  %@",timeStr,listTodoEvent.subject];
		[cell.contentView addSubview:l];
		[l release];
		
		//add icon
		imgView = [[UIImageView alloc] initWithFrame:CGRectMake(270.0f, 7.0f, 40.0f, 40.0f)];
		[imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"eventicon_%@40.png",[RuleArray getEventIcon:[listTodoEvent.eventIcon intValue]]]]];
		[cell.contentView addSubview:imgView];
		[imgView release];
		
		/*
		cell.textLabel.text=[NSString stringWithFormat:@"%@  %@",timeStr,listTodoEvent.subject];
		//cell.textLabel.font=[UIFont fontWithName:@"Arial" size:16];
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
		cell.textLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
		cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"calenfolder_320_%@.png",[RuleArray getColorDictionary:listTodoEvent.colorRgb]]]];
		//cell.imageView.image = [self createFolderImage:CGSizeMake(10.0f,10.0f) bgColor:listTodoEvent.colorRgb];
		 */
	}
	
	
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor]; //must do here in willDisplayCell
    cell.textLabel.backgroundColor = [UIColor clearColor]; //must do here in willDisplayCell
    //cell.textLabel.textColor = [UIColor yellowColor]; //can do here OR in cellForRowAtIndexPath
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	DoLog(DEBUG,@"selected %d",[indexPath row]);
	if( [self.dictionary objectForKey:self.dictionaryKey] !=nil){
		NSMutableArray *mArray = [self.dictionary objectForKey:self.dictionaryKey];
		ListTodoEvent *listTodoEvent = [mArray objectAtIndex:indexPath.row];
		//EventDetailViewController *next = [[[EventDetailViewController alloc]initWithListTodoEvent:listTodoEvent nib:@"EventDetailView" ] autorelease];
		EventDetailViewController *next = [[EventDetailViewController alloc]init];
		next.eId=listTodoEvent.calendarId;
		next.sId=listTodoEvent.serverId;
		self.calendarRootViewController.title=@"<<";
		
		[self.calendarRootViewController.navigationController  pushViewController:next animated:YES];
	}
}


- (void) refreshTableView:(NSString *) iKey{
	if(iKey !=nil){
		self.dictionaryKey = iKey;
	}else{
		self.dictionaryKey = @"none";
	}
	
	[myTableView reloadData];
}

- (void) setSelectedTile:(Tile *) t key:(NSString *) iKey{

	[selectedTile removeSelectedView];
	selectedTile = t;
	
	if(iKey !=nil){
		self.dictionaryKey = iKey;
	}else{
		self.dictionaryKey = @"none";
	}
	
	[myTableView reloadData];
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
