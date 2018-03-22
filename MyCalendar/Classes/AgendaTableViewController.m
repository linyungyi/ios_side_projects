//
//  AgendaTableViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AgendaTableViewController.h"
#import "EventDetailViewController.h"
#import "MySqlite.h"
#import "ListTodoEvent.h"
#import "DateTimeUtil.h"
#import "picture.h"
#import "YearTileView.h"
#import "LunarCalendar.h"
#import "ListTableView.h"
#import "RuleArray.h"

@implementation AgendaTableViewController
@synthesize myTableView;
//@synthesize calendarRootViewController;
@synthesize theDay;
@synthesize now;
@synthesize dataArray,titleArray;
@synthesize contentView;
@synthesize noDataFlag;
@synthesize dayView;
@synthesize dayViewMonthLabel;
@synthesize dayViewDayLabel;
@synthesize dayViewWeeknameLabel;
@synthesize monthView;
@synthesize listBgView;
@synthesize listBtView;
@synthesize listTableView;
@synthesize closeButton;
@synthesize dragButton;
@synthesize listArray;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/
- (void)loadView {
	
	self.title=@"行事曆";
	
	dataArray = [[NSMutableArray alloc] init];
	
	CGRect appFrame = CGRectMake(0.0f, 0.0f, 320.0f, 372.0f);
	contentView = [[UIView alloc] initWithFrame:appFrame];
	//contentView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:[[picture calendar] objectAtIndex:1]]];
	
	//background image
	UIImageView *u = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 455.0f)];
	[u setImage:[UIImage imageNamed:[[picture calendar] objectAtIndex:1]]];
	[contentView addSubview:u];
	[u release];
	
	//drag button image
	u = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 55.0f)];
	[u setImage:[UIImage imageNamed:[[picture calenNotify] objectAtIndex:2]]];
	[contentView addSubview:u];
	[u release];
	
	//drag button
	dragButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0f,2.0f,40.0f,40.0f)];
	[dragButton setTitle:@"0" forState:UIControlStateNormal];
	dragButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	dragButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	//drawButton.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	[dragButton addTarget:self action:@selector(showList) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:dragButton];

	
	//notification image
	u = [[UIImageView alloc]initWithFrame:CGRectMake(80.0f, 5.0f, 140.0f, 36.0f)];
	[u setImage:[UIImage imageNamed:[[picture calenOther] objectAtIndex:2]]];
	[contentView addSubview:u];
	[u release];
	
	//daily calendar
	dayView = [[UIImageView alloc]initWithFrame:CGRectMake(25.0f, 65.0f, 118.0f, 115.0f)];
	[dayView setImage:[UIImage imageNamed:[[picture calenOther] objectAtIndex:3]]];
	dayViewMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 2.0f, 118.0f, 33.0f)];
	dayViewMonthLabel.backgroundColor = [UIColor clearColor];
	dayViewMonthLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
	dayViewMonthLabel.textAlignment = UITextAlignmentCenter;
	dayViewMonthLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
	
	//headerTitleLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kal_header_text_fill.png"]];
	//dayViewMonthLabel.shadowColor = [UIColor whiteColor];
	//dayViewMonthLabel.shadowOffset = CGSizeMake(0.f, 1.f);
	//[self setHeaderTitleText:[logic selectedMonthNameAndYear]];
	dayViewMonthLabel.text=@"";
	[dayView addSubview:dayViewMonthLabel];
	dayViewDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 31.0f, 118.0f, 60.0f)];
	dayViewDayLabel.backgroundColor = [UIColor clearColor];
	dayViewDayLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:54.0f];
	dayViewDayLabel.textAlignment = UITextAlignmentCenter;
	dayViewDayLabel.textColor = [UIColor colorWithRed:50.0f/255.0f green:43.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
	dayViewDayLabel.text=@"";
	[dayView addSubview:dayViewDayLabel];
	dayViewWeeknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 83.0f, 118.0f, 30.0f)];
	dayViewWeeknameLabel.backgroundColor = [UIColor clearColor];
	dayViewWeeknameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
	dayViewWeeknameLabel.textAlignment = UITextAlignmentCenter;
	dayViewWeeknameLabel.textColor = [UIColor colorWithRed:129.0f/255.0f green:104.0f/255.0f blue:92.0f/255.0f alpha:1.0f];
	dayViewWeeknameLabel.text=@"";
	[dayView addSubview:dayViewWeeknameLabel];
	
	[contentView addSubview:dayView];
	
	//draw month
	monthView = [[UIView alloc] initWithFrame:CGRectMake(155.0f, 65.0f, 150.0f, 115.0f)];
	
	[contentView addSubview:monthView];
	
	
	
	
	//CGFloat buttonHeight = 30.0f;
	//CGFloat tableHeight = 372.0f - 30.0f - 30.0f;
	/*
	
	//draw previousButton
	UIButton *previousButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,320.0f,buttonHeight)];
	//[previousButton setImage:[UIImage imageNamed:@"kal_right_arrow.png"] forState:UIControlStateNormal]; 
	[previousButton setTitle:@"之前事件查詢" forState:UIControlStateNormal];
	previousButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	previousButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	previousButton.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	[previousButton addTarget:self action:@selector(showPrevious) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:previousButton];
	[previousButton release];

	//draw nextButton
	UIButton *nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0,buttonHeight+tableHeight,320.0f,buttonHeight)];
	//[nextButton setImage:[UIImage imageNamed:@"kal_right_arrow.png"] forState:UIControlStateNormal]; 
	[nextButton setTitle:@"之後事件查詢" forState:UIControlStateNormal];
	nextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	nextButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	nextButton.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	[nextButton addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
	[contentView addSubview:nextButton];
	[nextButton release];
	*/
	//draw tableView
	myTableView = [[UITableView alloc] initWithFrame:CGRectMake(7.0f, 210.0f, 306.0f, 162.0f) style:UITableViewStylePlain];
	myTableView.dataSource = self;
	myTableView.delegate = self;
	myTableView.backgroundColor =[UIColor clearColor];
	myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[contentView addSubview:myTableView];
	
	
	
	
	
	//view as clicking the drag button
	listArray = [[NSMutableArray alloc] init];
	
	listTableView = [[ListTableView alloc] initWithFrame:CGRectMake(8.0f, 0.0f, 305.0f, 320.0f) style:UITableViewStylePlain];
	listTableView.backgroundColor = [UIColor clearColor];
	listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	listTableView.data = listArray;
	listTableView.calendarRootViewController=self;
	[listTableView reloadData];
	listBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f)];
	[listBgView setImage:[UIImage imageNamed:[[picture calenNotify]objectAtIndex:1]]];
	listBgView.userInteractionEnabled = YES;
	listBtView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 318.0f, 320.0f, 55.0f)];
	[listBtView setImage:[UIImage imageNamed:[[picture calenNotify]objectAtIndex:3]]];
	listBtView.userInteractionEnabled = YES;
	closeButton = [[UIButton alloc] initWithFrame:CGRectMake(26.0f,331.0f,30.0f,30.0f)];
	[closeButton setTitle:@"X" forState:UIControlStateNormal];
	closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	closeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[closeButton addTarget:self action:@selector(closeList) forControlEvents:UIControlEventTouchUpInside];
	
	

	
	self.view = contentView;
	
	[self refreshViewWithPushDirection:0];
	[self drawMonth];
	
	
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES]; 
	
	[self refreshViewWithPushDirection:3];
}

