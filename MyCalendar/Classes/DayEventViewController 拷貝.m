//
//  DayEventViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DayEventViewController.h"
#import "DayTableView.h"
#import "MySqlite.h"
#import "DateTimeUtil.h"
#import "ListTodoEvent.h"
#import "TouchView.h"

@implementation DayEventViewController
@synthesize theDay,contentView;
@synthesize calendarRootViewController;
@synthesize myTableView;
@synthesize now;
@synthesize dataArray;
@synthesize dictionary;
@synthesize year,month,day;
@synthesize sv;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
	//CGPoint offset = aScrollView.contentOffset;
}

- (void)loadView {
	
	self.dictionary = [[NSMutableDictionary alloc] init];
	dataArray = [[NSMutableArray alloc]init];
	
	CGRect appFrame = CGRectMake(0, 0, 320, 372);
	contentView = [[UIView alloc] initWithFrame:appFrame];
	contentView.backgroundColor=[UIColor blueColor];
	
	// Header
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320, 40)] autorelease];
    headerView.backgroundColor = [UIColor grayColor];
    [self addSubviewsToHeaderView:headerView];
	[contentView addSubview:headerView];
	
	self.sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 40.0f, 320.0f, 332)];
	sv.contentSize = CGSizeMake(320.0f, 60.0*24);
	sv.delegate = self;
	sv.backgroundColor=[UIColor whiteColor];
	
	
	myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 60.0*24) style:UITableViewStylePlain];
	myTableView.dataSource = self;
	myTableView.delegate = self;
	myTableView.scrollEnabled = NO;
	myTableView.allowsSelection = NO;
	//myTableView.userInteractionEnabled = NO;

	[sv addSubview:myTableView];
	[contentView addSubview:sv];
	
	//tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	
	//[contentView addSubview:myTableView];	
	
	
	self.view =contentView;
	[self refreshViewWithPushDirection:0];
	

}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"Day");
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
	[sv release];
	[calendarRootViewController release];
	[contentView release];
	[myTableView release];
	[headerTitleLabel release];
	[now release];
	[dictionary release];
    [super dealloc];
}
- (void)addSubviewsToHeaderView:(UIView *)headerView
{
	const CGFloat kChangeMonthButtonWidth = 46.0f;
	const CGFloat kChangeMonthButtonHeight = 30.0f;
	//const CGFloat kMonthLabelWidth = 200.0f;
	const CGFloat kHeaderVerticalAdjust = 3.f;
	
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

	//[previousMonthButton setImage:[UIImage imageNamed:@"syncicon.png"] forState:UIControlStateNormal];
	[previousMonthButton setTitle:@"<" forState:UIControlStateNormal];
	previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	previousMonthButton.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	//[previousMonthButton setBackgroundColor:[UIColor colorWithRed:0 green:50 blue:50 alpha:1.0f] forState:UIControlStateNormal];
	[previousMonthButton addTarget:self action:@selector(showPreviousDay) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:previousMonthButton];
	[previousMonthButton release];
	
	// Draw the selected month name centered and at the top of the view
	
	CGRect monthLabelFrame = CGRectMake(85,
										3,
										150,
										30);
	headerTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
	headerTitleLabel.backgroundColor = [UIColor grayColor];
	headerTitleLabel.font = [UIFont boldSystemFontOfSize:18.f];
	headerTitleLabel.textAlignment = UITextAlignmentCenter;
	//headerTitleLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kal_header_text_fill.png"]];
	headerTitleLabel.shadowColor = [UIColor whiteColor];
	headerTitleLabel.shadowOffset = CGSizeMake(0.f, 1.f);
	//[self setHeaderTitleText:[logic selectedMonthNameAndYear]];
	headerTitleLabel.text=@"2010/01/01 星期五";
	[headerView addSubview:headerTitleLabel];
	
	// Create the next month button on the right side of the view
	CGRect nextMonthButtonFrame = CGRectMake(320 - kChangeMonthButtonWidth,
											 kHeaderVerticalAdjust,
											 kChangeMonthButtonWidth,
											 kChangeMonthButtonHeight);
	UIButton *nextMonthButton = [[UIButton alloc] initWithFrame:nextMonthButtonFrame];
	
	//[nextMonthButton setImage:[UIImage imageNamed:@"kal_right_arrow.png"] forState:UIControlStateNormal]; 
	[nextMonthButton setTitle:@">" forState:UIControlStateNormal];
	nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	nextMonthButton.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	[nextMonthButton addTarget:self action:@selector(showFollowingDay) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:nextMonthButton];
	[nextMonthButton release];
	
}


