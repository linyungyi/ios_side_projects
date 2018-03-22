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
#import "picture.h"
#import "RuleArray.h"

@interface MyUIScrollView : UIScrollView

@end
@implementation MyUIScrollView

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



@implementation DayEventViewController
@synthesize theDay,contentView;
@synthesize calendarRootViewController;
@synthesize now;
@synthesize dataArray;
@synthesize dictionary;
@synthesize year,month,day;
@synthesize sv;
@synthesize labelArray;
@synthesize touchViewArray;
@synthesize allDayEventView;
@synthesize allDayEventArray;


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
	//DoLog(INFO,@"%f %f",aScrollView.contentOffset.x,aScrollView.contentOffset.y);
}

-(void) showPrevious{
	[self showPreviousDay];
}
-(void) showFollowing{
	[self showFollowingDay];
}

- (void)loadView {
	
	self.dictionary = [[NSMutableDictionary alloc] init];
	dataArray = [[NSMutableArray alloc]init];
	labelArray = [[NSMutableArray alloc]init];
	touchViewArray = [[NSMutableArray alloc]init];
	allDayEventArray = [[NSMutableArray alloc]init];
	
	CGFloat headerHeight = 20.0f;
	CGFloat allDayeEventHeight = 25.0f;
	CGFloat timeLineAdjust = 6.0f;
	CGFloat timeAxisWidth = 50.0f;
	CGFloat timeLineHeight = 46.0f;
	CGFloat timeLineWidth = 320.0f - timeAxisWidth;
	
	CGRect appFrame = CGRectMake(0.0f, 0.0f, 320.0f, 372.0f);
	contentView = [[MyUIView alloc] initWithFrame:appFrame];
	contentView.delegate=self;
	contentView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:[[picture calendar] objectAtIndex:2]]];

	
	// Header
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320, headerHeight)] autorelease];
    //headerView.backgroundColor = [UIColor clearColor];
	headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[picture daily] objectAtIndex:4]]];
    [self addSubviewsToHeaderView:headerView];
	[contentView addSubview:headerView];
	// all day event
	allDayEventView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, headerHeight, 320, allDayeEventHeight)];
    allDayEventView.backgroundColor = [UIColor clearColor];
	[contentView addSubview:allDayEventView];
	
	// scroll view
	self.sv = [[MyUIScrollView alloc] initWithFrame:CGRectMake(0.0f, headerHeight+allDayeEventHeight, 320.0f, (372.0f-headerHeight-allDayeEventHeight))];
	sv.contentSize = CGSizeMake(320.0f, (timeLineAdjust+timeLineHeight*24));
	sv.delegate = self;
	sv.backgroundColor=[UIColor clearColor];
	//add timeaxis
	UIImageView *backgroudImg = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,0.0f,timeAxisWidth,timeLineAdjust+timeLineHeight*24)];
	[backgroudImg setImage:[UIImage imageNamed:[[picture daily] objectAtIndex:1]]];
	[sv addSubview:backgroudImg];
	[backgroudImg release];
	//add timeline
	for(int i=0;i<24;i++){
		UIImageView *backgroudImg = [[UIImageView alloc] initWithFrame:CGRectMake(timeAxisWidth,timeLineAdjust+timeLineHeight*i,timeLineWidth,timeLineHeight)];
		[backgroudImg setImage:[UIImage imageNamed:[[picture daily] objectAtIndex:2]]];
		[sv addSubview:backgroudImg];
		[backgroudImg release];
	}
	
	
	[contentView addSubview:sv];
	
	self.view =contentView;
	[self refreshViewWithPushDirection:0];
	

}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	DoLog(DEBUG,@"Day");
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
	[allDayEventArray release];
	[allDayEventView release];
	[touchViewArray release];
	[labelArray release];
	[sv release];
	[calendarRootViewController release];
	[contentView release];
	[headerTitleLabel release];
	[now release];
	[dictionary release];
    [super dealloc];
}
- (void)addSubviewsToHeaderView:(UIView *)headerView
{
	const CGFloat kChangeMonthButtonWidth = 46.0f;
	const CGFloat kChangeMonthButtonHeight = 20.0f;
	//const CGFloat kMonthLabelWidth = 200.0f;
	const CGFloat kHeaderVerticalAdjust = 1.f;
	
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
	[previousMonthButton setImage:[UIImage imageNamed:[[picture arrow]objectAtIndex:1]] forState:UIControlStateNormal];
	//[previousMonthButton setImage:[UIImage imageNamed:@"syncicon.png"] forState:UIControlStateNormal];
	//[previousMonthButton setTitle:@"<" forState:UIControlStateNormal];
	previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	//previousMonthButton.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	//[previousMonthButton setBackgroundColor:[UIColor colorWithRed:0 green:50 blue:50 alpha:1.0f] forState:UIControlStateNormal];
	[previousMonthButton addTarget:self action:@selector(showPreviousDay) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:previousMonthButton];
	[previousMonthButton release];
	
	// Draw the selected month name centered and at the top of the view
	
	CGRect monthLabelFrame = CGRectMake(85,
										0,
										150,
										20);
	headerTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
	headerTitleLabel.backgroundColor = [UIColor clearColor];
	headerTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
	headerTitleLabel.textAlignment = UITextAlignmentCenter;
	headerTitleLabel.textColor = [UIColor colorWithRed:100.0f/255.0f green:44.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
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
	[nextMonthButton setImage:[UIImage imageNamed:[[picture arrow]objectAtIndex:2]] forState:UIControlStateNormal];
	//[nextMonthButton setImage:[UIImage imageNamed:@"kal_right_arrow.png"] forState:UIControlStateNormal]; 
	//[nextMonthButton setTitle:@">" forState:UIControlStateNormal];
	nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	//nextMonthButton.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
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
	DoLog(DEBUG,@"AAA:::%@",now);
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
	DoLog(DEBUG,@"start: %@, end: %@",startDateTimeString,endDateTimeString);
	
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
	 
	 }
	*/
	[self.dictionary removeAllObjects];
	for(int i=0;i<[listEventData count];i++){
		ListTodoEvent *listTodoEvent = [listEventData objectAtIndex:i];
		dateStrCmp = [DateTimeUtil getDateComponentsFromString:listTodoEvent.startTime];
		NSMutableString *tempString = [NSString stringWithFormat:@"%02d",dateStrCmp.hour];
		DoLog(DEBUG,@"key:%@",tempString);
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
	DoLog(DEBUG,@"count:%d",[self.dictionary count]);
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
	[self clearAndDraw];

	[weekdayNames release];
}

- (void) clearAndDraw{
	
	CGFloat labelWidth = 50.0f;
	CGFloat labelHourHeight = 12.0f;
	CGFloat labelMinuteHeight = 10.0f;
	//CGFloat touchViewWidth = 320.0f - labelWidth;
	CGFloat touchViewHeight = 46.0f;
	CGFloat timeLineAdjust = 6.0f;
	CGFloat labelAdjust = 46.0f;
	CGFloat label30Offset = 24.0f;
	
	for(TouchView *t in touchViewArray)
	{
		[t removeFromSuperview];
		//DoLog(DEBUG,@"VVV:::");
	}
	[touchViewArray removeAllObjects];
	for(UILabel *t in labelArray)
	{
		[t removeFromSuperview];
		//DoLog(DEBUG,@"VVV:::");
	}
	[labelArray removeAllObjects];
	
	for(TouchView *t in allDayEventArray)
	{
		[t removeFromSuperview];
		//DoLog(DEBUG,@"VVV:::");
	}
	[allDayEventArray removeAllObjects];
	
	//draw time hour label
	for(int i=0;i<24;i++){
		UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, labelAdjust*i, labelWidth, labelHourHeight)];
		myLabel.text=[NSString stringWithFormat:@"%02d:00",i];
		myLabel.numberOfLines=1;
		myLabel.backgroundColor=[UIColor clearColor];
		myLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
		myLabel.textAlignment = UITextAlignmentRight;
		myLabel.textColor = [UIColor colorWithRed:100.0f/255.0f green:44.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
		[labelArray addObject:myLabel];
		[sv addSubview:myLabel];
		[myLabel release];
	}
	//draw time 30 label
	for(int i=0;i<24;i++){
		UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, label30Offset+labelAdjust*i, labelWidth, labelMinuteHeight)];
		myLabel.text=[NSString stringWithFormat:@"%d",30];
		myLabel.numberOfLines=1;
		myLabel.backgroundColor=[UIColor clearColor];
		myLabel.font = [UIFont fontWithName:@"Helvetica" size:10.0f];
		myLabel.textAlignment = UITextAlignmentRight;
		myLabel.textColor = [UIColor colorWithRed:195.0f/255.0f green:142.0f/255.0f blue:77.0f/255.0f alpha:1.0f];
		[labelArray addObject:myLabel];
		[sv addSubview:myLabel];
		[myLabel release];
	}
	
	//draw content
	CGFloat defaultHeight = 46.0f;
	CGFloat allDayHeight = 25.0f;
	CGFloat defaultWidth = (320.0f-50.0f) / 3.0f - 1.0f;
	CGFloat defaultAllDayWidth = 320.0f / 3.0f - 1.0f;
	//CGFloat defaultWidth = 320.0f-50.0f-1.0f;
	CGFloat height = 0.0f;
	CGFloat width = 0.0f;
	CGFloat pointX = 0.0f;
	CGFloat pointY = 0.0f;
	
	//scroll view location
	sv.frame = CGRectMake(0.0f, 20.0f, 320.0f, (372.0f-20.0f));
	
	// for all day event
	int allDayEventCount = 0;
	CGFloat allDayEventX = 0.0f;
	
	
	int xCount = 0;

	//int fading = 2;
	NSMutableDictionary *yAtX = [[NSMutableDictionary alloc] init];
	for(int k=0;k<24;k++){
		NSString *keyStr= [NSString stringWithFormat:@"%02d",k];
		if( [self.dictionary objectForKey:keyStr] !=nil){
			NSMutableArray *mArray=[self.dictionary objectForKey:keyStr];
			xCount = 0;
			pointX = 50.0f;
			ListTodoEvent *listTodoEvent;
			int sH,eH,sM,eM;
			NSRange mRange;
			mRange.location=8;
			mRange.length=4;
			int r,g,b;
			
			TouchView *button;
			UILabel *mLabel;
			for(int i=0;i<[mArray count];i++){
				listTodoEvent=[mArray objectAtIndex:i];
				r = listTodoEvent.colorRgb/1000000;
				g = (listTodoEvent.colorRgb%1000000)/1000;
				b = (listTodoEvent.colorRgb%1000);
				
				sH=[[listTodoEvent.startTime substringWithRange:mRange] intValue];
				eH=[[listTodoEvent.endTime substringWithRange:mRange] intValue];
				
				sM=sH%100;
				sH=sH/100;
				eM=eH%100;
				eH=eH/100;
				
				pointY = (sH * 60 + sM)*(touchViewHeight/60.0f)+ timeLineAdjust;
				height = ((eH - sH) * 60 + (eM - sM) -1.0f)*(touchViewHeight/60.0f);
				if(height < defaultHeight)
					height = defaultHeight;
				
				if(listTodoEvent.allDayEvent==1){
					height = allDayHeight;
					
					if(allDayEventCount <2){
						width = defaultAllDayWidth ;
					}else{
						width = defaultAllDayWidth / pow(2,(allDayEventCount - 1)) ;
					}
					DoLog(DEBUG,@"x:%f,y:%f,w:%f,h:%f,xCount:%d",allDayEventX,0.0f,width,height,allDayEventCount);
					
					button=[[TouchView alloc]initWithFrame:CGRectMake(allDayEventX, 0.0f, width, height)];
					button.listTodoEvent=listTodoEvent;
					button.calendarRootViewController=self.calendarRootViewController;
					
					button.userInteractionEnabled=YES;
					//button.backgroundColor=[UIColor blackColor];
					button.image=[UIImage imageNamed:[NSString stringWithFormat:@"calenfolder_small_%@.png",[RuleArray getColorDictionary:listTodoEvent.colorRgb]]];
					
					
					mLabel=[[UILabel alloc]initWithFrame:CGRectMake(1.0f, 1.0f , width-2.0f, height-2.0f )];
					mLabel.numberOfLines=1;
					mLabel.font=[UIFont systemFontOfSize:14.0];
					mLabel.textColor = [UIColor whiteColor];
					if(listTodoEvent.allDayEvent!=1){
						mLabel.text=[NSString stringWithFormat:@"%@\n%@",listTodoEvent.subject,listTodoEvent.location];
					}else{
						sv.frame = CGRectMake(0.0f, 20.0f+25.0f, 320.0f, (372.0f-20.0f-25.0f));
						mLabel.text=[NSString stringWithFormat:@"%@",listTodoEvent.subject,listTodoEvent.location];
					}
					//mLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
					mLabel.backgroundColor=[UIColor clearColor];
					[button addSubview:mLabel];	
					[mLabel release];
					
					[allDayEventView addSubview:button];
					[allDayEventArray addObject:button];
					[button release];
					allDayEventCount++;
					allDayEventX = allDayEventX + width;
					
					continue;
				}
				
				NSString *xLocation = [NSString stringWithFormat:@"%d",xCount];

				while ([yAtX objectForKey:xLocation]!= nil && [[yAtX objectForKey:xLocation] floatValue] > pointY){
					if(xCount <2){
						pointX = pointX + defaultWidth;
					}else{
						pointX = pointX + (defaultWidth / pow(2,(xCount - 1))) ;
					}
					//pointX = pointX + (defaultWidth / pow(2,(xCount - 1))) ;
					xCount++;
					xLocation = [NSString stringWithFormat:@"%d",xCount];
				}
				//width = defaultWidth / pow(2,(xCount - 1)) ;
				
				if(xCount <2){
					width = defaultWidth ;
				}else{
					width = defaultWidth / pow(2,(xCount - 1)) ;
					DoLog(DEBUG,@"^^^:::%f",pow(2,(xCount - 1)));
					
				}
				
				[yAtX setObject:[NSString stringWithFormat:@"%f",(pointY+height)] forKey:[NSString stringWithFormat:@"%d",xCount]];
				button=[[TouchView alloc]initWithFrame:CGRectMake(pointX, pointY, width, height)];
				button.listTodoEvent=listTodoEvent;
				button.calendarRootViewController=self.calendarRootViewController;
				
				button.userInteractionEnabled=YES;
				//button.backgroundColor=[UIColor blackColor];
				button.image=[UIImage imageNamed:[NSString stringWithFormat:@"calenfolder_small_%@.png",[RuleArray getColorDictionary:listTodoEvent.colorRgb]]];
				
				//subject label
				mLabel=[[UILabel alloc]initWithFrame:CGRectMake(3.0f, 0.0f , width-6.0f, 20.0f )];
				mLabel.numberOfLines=1;
				mLabel.font=[UIFont systemFontOfSize:16.0];
				mLabel.textColor = [UIColor whiteColor];
				if(listTodoEvent.allDayEvent!=1){
					mLabel.text=[NSString stringWithFormat:@"%@",listTodoEvent.subject];
				}else{
					mLabel.text=[NSString stringWithFormat:@"整日\n%@:%@",listTodoEvent.subject,listTodoEvent.location];
				}
				//mLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
				mLabel.backgroundColor=[UIColor clearColor];
				[button addSubview:mLabel];	
				[mLabel release];
				
				mLabel=[[UILabel alloc]initWithFrame:CGRectMake(23.0f, 20.0f , width-35.0f, 20.0f )];
				mLabel.numberOfLines=1;
				mLabel.font=[UIFont systemFontOfSize:14.0];
				mLabel.textColor = [UIColor whiteColor];
				mLabel.text=[NSString stringWithFormat:@"%@",listTodoEvent.location];
				//mLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
				mLabel.backgroundColor=[UIColor clearColor];
				[button addSubview:mLabel];	
				[mLabel release];
				UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(3.0f, 20.0f , 20.0f, 20.0f )];
				[img setImage:[UIImage imageNamed:[[picture icon] objectAtIndex:1]]];
				[button addSubview:img];
				[img release];
				
				//add icon
				img = [[UIImageView alloc] initWithFrame:CGRectMake(width-33.0f, 3.0f, 30.0f, 30.0f)];
				[img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"eventicon_%@.png",[RuleArray getEventIcon:[listTodoEvent.eventIcon intValue]]]]];
				[button addSubview:img];
				[img release];
				
				
				/*
				mLabel=[[UILabel alloc]initWithFrame:CGRectMake(1.0f, 1.0f , width-2.0f, height-2.0f )];
				mLabel.numberOfLines=2;
				mLabel.font=[UIFont systemFontOfSize:14.0];
				if(listTodoEvent.allDayEvent!=1){
					mLabel.text=[NSString stringWithFormat:@"%@\n%@",listTodoEvent.subject,listTodoEvent.location];
				}else{
					sv.frame = CGRectMake(0.0f, 20.0f+25.0f, 320.0f, (372.0f-20.0f-25.0f));
					mLabel.text=[NSString stringWithFormat:@"整日\n%@:%@",listTodoEvent.subject,listTodoEvent.location];
				}
				//mLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
				mLabel.backgroundColor=[UIColor clearColor];
				[button addSubview:mLabel];	
				[mLabel release];
				*/
				
				
				[sv addSubview:button];
				[touchViewArray addObject:button];
				[button release];
				//DoLog(INFO,@"x:%f,y:%f,w:%f,h:%f,xCount:%d",pointX,pointY,width,height,xCount);
				
			}
		}
	}
	[yAtX release];
	

}


- (void) fromWeekViewToDayViewForYear:(NSInteger)iYear Month:(NSInteger)iMonth Day:(NSInteger)iDay{
	
	self.year = iYear;
	self.month = iMonth;
	self.day = iDay;
	[self refreshViewWithPushDirection:4];
}





@end