- (void) showList{
	[contentView addSubview:listBgView];
	[contentView addSubview:listTableView];
	[contentView addSubview:listBtView];
	[contentView addSubview:closeButton];
}
- (void) closeList{
	[listBgView removeFromSuperview];
	[listTableView removeFromSuperview];
	[listBtView removeFromSuperview];
	[closeButton removeFromSuperview];
}

- (void) refreshListArray{
	
	//init
	NSCalendar *cal=[NSCalendar currentCalendar];
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];
	
	
	// get sqlite data
	NSString *startDateTimeString=[DateTimeUtil getStringFromDate:self.now forKind:0];
	[components setMonth:5];
	NSString *endDateTimeString=[DateTimeUtil getStringFromDate:[cal dateByAddingComponents:components toDate: self.now options:0] forKind:0];
	//DoLog(DEBUG,@"start: %@, end: %@",startDateTimeString,endDateTimeString);
	
	MySqlite *mySqlite=[[MySqlite alloc] init];
	//NSArray *listEventData=[mySqlite getListTodoEventFrom:startDateTimeString to:endDateTimeString];
	NSArray *listEventData=[mySqlite getAgendaEventsFrom: startDateTimeString to:endDateTimeString limit:9999 offset:0];
	
	
	[mySqlite release];
	//
	[listArray removeAllObjects];
	
	//sqlite data
	//use two layer object array to save data by day
	NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
	int year = 0;
	int month = 0;
	for (int i=0; i< [listEventData count]; i++) {
		
		ListTodoEvent *listTodoEvent = [listEventData objectAtIndex:i];
		
		//int year = 0;
		dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
		if(i == 0){
			year=dateStrCmp.year;
			month=dateStrCmp.month;
		}
		//DoLog(DEBUG,@"iii:::%d,%d,%d,%d,%d",i,dateStrCmp.month,dateStrCmp.day,month,day);
		if(dateStrCmp.year>year || dateStrCmp.month>month){
			
			year=dateStrCmp.year;
			month=dateStrCmp.month;
			[listArray addObject: tmpArray];
			[tmpArray release];
			tmpArray = [[NSMutableArray alloc]init];
		}
		[tmpArray addObject: listTodoEvent];
	}
	if(year != 0)
	{
		[listArray addObject: tmpArray];
	}
	[tmpArray release];
	[dragButton setTitle:[NSString stringWithFormat:@"%d",[listEventData count]] forState:UIControlStateNormal];
	[listEventData release];
	[listTableView reloadData];
	
}