- (void) showPreviousDay{
	[self refreshViewWithPushDirection:2];
}
- (void) showFollowingDay{
	[self refreshViewWithPushDirection:1];
}

- (void) refreshViewWithPushDirection:(NSInteger) type{
	
	NSCalendar *cal=[NSCalendar currentCalendar];
	NSDateComponents *cmp=[[[NSDateComponents alloc] init] autorelease];
	NSInteger flags=NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
	NSArray *weekdayNames = [[NSArray alloc] initWithObjects:@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
	// init date data
	if(type == 0){
		[self setNow:[NSDate date]];
	}else if(type == 1){
		NSDateComponents *components = [[NSDateComponents alloc] init] ;
		[components setDay:1];
		[self setNow:[cal dateByAddingComponents:components toDate:self.now options:0]];
		[components release];
		
	}else if(type == 2){
		NSDateComponents *components = [[NSDateComponents alloc] init] ;
		[components setDay:-1];
		[self setNow:[cal dateByAddingComponents:components toDate:self.now options:0]];
		[components release];
	}else if(type == 3){
		//viewWillAppear
	}else if(type == 4){
		NSDateComponents *components = [[NSDateComponents alloc] init] ;
		[components setYear:self.year];
		[components setMonth:self.month];
		[components setDay:self.day];
		[self setNow:[cal dateFromComponents:components]];
		[components release];
	}
	//[myTableView removeFromSuperview];
	NSLog(@"AAA:::%@",now);
	cmp = [ cal components:flags fromDate:self.now];
	
	headerTitleLabel.text=[NSString stringWithFormat:@"%d/%d/%d %@",cmp.year,cmp.month,cmp.day,[weekdayNames objectAtIndex:(cmp.weekday - 1)]];
	
	//get data from sqlite
	//# get sqlite data
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
	NSDateComponents *dateStrCmp=[[[NSDateComponents alloc] init] autorelease];
	comps = [cal components:flags fromDate:self.now];
	[comps setHour: 0];
	[comps setMinute: 0];
	[comps setSecond: 0];
	NSString *startDateTimeString=[DateTimeUtil getStringFromDate:[cal dateFromComponents:comps] forKind:0];
	
	[comps setHour: 23];
	[comps setMinute: 59];
	[comps setSecond: 59];
	NSString *endDateTimeString=[DateTimeUtil getStringFromDate:[cal dateFromComponents:comps] forKind:0];
	NSLog(@"start: %@, end: %@",startDateTimeString,endDateTimeString);
	
	MySqlite *mySqlite=[[MySqlite alloc] init];
	NSArray *listEventData=[mySqlite getListTodoEventFrom:startDateTimeString to:endDateTimeString];
	
	[mySqlite release];
	/*
	 for(int i=0;i<[listEventData count];i++){
	 ListTodoEvent *listTodoEvent = [listEventData objectAtIndex:i];
		 
	 NSLog(@"---------------------");
	 NSLog(@"CalendarId:%@",listTodoEvent.calendarId);
	 NSLog(@"user_id:%@",listTodoEvent.userId);
	 NSLog(@"folder_id:%@",listTodoEvent.folderId);
	 NSLog(@"is_synced:%d",listTodoEvent.isSynced);
	 NSLog(@"status:%d",listTodoEvent.status);
	 NSLog(@"AllDayEvent:%d",listTodoEvent.allDayEvent);
	 NSLog(@"DtStamp:%@",listTodoEvent.dtStamp);
	 NSLog(@"EndTime:%@",listTodoEvent.endTime);
	 NSLog(@"Location:%@",listTodoEvent.location);
	 NSLog(@"Reminder:%d",listTodoEvent.reminder);
	 NSLog(@"Subject:%@",listTodoEvent.subject);
	 NSLog(@"event_desc:%@",listTodoEvent.eventDesc);
	 NSLog(@"starttime:%@",listTodoEvent.startTime);
	 NSLog(@"UID:%@",listTodoEvent.uid);
	 NSLog(@"cal_recurrence_id:%@",listTodoEvent.calRecurrenceId);
	 NSLog(@"IsException:%d",listTodoEvent.isException);
	 NSLog(@"Deleted:%d",listTodoEvent.deleted);
	 NSLog(@"memo:%@",listTodoEvent.memo);
	 NSLog(@"server_id:%@",listTodoEvent.serverId);
	 NSLog(@"folder_name:%@",listTodoEvent.folderName);
	 NSLog(@"color_rgb:%d",listTodoEvent.colorRgb);
	 NSLog(@"display_flag:%d",listTodoEvent.displayFlag);
	 
	 }
	*/
	[self.dictionary removeAllObjects];
	for(int i=0;i<[listEventData count];i++){
		ListTodoEvent *listTodoEvent = [listEventData objectAtIndex:i];
		dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
		NSMutableString *tempString = [NSString stringWithFormat:@"%02d",dateStrCmp.hour];
		NSLog(@"key:%@",tempString);
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
	NSLog(@"count:%d",[self.dictionary count]);
	[listEventData release];	
	/*[dataArray removeAllObjects];
	
	
	
	
	
	
	for(int i=0;i<24;i++){

		NSMutableArray *ttt=[[NSMutableArray alloc]init];
		if(i!=cmp.day)
		{
		for(int j=0;j<5;j++)
		{
			//[ttt addObject:[NSString stringWithFormat:@"hour: %d, event: %d",i,j]];
		}
		}
		[dataArray addObject:ttt];
		[ttt release];
		
	}
	*/
	
	[myTableView  reloadData];
	[weekdayNames release];
}


#pragma mark tableViewDelegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 24;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{ 
	return 60.0; 
} 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//static NSString *MyIdentifier = @"DayView";
	NSString *MyIdentifier = [NSString stringWithFormat:@"%d_DayView",indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	
	for(UIView *view in cell.contentView.subviews)
		[view removeFromSuperview];
	
	
	
	NSString *keyStr= [NSString stringWithFormat:@"%02d",indexPath.row];
	//NSLog(@"key:%@",keyStr);
	CGRect myRect = cell.contentView.frame;
	UIView *myView = [[UIView alloc]initWithFrame:myRect];
	
	
	
	if( [self.dictionary objectForKey:keyStr] !=nil){
		NSMutableArray *mArray=[self.dictionary objectForKey:keyStr];
		
		
		TouchView *button;
		UILabel *mLabel;
		int interval=1;
		float eventW=(myRect.size.width-50)/[mArray count];
		float eventH=myRect.size.height/(60/interval);
		
		ListTodoEvent *listTodoEvent;
		int sH,eH,sM,eM;
		NSRange mRange;
		mRange.location=8;
		mRange.length=4;
		int r,g,b;
		float tmpH=50.0f;
		for(int i=0;i<[mArray count];i++){
			listTodoEvent=[mArray objectAtIndex:i];
			
			r = listTodoEvent.colorRgb/1000000;
			g = (listTodoEvent.colorRgb%1000000)/1000;
			b = (listTodoEvent.colorRgb%1000);
			
			//if(listTodoEvent.allDayEvent!=1){
			sH=[[listTodoEvent.startTime substringWithRange:mRange] intValue];
			eH=[[listTodoEvent.endTime substringWithRange:mRange] intValue];
			
			sM=sH%100;
			sH=sH/100;
			eM=eH%100;
			eH=eH/100;
			
			myRect.origin.x=50+i*eventW;
			myRect.origin.y=(sM/interval)*eventH;
			myRect.size.width=eventW;
			if(listTodoEvent.allDayEvent!=1)
				myRect.size.height=(((eH-sH)*60+(eM-sM))/interval) *eventH;
			else
				myRect.size.height=59;
			
			//NSLog(@"oooooooooooo=%f %f %f %f",myRect.origin.x,myRect.origin.y,myRect.size.width,myRect.size.height);
			
			button=[[TouchView alloc]initWithFrame:myRect];
			//[button setTitle:listTodoEvent.subject forState:UIControlStateNormal];
			button.listTodoEvent=listTodoEvent;
			button.calendarRootViewController=self.calendarRootViewController;
			
			button.backgroundColor=[UIColor blackColor];
			
			
			if((myRect.size.height-tmpH-2)<0)
				tmpH=myRect.size.height-2;
			//NSLog(@"%f %f",myRect.size.height-2,tmpH);
			
			//tmpH=myRect.size.height-2;
			mLabel=[[UILabel alloc]initWithFrame:CGRectMake(1, 1, myRect.size.width-2, tmpH)];
			//mLabel.lineBreakMode=YES;
			//mLabel.adjustsFontSizeToFitWidth=YES;
			mLabel.numberOfLines=2;
			mLabel.font=[UIFont systemFontOfSize:14.0];
			if(listTodoEvent.allDayEvent!=1)
				mLabel.text=[NSString stringWithFormat:@"%@\n%@",listTodoEvent.subject,listTodoEvent.location];
			else
				mLabel.text=[NSString stringWithFormat:@"整日\n%@:%@",listTodoEvent.subject,listTodoEvent.location];
			mLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
			[button addSubview:mLabel];	
			[mLabel release];
			
			if((myRect.size.height-tmpH-2)>0){
				mLabel=[[UILabel alloc]initWithFrame:CGRectMake(1, 1+tmpH, myRect.size.width-2, myRect.size.height-tmpH-2)];
				mLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
				[button addSubview:mLabel];
				[mLabel release];
			}
			
			
			[myView addSubview:button];
			[button release];
		}
	}
	
	
	/*
	NSString *keyStr= [NSString stringWithFormat:@"%02d",indexPath.row];
	//NSLog(@"key:%@",keyStr);
	CGRect myRect = cell.contentView.frame;
	UIView *myView = [[UIView alloc]initWithFrame:myRect];
	
	if( [self.dictionary objectForKey:keyStr] !=nil){
		NSMutableArray *mArray=[self.dictionary objectForKey:keyStr];

		
		TouchView *button;
		UILabel *mLabel;
		int interval=1;
		float eventW=(myRect.size.width-50)/[mArray count];
		float eventH=myRect.size.height/(60/interval);
		
		ListTodoEvent *listTodoEvent;
		int sH,eH,sM,eM;
		NSRange mRange;
		mRange.location=8;
		mRange.length=4;
		int r,g,b;
		float tmpH=50.0f;
		for(int i=0;i<[mArray count];i++){
			listTodoEvent=[mArray objectAtIndex:i];
			
			r = listTodoEvent.colorRgb/1000000;
			g = (listTodoEvent.colorRgb%1000000)/1000;
			b = (listTodoEvent.colorRgb%1000);
			
			//if(listTodoEvent.allDayEvent!=1){
			sH=[[listTodoEvent.startTime substringWithRange:mRange] intValue];
			eH=[[listTodoEvent.endTime substringWithRange:mRange] intValue];
			
			sM=sH%100;
			sH=sH/100;
			eM=eH%100;
			eH=eH/100;
			
			myRect.origin.x=50+i*eventW;
			myRect.origin.y=(sM/interval)*eventH;
			myRect.size.width=eventW;
			if(listTodoEvent.allDayEvent!=1)
				myRect.size.height=(((eH-sH)*60+(eM-sM))/interval) *eventH;
			else
				myRect.size.height=59;
			
			//NSLog(@"oooooooooooo=%f %f %f %f",myRect.origin.x,myRect.origin.y,myRect.size.width,myRect.size.height);
			
			button=[[TouchView alloc]initWithFrame:myRect];
			//[button setTitle:listTodoEvent.subject forState:UIControlStateNormal];
			button.listTodoEvent=listTodoEvent;
			button.calendarRootViewController=self.calendarRootViewController;
			
			button.backgroundColor=[UIColor blackColor];
			
			
			if((myRect.size.height-tmpH-2)<0)
				tmpH=myRect.size.height-2;
			//NSLog(@"%f %f",myRect.size.height-2,tmpH);
			
			//tmpH=myRect.size.height-2;
			mLabel=[[UILabel alloc]initWithFrame:CGRectMake(1, 1, myRect.size.width-2, tmpH)];
			//mLabel.lineBreakMode=YES;
			//mLabel.adjustsFontSizeToFitWidth=YES;
			mLabel.numberOfLines=2;
			mLabel.font=[UIFont systemFontOfSize:14.0];
			if(listTodoEvent.allDayEvent!=1)
				mLabel.text=[NSString stringWithFormat:@"%@\n%@",listTodoEvent.subject,listTodoEvent.location];
			else
				mLabel.text=[NSString stringWithFormat:@"整日\n%@:%@",listTodoEvent.subject,listTodoEvent.location];
			mLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
			[button addSubview:mLabel];	
			[mLabel release];
			
			if((myRect.size.height-tmpH-2)>0){
				mLabel=[[UILabel alloc]initWithFrame:CGRectMake(1, 1+tmpH, myRect.size.width-2, myRect.size.height-tmpH-2)];
				mLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
				[button addSubview:mLabel];
				[mLabel release];
			}
			
			
			[myView addSubview:button];
			[button release];
			/*
			}else{
				button=[[TouchView alloc]initWithFrame:myRect];
				button.listTodoEvent=listTodoEvent;
				button.calendarRootViewController=self.calendarRootViewController;
				UIButton *mButton=[[UIButton alloc]initWithFrame:CGRectMake(1, 1, myRect.size.width, myRect.size.height)];
				[mButton setTitle:[NSString stringWithFormat:@"整日:%@",listTodoEvent.subject] forState:UIControlStateNormal];
				mButton.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
				[button addSubview:mButton];
				[mLabel release];
				[myView addSubview:button];
				[button release];
			}
			*/
		/*}
		
		/*
		myRect.origin.x=50;
		myRect.origin.y=0;
		myRect.size.width=myRect.size.width-50;
		myRect.size.height=60;
		DayTableView *ttt=[[DayTableView alloc]initWithFrame:myRect];
		[ttt setEventArray:mArray];
		[ttt setCalendarRootViewController:self.calendarRootViewController];
		[myView addSubview:ttt];
		[ttt release];
		 */
	/*}*/
	
	myRect.origin.x=0;
	myRect.origin.y=0;
	myRect.size.width=50.0;
	myRect.size.height=60.0;
	UILabel *myLabel = [[UILabel alloc]initWithFrame:myRect];
	//myLabel = [[UILabel alloc]initWithFrame:myRect];
	
	myLabel.text=[NSString stringWithFormat:@"%d:00",indexPath.row];
	myLabel.backgroundColor=[UIColor orangeColor];
	[myView addSubview:myLabel];
	[myLabel release];
	
	[cell.contentView addSubview:myView];
	[myView release];
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//[cell setText:@"No Data For Now"];
	
	return cell;
	
}/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	
}*/

- (void) fromWeekViewToDayViewForYear:(NSInteger)iYear Month:(NSInteger)iMonth Day:(NSInteger)iDay{
	
	self.year = iYear;
	self.month = iMonth;
	self.day = iDay;
	[self refreshViewWithPushDirection:4];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.myTableView deselectRowAtIndexPath:[self.myTableView indexPathForSelectedRow] animated:NO];
}



@end
