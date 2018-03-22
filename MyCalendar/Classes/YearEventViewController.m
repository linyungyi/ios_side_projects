//
//  YearEventViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "YearEventViewController.h"
#import "YearTileView.h"
#import "MySqlite.h"
#import "DateTimeUtil.h"
#import "picture.h"

@interface YearEventViewController ()
- (void)showPreviousMonth;
- (void)showFollowingMonth;
@end

@implementation YearEventViewController
@synthesize theDay,contentView,year;
@synthesize calendarRootViewController;
@synthesize now;


-(void) showPrevious{
	[self showPreviousMonth];
}
-(void) showFollowing{
	[self showFollowingMonth];
}


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	DoLog(DEBUG,@"Year");
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	

	
	//build view 
	CGRect appFrame = CGRectMake(0, 0, 320, 372);
	contentView = [[MyUIView alloc] initWithFrame:appFrame];
	contentView.delegate=self;
	contentView.backgroundColor=[UIColor clearColor];

	
	// Header
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320, 20)] autorelease];
    //headerView.backgroundColor = [UIColor clearColor];
	headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[[picture calenOther] objectAtIndex:1]]];
    [self addSubviewsToHeaderView:headerView];
	[contentView addSubview:headerView];
	
	tileArray = [[NSMutableArray alloc] init];
	
	[self refreshViewWithPushDirection:0];
	
}


