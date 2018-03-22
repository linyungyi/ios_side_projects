//
//  EventTimeViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventTimeViewController.h"


@implementation EventTimeViewController
@synthesize notifySwitch,datePicker;
@synthesize days,hours,mins;
@synthesize column1,column2,column3;
@synthesize todoEvent;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	column1=[[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",nil];
	column2=[[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",nil];
	column3=[[NSArray alloc] initWithObjects:@"0",@"5",@"10",@"15",@"20",@"25",@"30",@"35",@"40",@"45",@"50",@"55",nil];
	
	NSArray *tmpArray=[[[todoEvent objectAtIndex:4] objectAtIndex:0] componentsSeparatedByString:@"#"];
	NSInteger tmpInteger=[[tmpArray objectAtIndex:0]intValue];
	if(tmpInteger<0){
		[notifySwitch setOn:NO];
		datePicker.hidden=YES;
	}else{
		self.days=(tmpInteger/60)/24;
		self.hours=(tmpInteger-self.days*24*60)/60;
		self.mins=(tmpInteger-self.days*24*60-self.hours*60);
				
		[datePicker selectRow:self.days inComponent:0 animated:YES];
		[datePicker selectRow:self.hours inComponent:1 animated:YES];
		[datePicker selectRow:(self.mins/5) inComponent:2 animated:YES];
		
	}
	
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"確定" style:UIBarButtonItemStyleBordered target:self action:@selector(doJob:)] autorelease];
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
	[todoEvent release];
	[notifySwitch release];
	[column1 release];
	[column2 release];
	[column3 release];
	[datePicker release];
    [super dealloc];
}

-(IBAction) doJob:(id) sender{
	//DoLog(DEBUG,@"save notify%d",[notifySwitch isOn]);
	
	if([notifySwitch isOn]==YES){
		/*
		NSDate *now=[datePicker date];
		NSCalendar *cal=[datePicker calendar];
		//NSInteger flags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSWeekdayCalendarUnit|NSWeekdayOrdinalCalendarUnit|NSWeekCalendarUnit;
		NSInteger flags=NSHourCalendarUnit|NSMinuteCalendarUnit;
		NSDateComponents *cmp = [ cal components:flags fromDate:now];
		DoLog(DEBUG,@"%d %d",[cmp hour],[cmp minute]);
		*/
		NSMutableString *tmpString=[[NSMutableString alloc]init];
		if(days>0)
			[tmpString appendFormat:@"%d天",days];
		if(hours>0)
			[tmpString appendFormat:@"%d小時",hours];
		[tmpString appendFormat:@"%d分鐘前",mins];
		[[[todoEvent objectAtIndex:4] objectAtIndex:0] setString:[NSString stringWithFormat:@"%d#%@",days*24*60+hours*60+mins,tmpString]];
		[tmpString release];
	}else{
		[[[todoEvent objectAtIndex:4] objectAtIndex:0] setString:@"-1"];
	}
	
	[[self parentViewController] viewWillAppear:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) switchChange:(id) sender{
	if([sender isOn])
		datePicker.hidden=NO;
	else
		datePicker.hidden=YES;
}

-(IBAction) pickerChange:(id) sender{
	DoLog(DEBUG,@"%@",[sender date]);
	
}

#pragma mark -
#pragma mark Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	NSInteger row=0;
	switch (component) {
		case 0:
			row=[self.column1 count];
			break;
		case 1:
			row=[self.column2 count];
			break;
		case 2:
			row=[self.column3 count];
			break;
		default:
			break;
	}
    return row;
}
#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *tmpString;
	switch (component) {
		case 0:
			tmpString=[NSString stringWithFormat:@"%@天",[self.column1 objectAtIndex:row]];
			break;
		case 1:
			tmpString=[NSString stringWithFormat:@"%@小時",[self.column2 objectAtIndex:row]];
			break;
		case 2:
			tmpString=[NSString stringWithFormat:@"%@分",[self.column3 objectAtIndex:row]];
			break;
		default:
			break;
	}
	return tmpString;
}

-(void) pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger) row inComponent:(NSInteger) component
{
	
	switch (component) {
		case 0:
			days=[[self.column1 objectAtIndex:row]intValue];
			break;
		case 1:
			hours=[[self.column2 objectAtIndex:row]intValue];
			break;
		case 2:
			mins=[[self.column3 objectAtIndex:row]intValue];
			break;
		default:
			break;
	}
	
}

@end
