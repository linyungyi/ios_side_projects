//
//  WeekEventViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeekEventViewController.h"
#import "WeekTableView.h"
#import "MySqlite.h"
#import "DateTimeUtil.h"
#import "ListTodoEvent.h"
#import "CalendarRootViewController.h"
#import "picture.h"

@implementation WeekEventViewController
@synthesize theDay,contentView;
@synthesize calendarRootViewController;
@synthesize tableArray;
@synthesize now;
@synthesize dictionary;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/ 
-(void) showPrevious{
	[self showPreviousWeek];
}
-(void) showFollowing{
	[self showFollowingWeek];
}
- (void)loadView {
	
	self.dictionary = [[NSMutableDictionary alloc] init];

	
	CGRect appFrame = CGRectMake(0, 0, 320, 372);
	contentView = [[MyUIView alloc] initWithFrame:appFrame];
	contentView.delegate=self;
	contentView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:[[picture calendar] objectAtIndex:3]]];
	
	// Header
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320, 30)] autorelease];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[picture calenOther] objectAtIndex:1]]];

    [self addSubviewsToHeaderView:headerView];
	[contentView addSubview:headerView];

	

	
	tableArray=[[NSMutableArray alloc]init];
	[self refreshViewWithPushDirection:0];


	
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	DoLog(DEBUG,@"Week");
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
	[calendarRootViewController release];
	[headerTitleLabel release];
	[contentView release];
	[tableArray release];
	[dictionary release];
	[now release];
    [super dealloc];
}

- (void)addSubviewsToHeaderView:(UIView *)headerView
{
	const CGFloat kChangeMonthButtonWidth = 46.0f;
	const CGFloat kChangeMonthButtonHeight = 30.0f;
	//const CGFloat kMonthLabelWidth = 200.0f;
	const CGFloat kHeaderVerticalAdjust = 1.0f;
	
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
												 kHeaderVerticalAdjust,
												 kChangeMonthButtonWidth,
												 kChangeMonthButtonHeight);
	UIButton *previousMonthButton = [[UIButton alloc] initWithFrame:previousMonthButtonFrame];
	[previousMonthButton setImage:[UIImage imageNamed:[[picture arrow] objectAtIndex:1]] forState:UIControlStateNormal];
	//[previousMonthButton setTitle:@"<" forState:UIControlStateNormal];
	previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	//previousMonthButton.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	//[previousMonthButton setBackgroundColor:[UIColor colorWithRed:0 green:50 blue:50 alpha:1.0f] forState:UIControlStateNormal];
	[previousMonthButton addTarget:self action:@selector(showPreviousWeek) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:previousMonthButton];
	[previousMonthButton release];
	
	// Draw the selected month name centered and at the top of the view
	
	CGRect monthLabelFrame = CGRectMake(100,
										1,
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
	headerTitleLabel.text=@"2010/01/01";
	[headerView addSubview:headerTitleLabel];
	
	// Create the next month button on the right side of the view
	CGRect nextMonthButtonFrame = CGRectMake(320 - kChangeMonthButtonWidth,
											 kHeaderVerticalAdjust,
											 kChangeMonthButtonWidth,
											 kChangeMonthButtonHeight);
	UIButton *nextMonthButton = [[UIButton alloc] initWithFrame:nextMonthButtonFrame];
	
	[nextMonthButton setImage:[UIImage imageNamed:[[picture arrow] objectAtIndex:2]] forState:UIControlStateNormal];
	//[nextMonthButton setTitle:@">" forState:UIControlStateNormal];
	nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	//nextMonthButton.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	[nextMonthButton addTarget:self action:@selector(showFollowingWeek) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:nextMonthButton];
	[nextMonthButton release];
	
}

- (void) showPreviousWeek{
	[self refreshViewWithPushDirection:2];
}
- (void) showFollowingWeek{
	[self refreshViewWithPushDirection:1];
}

