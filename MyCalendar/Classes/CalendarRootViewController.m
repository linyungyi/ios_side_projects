//
//  CalendarRootViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalendarRootViewController.h"
#import "ListEventViewController.h"
#import "YearEventViewController.h"
#import "MonthEventViewController.h"
#import "WeekEventViewController.h"
#import "DayEventViewController.h"
#import "NewEventViewController.h"
#import "DateTimeUtil.h"

@implementation CalendarRootViewController
@synthesize whichView,segmentedControl;
//@synthesize listEventViewController;
@synthesize yearEventViewController,monthEventViewController,weekEventViewController,dayEventViewController;

-(id) init{
	if(self = [super init]){
		YearEventViewController *tmpViewController = 
		[[YearEventViewController alloc] initWithNibName:@"YearEventView" 
												  bundle:nil];
		self.yearEventViewController=tmpViewController;
		[self.view addSubview:tmpViewController.view];
		[tmpViewController release];
	}
	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
/*
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad {
    [super viewDidLoad];
	
	DoLog(DEBUG,@"did load %d",self.whichView);
	//[self changeView:self.whichView toView:whichView];
	[self.segmentedControl setSelectedSegmentIndex:0];
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
	[segmentedControl release];
	//[listEventViewController release];
	[yearEventViewController release];
	[monthEventViewController release];
	[weekEventViewController release];
	[dayEventViewController release];
    [super dealloc];
}
/*
-(IBAction)doList:(id)sender{
	DoLog(DEBUG,@"doList");
	
	//[self.segmentedControl setSelected:NO];
	//self.segmentedControl.momentary=YES;
	[self.segmentedControl setSelectedSegmentIndex:-1];
	
	[self changeView:self.whichView toView:0];
}*/

-(IBAction)doAdd:(id)sender{
	DoLog(DEBUG,@"doAdd");
	
	NSString *now;
	switch (self.whichView) {
			/*
		case 0:
			now=[DateTimeUtil getStringFromDate:self.listEventViewController.now forKind:0];
			break;
			 */
		case 0:
			//now=[DateTimeUtil getStringFromDate:self.yearEventViewController.now forKind:0];
			now=nil;
			break;
		case 1:
			now=[DateTimeUtil getStringFromDate:self.monthEventViewController.now forKind:0];
			break;
		case 2:
			now=[DateTimeUtil getStringFromDate:[DateTimeUtil getDiffDate:self.weekEventViewController.now mins:-(7*24*60)] forKind:0];
			break;
		case 3:
			now=[DateTimeUtil getStringFromDate:self.dayEventViewController.now forKind:0];
			break;
		default:
			break;
	}	
	
	NewEventViewController *nextController = [[[NewEventViewController alloc] initWithNibName:@"NewEventView" dateString:now] autorelease];
	self.title=@"<<";
    [self.navigationController pushViewController:nextController animated:YES];
}

-(IBAction)toToday:(id)sender{
	DoLog(DEBUG,@"toToday");
	
	switch (self.whichView) {
			/*
		case 0:
			DoLog(DEBUG,@"toToday refreshlistview");
			[self.listEventViewController refreshViewWithPushDirection:0];
			break;
			 */
		case 0:
			DoLog(DEBUG,@"toToday refreshyearview");
			[self.yearEventViewController refreshViewWithPushDirection:0];
			break;
		case 1:
			DoLog(DEBUG,@"toToday refreshmonthview");
			[self.monthEventViewController refreshViewWithPushDirection:0];
			break;
		case 2:
			DoLog(DEBUG,@"toToday refreshweekview");
			[self.weekEventViewController refreshViewWithPushDirection:0];
			break;
		case 3:
			DoLog(DEBUG,@"toToday refreshdayview");
			[self.dayEventViewController refreshViewWithPushDirection:0];
			break;
		default:
			break;
	}
	
}

-(IBAction)doSwitch:(id)sender{
	
	NSInteger to=[sender selectedSegmentIndex];
	DoLog(DEBUG,@"%d doSwitch %d",self.whichView,to);
	//refreshview before switch
	switch (to) {
			/*
		case 0:
			[self.listEventViewController refreshViewWithPushDirection:3];
			break;
			 */
		case 0:
			DoLog(DEBUG,@"refreshyearview");
			[self.yearEventViewController refreshViewWithPushDirection:3];
			break;
		case 1:
			DoLog(DEBUG,@"refreshmonthview");
			[self.monthEventViewController refreshViewWithPushDirection:3];
			break;
		case 2:
			DoLog(DEBUG,@"refreshweekview");
			[self.weekEventViewController refreshViewWithPushDirection:3];
			break;
		case 3:
			DoLog(DEBUG,@"refreshdayview");
			[self.dayEventViewController refreshViewWithPushDirection:3];
			break;
		default:
			break;
	}
	//self.segmentedControl.momentary=NO;
	[self changeView:self.whichView toView:to];
	

}

-(void)changeView:(NSInteger) from toView:(NSInteger)to{
	DoLog(DEBUG,@"%d changeView from=%d,to=%d",self.whichView,from,to);
	
	UIViewController *coming;
	UIViewController *going;
	
	switch (to) {
			/*
		case 0:
			coming=self.listEventViewController;
			if (coming == nil)
			{
				self.listEventViewController = 
				[[ListEventViewController alloc] initWithNibName:@"ListEventView" 
													   bundle:nil];
				self.listEventViewController.calendarRootViewController=self;
				coming=self.listEventViewController;
			}
			break;
			 */
		case 0:
			coming=self.yearEventViewController;
			if (coming == nil)
			{
				self.yearEventViewController = 
				[[YearEventViewController alloc] initWithNibName:@"YearEventView" 
														  bundle:nil];
				self.yearEventViewController.calendarRootViewController=self;
				coming=self.yearEventViewController;
			}
			break;
		case 1:
			DoLog(DEBUG,@"3");
			coming=self.monthEventViewController;
			if (coming == nil)
			{
				self.monthEventViewController = 
				[[MonthEventViewController alloc] initWithNibName:@"MonthEventView" 
														  bundle:nil];
				self.monthEventViewController.calendarRootViewController=self;
				coming=self.monthEventViewController;
		
			}
			break;
		case 2:
			coming=self.weekEventViewController;
			if (coming == nil)
			{
				self.weekEventViewController = 
				[[WeekEventViewController alloc] initWithNibName:@"WeekEventView" 
														  bundle:nil];
				self.weekEventViewController.calendarRootViewController=self;
				coming=self.weekEventViewController;
			}
			break;
		case 3:
			coming=self.dayEventViewController;
			if (coming == nil)
			{
				self.dayEventViewController = 
				[[DayEventViewController alloc] initWithNibName:@"DayEventView" 
														  bundle:nil];
				self.dayEventViewController.calendarRootViewController=self;
				coming=self.dayEventViewController;
			}
			break;
		default:
			break;
	}
	//DoLog(DEBUG,@"%@",[coming description]);
	
	switch (self.whichView) {
			/*
		case 0:
			going=self.listEventViewController;
			if (going == nil)
			{
				self.listEventViewController = 
				[[ListEventViewController alloc] initWithNibName:@"ListEventView" 
														  bundle:nil];
				self.listEventViewController.calendarRootViewController=self;
				going=self.listEventViewController;
				
			}
			break;
			 */
		case 0:
			going=self.yearEventViewController;
			if (going == nil)
			{
				self.yearEventViewController = 
				[[YearEventViewController alloc] initWithNibName:@"YearEventView" 
														  bundle:nil];
				self.yearEventViewController.calendarRootViewController=self;
				going=self.yearEventViewController;
			}
			break;
		case 1:
			going=self.monthEventViewController;
			if (going == nil)
			{
				self.monthEventViewController = 
				[[MonthEventViewController alloc] initWithNibName:@"MonthEventView" 
														   bundle:nil];
				self.monthEventViewController.calendarRootViewController=self;
				going=self.monthEventViewController;
			}
			break;
		case 2:
			going=self.weekEventViewController;
			if (going == nil)
			{
				self.weekEventViewController = 
				[[WeekEventViewController alloc] initWithNibName:@"WeekEventView" 
														  bundle:nil];
				self.weekEventViewController.calendarRootViewController=self;
				going=self.weekEventViewController;
			}
			break;
		case 3:
			going=self.dayEventViewController;
			if (going == nil)
			{
				self.dayEventViewController = 
				[[DayEventViewController alloc] initWithNibName:@"DayEventView" 
														 bundle:nil];
				self.dayEventViewController.calendarRootViewController=self;
				
				going=self.dayEventViewController;
			}
			break;
		default:
			break;
	}
	//DoLog(DEBUG,@"%@",[going description]);
	
	/*
	[UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:1.25];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationTransition:
	 UIViewAnimationTransitionFlipFromRight
						   forView:self.view cache:YES];
	*/
	
	[going viewWillAppear:YES];
	[coming viewWillDisappear:YES]; 
	 
	if(going !=nil && going.view.superview !=nil){
		[going.view removeFromSuperview];
		DoLog(DEBUG,@"remove");
	}
	if(coming!=nil){
		[coming performSelector:@selector(setTheDay:)  withObject:[NSString stringWithFormat:@"%d",from] ];
		self.whichView=to;
		[self.view insertSubview:coming.view atIndex:0];
		DoLog(DEBUG,@"insert");
	}	
	
	[going viewDidAppear:YES];
	[coming viewDidDisappear:YES];
	
	//[UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	
	switch (self.whichView) {
			/*
		case 0:
			DoLog(DEBUG,@"viewWillAppear refreshlistview");
			[self.listEventViewController refreshViewWithPushDirection:3];
			break;
			 */
		case 0:
			DoLog(DEBUG,@"viewWillAppear refreshyearview");
			[self.yearEventViewController refreshViewWithPushDirection:3];
			break;
		case 1:
			DoLog(DEBUG,@"viewWillAppear refreshmonthview");
			[self.monthEventViewController refreshViewWithPushDirection:3];
			break;
		case 2:
			DoLog(DEBUG,@"viewWillAppear refreshweekview");
			[self.weekEventViewController refreshViewWithPushDirection:3];
			break;
		case 3:
			DoLog(DEBUG,@"viewWillAppear refreshdayview");
			[self.dayEventViewController refreshViewWithPushDirection:3];
			break;
		default:
			break;
	}

}

@end