- (void) showNext{
	[self refreshViewWithPushDirection:1];
}

- (void) showPrevious{
	[self refreshViewWithPushDirection:2];
}


- (void) refreshViewWithPushDirection:(NSInteger) type {
	NSCalendar *cal=[NSCalendar currentCalendar];
	if(type == 0){
		//set today to yyyyMMdd000000
		[self setNow: [NSDate date]];//set today
		NSDateComponents *components = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate: self.now];
		[self setNow: [cal dateFromComponents:components]];//set date year,month,day
		
	}
	else if(type == 1){
		NSDateComponents *components = [[NSDateComponents alloc] init] ;
		[components setDay:7];
		[self setNow:[cal dateByAddingComponents:components toDate:self.now options:0]];
		[components release];
	}else if(type ==2){
		NSDateComponents *components = [[NSDateComponents alloc] init];
		[components setDay:-7];
		[self setNow:[cal dateByAddingComponents:components toDate:self.now options:0]];
		[components release];
	}else if(type ==3){
		//viewWillAppear
	}
	
	[self refreshData];
	[self refreshLabel];
	[self refreshListArray];
	
	
}

- (void) drawMonth{
	if(monthView !=nil){
		NSArray *nStr1 = [[NSArray alloc] initWithObjects:@"",@"January",@"Feburary",@"March",@"April",@"May",@"June",@"July",@"Auguest",@"Setember",@"October",@"Nomember",@"December",nil];
		
		
		NSInteger flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
		NSDateComponents *cmp = [[[NSDateComponents alloc]init]autorelease];
		NSDateComponents *cmpToday = [[[NSDateComponents alloc]init]autorelease];

		NSCalendar *cal = [NSCalendar currentCalendar];
		cmpToday = [cal components:flags fromDate:self.now];
		cmp = [cal components:flags fromDate:self.now];
		[cmp setDay:1];
		cmp = [cal components:flags fromDate:[cal dateFromComponents:cmp]];
		NSRange range = [cal rangeOfUnit:NSDayCalendarUnit
						 inUnit:NSMonthCalendarUnit
						 forDate:[cal dateFromComponents:cmp]];
		int first=[cmp weekday];
		
		int i=0,j=0;
		int draw =0;
		int rows= ceil((first-1+range.length)/7.0f);
		
		CGFloat dateHeight = 20.0f;
		CGFloat tileWidth =  monthView.frame.size.width / 7.0f;
		CGFloat tileHeight = (monthView.frame.size.height-dateHeight) / (rows+1);
		UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, monthView.frame.size.width, dateHeight)];
		dateLabel.backgroundColor = [UIColor clearColor];
		dateLabel.font = [UIFont boldSystemFontOfSize:14.0f];
		dateLabel.textAlignment = UITextAlignmentCenter;
		dateLabel.text=[NSString stringWithFormat:@"%d %@",cmp.year,[nStr1 objectAtIndex:cmp.month]];
		dateLabel.textColor = [UIColor colorWithRed:129.0f/255.0f green:104.0f/255.0f blue:92.0f/255.0f alpha:1.0f];
		[monthView addSubview:dateLabel];
		[dateLabel release];
		
		NSArray *weekdayNames = [[NSArray alloc] initWithObjects:@"S", @"M", @"T", @"W", @"T", @"F", @"S", nil];
		for(int k=0;k<7;k++){
			UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(0+k*tileWidth, dateHeight, tileWidth, tileHeight)];
			l.backgroundColor = [UIColor clearColor];
			l.font = [UIFont boldSystemFontOfSize:12.0f];
			l.textAlignment = UITextAlignmentCenter;
			l.text=[weekdayNames objectAtIndex:k];
			l.textColor = [UIColor colorWithRed:181.0f/255.0f green:149.0f/255.0f blue:133.0f/255.0f alpha:1.0f];
			[monthView addSubview:l];
			[l release];
		}
		[weekdayNames release];
		
		for(int k=0;k<rows*7;k++)
		{
			if(i==(first-1) && draw==0)
			{
				draw = 1;
			}
			if(draw >= 1 && draw <= range.length){
				
				UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(0+i*tileWidth, dateHeight+tileHeight+j*tileHeight, tileWidth, tileHeight)];
				l.backgroundColor = [UIColor clearColor];
				//l.font = [UIFont boldSystemFontOfSize:10.0f];
				l.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
				l.textColor = [UIColor colorWithRed:129.0f/255.0f green:104.0f/255.0f blue:92.0f/255.0f alpha:1.0f];
				l.textAlignment = UITextAlignmentCenter;
				l.text=[NSString stringWithFormat:@"%d",draw];
				if(draw == cmpToday.day){
					l.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
					//l.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[picture calenMonthly] objectAtIndex:5]]];
					UIImageView *a = [[UIImageView alloc] initWithFrame:CGRectMake(0+i*tileWidth, dateHeight+tileHeight+j*tileHeight, tileWidth, tileHeight)];
					[a setImage:[UIImage imageNamed:[[picture calenMonthly] objectAtIndex:5]]];
					[monthView addSubview:a];
					[a release];
				}else{
					if(i==0){
						l.textColor = [UIColor colorWithRed:244.0f/255.0f green:96.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
					}
					if(i==6){
						l.textColor = [UIColor colorWithRed:111.0f/255.0f green:131.0f/255.0f blue:11.0f/255.0f alpha:1.0f];
					}
				}
				[monthView addSubview:l];
				[l release];
				draw++;
				
			}
			
			
			
			i++;
			if(i==7){
				i=0;
				j++;
			}
			
		}
		[contentView addSubview:monthView];
		[nStr1 release];
	}
}