- (void) refreshViewWithPushDirection:(NSInteger) type{
	
	NSCalendar *cal=[NSCalendar currentCalendar];
	NSDateComponents *cmp=[[[NSDateComponents alloc] init] autorelease];
	NSInteger flags=NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
	
	// init date data
	if(type == 0)
	{
		[self setNow:[NSDate date]];
		/*
		cmp = [ cal components:flags fromDate:self.now];
		
		NSRange range = [cal rangeOfUnit:NSDayCalendarUnit
								  inUnit:NSMonthCalendarUnit
								 forDate:[cal dateFromComponents:cmp]];*/
		//DoLog(DEBUG,@"%d", range.length);
		//DoLog(DEBUG,@"NOW:%@,CAL:%@,CMP:%@,DAY:%d",self.now,cal,cmp,range.length);
	}else if(type == 1){
		//right 6 months
		/*NSDateComponents *components = [[NSDateComponents alloc] init];
		 [components setMonth:6];
		 [self setNow:[cal dateByAddingComponents:components toDate:self.now options:0]];
		 [components release];*/
		
	}else if(type == 2){
		NSDateComponents *components = [[NSDateComponents alloc] init] ;
		[components setDay:-14];
		[self setNow:[cal dateByAddingComponents:components toDate:self.now options:0]];
		[components release];
	}
	else if(type == 3){
		//viewWiiAppear
		NSDateComponents *components = [[NSDateComponents alloc] init] ;
		[components setDay:-7];
		[self setNow:[cal dateByAddingComponents:components toDate:self.now options:0]];
		[components release];
	}
	//DoLog(DEBUG,@"AAA");
	cmp = [ cal components:flags fromDate:self.now];

	headerTitleLabel.text=[NSString stringWithFormat:@"%d/%d/%d",cmp.year,cmp.month,cmp.day];

	[self clearAndDrawTable];
}
- (void) clearAndDrawTable{
	
	NSCalendar *cal=[NSCalendar currentCalendar];
	NSInteger flags=NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
	
	for(WeekTableView *t in tableArray){
		[t removeFromSuperview];
	}
	[tableArray removeAllObjects];
	
	
	
	
	//# get sqlite data
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];
	comps = [cal components:flags fromDate:self.now];
	[comps setHour: 0];
	[comps setMinute: 0];
	[comps setSecond: 0];
	NSString *startDateTimeString=[DateTimeUtil getStringFromDate:[cal dateFromComponents:comps] forKind:0];
	
	[comps setDay: 6];
	[comps setHour: 23];
	[comps setMinute: 59];
	[comps setSecond: 59];
	NSString *endDateTimeString=[DateTimeUtil getStringFromDate:[cal dateByAddingComponents:comps toDate:self.now options:0] forKind:0];
	DoLog(DEBUG,@"start: %@, end: %@",startDateTimeString,endDateTimeString);
	
	MySqlite *mySqlite=[[MySqlite alloc] init];
	NSArray *listEventData=[mySqlite getListTodoEventFrom:startDateTimeString to:endDateTimeString];
	
	[mySqlite release];
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
	//DoLog(DEBUG,@"count:%d",[self.dictionary count]);
	[listEventData release];
	
	CGFloat width = 320.0f/2.0f;
	CGFloat height= (372.0f-30.0f)/3.0f;
	CGFloat otherHeight= (372.0f-30.0f)/3.0f/2.0f;
	
	NSArray *weekdayNames = [[NSArray alloc] initWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
	for(int k=0;k<7;k++)
	{
		
		NSDateComponents *cmp=[[[NSDateComponents alloc] init] autorelease];
		
		cmp = [ cal components:flags fromDate:self.now];
		NSRange range = [cal rangeOfUnit:NSDayCalendarUnit
								  inUnit:NSMonthCalendarUnit
								 forDate:[cal dateFromComponents:cmp]];
		
		DoLog(DEBUG,@"DRAW NOW:%@,CAL:%@,CMP:%@,DAY:%d,K=%d",self.now,cal,cmp,range.length,k);
		
		WeekTableView *myView;
		
		if(k == 5){
			myView=[[WeekTableView alloc]initWithFrame:CGRectMake(0+width*(5%2),30.0f+height*ceil((5-1)/2.0), width, otherHeight)];
		}else if(k == 6) {
			myView=[[WeekTableView alloc]initWithFrame:CGRectMake(0+width*(5%2),30.0f+height*ceil((5-1)/2.0)+otherHeight, width, otherHeight)];
			
		}else{
			myView=[[WeekTableView alloc]initWithFrame:CGRectMake(0+width*(k%2),30.0f+height*ceil((k-1)/2.0), width, height)];
		}
				/*

		if(k != 0){
			myView=[[WeekTableView alloc]initWithFrame:CGRectMake(0+(320.0/2.0)*((k+1)%2),40+((372.0-40.0)/4)*ceil(k/2.0), 320.0/2.0, (372-40)/4)];
		}else{
			myView=[[WeekTableView alloc]initWithFrame:CGRectMake(0,40+((372.0-40.0)/4)*k, 320.0, (372.0-40.0)/4)];
		}*/
		//myView.backgroundColor=[UIColor clearColor];
		myView.year = cmp.year;
		myView.month = cmp.month;
		myView.day = cmp.day;
		myView.weekday = cmp.weekday;
		myView.title=[NSString stringWithFormat:@"%d/%d/%d %@",cmp.year,cmp.month,cmp.day,[weekdayNames objectAtIndex:(cmp.weekday-1)]];
		NSMutableString *tempString = [NSString stringWithFormat:@"%04d%02d%02d",cmp.year,cmp.month,cmp.day];
		if([self.dictionary objectForKey:tempString] != nil){
			NSMutableArray *mArray = [self.dictionary objectForKey:tempString];
			[myView setEventArray:mArray];
		}
		[myView setCalendarRootViewController:self.calendarRootViewController];
		//myView.backgroundColor=[UIColor whiteColor];
		[contentView addSubview:myView];
		[tableArray addObject:myView];
		[myView release];
		
		NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
		[components setDay:1];
		[self setNow:[cal dateByAddingComponents:components toDate:self.now options:0]];
	}
	self.view = contentView;
	[weekdayNames release];
	
}



@end