- (void)addSubviewsToHeaderView:(UIView *)headerView
{
	const CGFloat kChangeMonthButtonWidth = 45.0f;
	const CGFloat kChangeMonthButtonHeight = 19.0f;
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
	[previousMonthButton setImage:[UIImage imageNamed:[[picture arrow]objectAtIndex:1]] forState:UIControlStateNormal];
	//[previousMonthButton setImage:[UIImage imageNamed:@"syncicon.png"] forState:UIControlStateNormal];
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
										1,
										120,
										20);
	headerTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
	headerTitleLabel.backgroundColor = [UIColor clearColor];
	headerTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
	headerTitleLabel.textAlignment = UITextAlignmentCenter;
	headerTitleLabel.textColor = [UIColor colorWithRed:100.0f/255.0f green:44.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
	//headerTitleLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kal_header_text_fill.png"]];
	headerTitleLabel.shadowColor = [UIColor whiteColor];
	headerTitleLabel.shadowOffset = CGSizeMake(0.f, 1.f);
	//[self setHeaderTitleText:[logic selectedMonthNameAndYear]];
	headerTitleLabel.text=@"2010/01/01";
	[headerView addSubview:headerTitleLabel];
	
	// Create the next month button on the right side of the view
	CGRect nextMonthButtonFrame = CGRectMake(320.0 - kChangeMonthButtonWidth,
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
	[nextMonthButton addTarget:self action:@selector(showFollowingMonth) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:nextMonthButton];
	[nextMonthButton release];
	

}



- (void)showPreviousMonth{
	DoLog(DEBUG,@"type left");
	[self refreshViewWithPushDirection:2];
	
	
}

- (void)showFollowingMonth{
	DoLog(DEBUG,@"type right");
	[self refreshViewWithPushDirection:1];
	

	
}


- (void) refreshViewWithPushDirection:(NSInteger) type {
	
	NSCalendar *cal=[NSCalendar currentCalendar];
	NSDateComponents *cmp=[[[NSDateComponents alloc] init] autorelease];
	NSInteger flags=NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
	
	// init date data
	if(type == 0)
	{
		//init set date to 1/1 or 7/1 
		
		
		[self setNow:[NSDate date]];
		NSDateComponents *components = [ cal components:flags fromDate:self.now];
		if(components.month<7){
			[components setMonth:1];
		}else{
			[components setMonth:7];
		}
		[components setDay:1];
		
		[self setNow:[cal dateFromComponents:components]];
		
		//NSRange range = [cal rangeOfUnit:NSDayCalendarUnit
		//						  inUnit:NSMonthCalendarUnit
		//						 forDate:[cal dateFromComponents:cmp]];
		//DoLog(DEBUG,@"%d", range.length);
		//DoLog(DEBUG,@"NOW:%@,CAL:%@,CMP:%@,DAY:%d",self.now,cal,cmp,range.length);
	}else if(type == 1){
		//right 6 months
	}else if(type == 2){
		NSDateComponents *components = [[NSDateComponents alloc] init] ;
		[components setMonth:-12];
		[self setNow:[cal dateByAddingComponents:components toDate:self.now options:0]];
		[components release];
	}else if(type == 3){// for viewWillAppear
		NSDateComponents *components = [[NSDateComponents alloc] init] ;
		[components setMonth:-6];
		[self setNow:[cal dateByAddingComponents:components toDate:self.now options:0]];
		[components release];
	}

	cmp = [ cal components:flags fromDate:self.now];
	if(cmp.month<7){
		headerTitleLabel.text=[NSString stringWithFormat:@"%d 上半年",cmp.year ];
	}else{
		headerTitleLabel.text=[NSString stringWithFormat:@"%d 下半年",cmp.year ];
	}
	//DoLog(DEBUG,@"BBB:%d",cmp.year);
	[self clearAndDrawTile];

}

- (void) clearAndDrawTile{
	for(YearTileView *t in tileArray)
	{
		[t removeFromSuperview];
	}
	[tileArray removeAllObjects];
	
	NSCalendar *cal=[NSCalendar currentCalendar];
	
	NSString *startDateTimeString=[DateTimeUtil getStringFromDate:self.now forKind:0];
	NSDateComponents *tmpCmp = [[[NSDateComponents alloc] init] autorelease];
	[tmpCmp setMonth:6];
	NSString *endDateTimeString=[DateTimeUtil getStringFromDate:[cal dateByAddingComponents:tmpCmp toDate: self.now options:0] forKind:0];
	
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
	}
	//DoLog(DEBUG,@"XXXXXX:%@",[dictionary objectForKey:tempString]);
	[strArray release];
	
	for(int j=0;j<3;j++){
		for(int i=0;i<2;i++){
			
			
			NSDateComponents *cmp=[[[NSDateComponents alloc] init] autorelease];
			NSInteger flags=NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit;
			cmp = [ cal components:flags fromDate:self.now];
			NSRange range = [cal rangeOfUnit:NSDayCalendarUnit
									  inUnit:NSMonthCalendarUnit
									 forDate:[cal dateFromComponents:cmp]];
			
			//DoLog(DEBUG,@"DRAW NOW:%@,CAL:%@,CMP:%@,DAY:%d",self.now,cal,cmp,range.length);
			YearTileView *myView=[[YearTileView alloc]initWithFrame: CGRectMake(5+(320.0)/2.0*i, 25+5+(342.0)/3.0*j, (320.0-20.0)/2.0, (342.0-30)/3.0)];
			myView.backgroundColor = [UIColor clearColor];
			myView.days=range.length;	
			myView.title=[NSString stringWithFormat:@"%d年%d月",cmp.year,cmp.month];
			//myView.title=@"11";
			myView.first=cmp.weekday;
			
			
			for(int k=0;k<=range.length;k++)
			{
				tempString = [NSString stringWithFormat:@"%04d%02d%02d",cmp.year,cmp.month,k];
				if([dictionary objectForKey:tempString] != nil){
					[myView setColors:k	value:1];
				}else{
					[myView setColors:k	value:0];
				}
				/*
				if(k == 10){
					[myView setColors:k	value:1];
				}else{
					[myView setColors:k	value:0];
				}*/
			}
			[myView setRootViewController:self.calendarRootViewController];
			myView.year=cmp.year;
			myView.month=cmp.month;
			[contentView addSubview:myView];
			[tileArray addObject:myView];
			[myView release];
			NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
			[components setMonth:1];
			[self setNow:[cal dateByAddingComponents:components toDate:self.now options:0]];
			
		}
	}
	[dictionary release];
	self.view = contentView;
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
	[contentView release];
	[headerTitleLabel release];
	[tileArray release];
	[now release];
    [super dealloc];
}


@end