- (void) refreshLabel{
	NSArray *nStr1 = [[NSArray alloc] initWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"十二",nil];
	NSArray *weekdayNames = [[NSArray alloc] initWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
	NSCalendar *cal=[NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate: self.now];
	if(components.month >= 0 && components.month< [nStr1 count]);
		dayViewMonthLabel.text=[NSString stringWithFormat:@"%@月",[nStr1 objectAtIndex:components.month]];
	dayViewDayLabel.text=[NSString stringWithFormat:@"%d",components.day];
	[LunarCalendar lunarAtDate:self.now];
	if(components.weekday >0)
		dayViewWeeknameLabel.text=[NSString stringWithFormat:@"%@  農%d, %d",[weekdayNames objectAtIndex:(components.weekday-1)],[LunarCalendar getLunarMonth],[LunarCalendar	 getLunarDay]];
	[nStr1 release];
	[weekdayNames release]; 
}


- (void) refreshData{

	//init
	NSArray *weekdayNames = [[NSArray alloc] initWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
	NSCalendar *cal=[NSCalendar currentCalendar];
	//NSDateComponents *cmp=[[[NSDateComponents alloc] init] autorelease];
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	//NSInteger flags=NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
	NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];


	// get sqlite data
	NSString *startDateTimeString=[DateTimeUtil getStringFromDate:self.now forKind:0];
	[components setDay: 0];
	[components setHour: 23];
	[components setMinute: 59];
	[components setSecond: 59];
	NSString *endDateTimeString=[DateTimeUtil getStringFromDate:[cal dateByAddingComponents:components toDate: self.now options:0] forKind:0];
	//DoLog(DEBUG,@"start: %@, end: %@",startDateTimeString,endDateTimeString);
	
	MySqlite *mySqlite=[[MySqlite alloc] init];
	NSArray *listEventData=[mySqlite getListTodoEventFrom:startDateTimeString to:endDateTimeString];
	
	[mySqlite release];
	/*
	 for(int i=0;i<[listEventData count];i++){
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
	
	
	//
	[dataArray removeAllObjects];
	
	//sqlite data
	//use two layer object array to save data by day
	NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
	int month = 0;
	int day = 0;
	for (int i=0; i< [listEventData count]; i++) {
		
		ListTodoEvent *listTodoEvent = [listEventData objectAtIndex:i];

		//int year = 0;
		dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
		if(i == 0){
			month=dateStrCmp.month;
			day=dateStrCmp.day;
			self.noDataFlag = 0;
			
		}
		//DoLog(DEBUG,@"iii:::%d,%d,%d,%d,%d",i,dateStrCmp.month,dateStrCmp.day,month,day);
		if(dateStrCmp.month>month || dateStrCmp.day>day){
			
			month=dateStrCmp.month;
			day=dateStrCmp.day;
			[dataArray addObject: tmpArray];
			[tmpArray release];
			tmpArray = [[NSMutableArray alloc]init];
		}
		[tmpArray addObject: listTodoEvent];
	}
	if(month != 0)
	{
		[dataArray addObject: tmpArray];
	}else{
		self.noDataFlag = 1;
		/*ListTodoEvent *listTodoEvent=[[ListTodoEvent alloc]init];
		[listTodoEvent setStartTime:startDateTimeString];
		[listTodoEvent setSubject:@"本週無事件"];
		[tmpArray addObject:listTodoEvent];
		[dataArray addObject: tmpArray];
		[listTodoEvent release];*/
	}
	[tmpArray release];
	
	//DoLog(DEBUG,@"count::: %d",[dataArray count]);
	[self.myTableView reloadData];
	[listEventData release];
	[weekdayNames release];

	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
	[listArray release];
	[listBgView release];
	[listBtView release];
	[listTableView release];
	[closeButton release];
	[dragButton release];
	[dayView release];
	[dayViewMonthLabel release];
	[dayViewDayLabel release];
	[dayViewWeeknameLabel release];
	[monthView release];
	//[calendarRootViewController release];
	[now release];
	[myTableView release];
	[dataArray release];
	[contentView release];
    [super dealloc];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if(self.noDataFlag != 1)
		return [dataArray count];
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(self.noDataFlag != 1)
		return [[dataArray objectAtIndex:section] count];
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{ 
	return 65.0; 
} 

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSString *MyIdentifier = [NSString stringWithFormat:@"%d_ListView",indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	
	for(UIView *view in cell.contentView.subviews)
		[view removeFromSuperview];
    
    // Set up the cell...
	if(self.noDataFlag != 1){
		ListTodoEvent *listTodoEvent = [[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		if(listTodoEvent !=nil){
			NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];
			dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
			NSString *timeStr = @"";
			if(listTodoEvent.allDayEvent == 1){
				timeStr = @"整日";
			}else {
				timeStr =[NSString stringWithFormat:@"%02d:%02d",dateStrCmp.hour,dateStrCmp.minute];
			}
			

			//backgroud picture
			UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 306.0f, 60.0f)];
			[imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"calenfolder_%@.png",[RuleArray getColorDictionary:listTodoEvent.colorRgb]]]];
			[cell.contentView addSubview:imgView];
			[imgView release];
			//
			UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 300.0f, 60.0f)];
			l.backgroundColor = [UIColor clearColor];
			l.font = [UIFont fontWithName:@"Arial" size:20];
			//l.textAlignment = UITextAlignmentCenter;
			l.text=[NSString stringWithFormat:@"%@  %@",timeStr,listTodoEvent.subject];
			l.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
			[cell.contentView addSubview:l];
			[l release];
			
			//add icon
			imgView = [[UIImageView alloc] initWithFrame:CGRectMake(266.0f, 15.0f, 30.0f, 30.0f)];
			[imgView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"eventicon_%@.png",[RuleArray getEventIcon:[listTodoEvent.eventIcon intValue]]]]];
			[cell.contentView addSubview:imgView];
			[imgView release];
			
		}
	}
    return cell;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	if(self.noDataFlag != 1){
		ListTodoEvent *listTodoEvent = [[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		if(listTodoEvent !=nil){
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
			cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"calenfolder_320_%@.png",[RuleArray getColorDictionary:listTodoEvent.colorRgb]]]];
			//cell.imageView.image = [self createFolderImage:CGSizeMake(10.0f,10.0f) bgColor:listTodoEvent.colorRgb];
			//cell.imageView.image = [self createFolderImage:CGSizeMake(10.0f,10.0f) bgColor:listTodoEvent.colorRgb];
		
		}
	}	
    return cell;
}*/
/*
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{ 
	NSArray *weekdayNames = [[NSArray alloc] initWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
	if(self.noDataFlag != 1){
		ListTodoEvent *listTodoEvent = [[dataArray objectAtIndex:section] objectAtIndex:0];
		if(listTodoEvent !=nil){
			NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];
			dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
			NSString *weekdayName = [weekdayNames objectAtIndex:(dateStrCmp.weekday-1)];
			[weekdayNames release];
			return [NSString stringWithFormat:@"%d/%d/%d %@",dateStrCmp.year,dateStrCmp.month,dateStrCmp.day,weekdayName];
		}
	}
	NSDateComponents *cmp=[[[NSDateComponents alloc] init] autorelease];
	NSCalendar *cal=[NSCalendar currentCalendar];
	cmp = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:self.now];
	NSString *weekdayName = [weekdayNames objectAtIndex:(cmp.weekday-1)];
	[weekdayNames release];
	return [NSString stringWithFormat:@"%d/%d/%d %@",cmp.year,cmp.month,cmp.day,weekdayName];

} 
 */
/*
- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{ 
	if(section == 0){ 
		return @"之後的事件"; 
	} 
	else{ 
		return @"End of The Others"; 
	} 
}	
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ListTodoEvent *listTodoEvent = [[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	//EventDetailViewController *next = [[[EventDetailViewController alloc]initWithListTodoEvent:listTodoEvent nib:@"EventDetailView" ] autorelease];
	EventDetailViewController *next = [[EventDetailViewController alloc]init];
	next.eId=listTodoEvent.calendarId;
	next.sId=listTodoEvent.serverId;
	//self.calendarRootViewController.title=@"<<";

    [self.navigationController  pushViewController:next animated:YES];
	//DoLog(DEBUG,@"selected %@",[self.calendarRootViewController description]);
	//[next showData];
	
	
/*	NSUInteger row = [indexPath row];
    NSString *myString = [tableDatas objectAtIndex:row];
	
	DoLog(DEBUG,@"%@",myString);
	
	NSRange myRange;
	myRange.location=0;
	myRange.length=3;
	
	NSInteger r = [[myString substringWithRange:myRange]intValue];
	myRange.location=3;
	NSInteger g = [[myString substringWithRange:myRange]intValue];
	myRange.location=6;
	NSInteger b = [[myString substringWithRange:myRange]intValue];
	
	
	self.myLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
	
	[self.myTableView deselectRowAtIndexPath:[self.myTableView indexPathForSelectedRow] animated:NO];*/
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
