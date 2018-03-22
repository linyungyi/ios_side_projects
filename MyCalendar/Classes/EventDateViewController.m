//
//  EventDateViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventDateViewController.h"
#import "DateTimeUtil.h"
#import "LabelSwitchCell.h"


@implementation EventDateViewController
//@synthesize startDate,endDate,alldaySwitch;
@synthesize datePicker,flag;
@synthesize todoEvent,tableDatas,myTableView;


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
	
	NSMutableArray *myArray = [[NSMutableArray alloc]init];	
	[myArray addObject:[NSMutableString stringWithString:[[todoEvent objectAtIndex:2] objectAtIndex:0]]];
	[myArray addObject:[NSMutableString stringWithString:[[todoEvent objectAtIndex:2] objectAtIndex:1]]];
	
	NSArray *tmp1=[[[todoEvent objectAtIndex:2] objectAtIndex:0] componentsSeparatedByString:@"#"];
	NSArray *tmp2=[[[todoEvent objectAtIndex:2] objectAtIndex:1] componentsSeparatedByString:@"#"];	
	[myArray addObject:[NSMutableString stringWithFormat:@"%d",[DateTimeUtil chkAllDay:[tmp1 objectAtIndex:0] endDate:[tmp2 objectAtIndex:0]] ]];
	self.tableDatas = myArray;
	[myArray release];
	
	if(flag==0)
		[datePicker setDate:[DateTimeUtil getDateFromString:[tmp1 objectAtIndex:0]]];
	else
		[datePicker setDate:[DateTimeUtil getDateFromString:[tmp2 objectAtIndex:0]]];
	
	[self.myTableView reloadData];
	NSIndexPath *indexPath=[NSIndexPath indexPathForRow:flag inSection:0];
	[self.myTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];

	
	self.myTableView.backgroundColor=[UIColor clearColor];
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
	[myTableView release];
	[tableDatas release];
	[todoEvent release];
	//[startDate release];
	//[endDate release];
	//[alldaySwitch release];
	[datePicker release];
    [super dealloc];
}

-(IBAction) doJob:(id)sender{
	NSRange range;
	range.location=0;
	range.length=8;
	
	long date1 = [[[tableDatas objectAtIndex:0] substringWithRange:range] intValue];
	long date2 = [[[tableDatas objectAtIndex:1] substringWithRange:range] intValue];
	range.location=8;
	range.length=6;
	int time1 = [[[tableDatas objectAtIndex:0] substringWithRange:range] intValue];
	int time2 = [[[tableDatas objectAtIndex:1] substringWithRange:range] intValue];
	
	if((date1*1000000+time1)>=(date2*1000000+time2)){
		
		UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"日期有誤" message:@"終止需大於起始" delegate:nil cancelButtonTitle:@"確定"otherButtonTitles:nil] autorelease];
		[av show];
		
	}else{
	
		[[[todoEvent objectAtIndex:2] objectAtIndex:0] setString:[tableDatas objectAtIndex:0]];
		[[[todoEvent objectAtIndex:2] objectAtIndex:1] setString:[tableDatas objectAtIndex:1]];
	
		[[self parentViewController] viewWillAppear:YES];
		[self.navigationController popViewControllerAnimated:YES];
	}	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableDatas count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = [indexPath row];
    NSString *CellIdentifier;
	
	if(row<=2)
		CellIdentifier= @"Cell";
	else
		CellIdentifier=[NSString stringWithFormat:@"%d_Cell",row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if(row!=2)
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		else
			cell = [[[NSBundle mainBundle] loadNibNamed:@"LabelSwitchCell" owner:self options:nil] lastObject];		
		//[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    // Set up the cell...
	
	NSString *tmpString=[tableDatas objectAtIndex:row];
	
	NSArray *tmpArray;
	switch (row) {
		case 0:
			tmpArray=[tmpString componentsSeparatedByString:@"#"];
			cell.textLabel.text=@"起始";
			cell.detailTextLabel.text=[tmpArray objectAtIndex:1];
			break;
		case 1:
			tmpArray=[tmpString componentsSeparatedByString:@"#"];
			cell.textLabel.text=@"終止";
			cell.detailTextLabel.text=[tmpArray objectAtIndex:1];
			break;
		case 2:
			((LabelSwitchCell *)cell).customLabel.text = @"整日";
			((LabelSwitchCell *)cell).viewController=self;
			((LabelSwitchCell *)cell).myTag=1;
			if([tmpString intValue]==1){
				datePicker.enabled=NO;
				[((LabelSwitchCell *)cell).customSwitch setOn:YES];
			}else{
				datePicker.enabled=YES;
				[((LabelSwitchCell *)cell).customSwitch setOn:NO];
			}
			
			/*
			cell.textLabel.text=@"整日";
			
			CGRect myRect = cell.contentView.frame;
			myRect.origin.x=100;
			myRect.origin.y=3;
			myRect.size.width=100;
			myRect.size.height=28;
			UISwitch *tmpSwitch = [[UISwitch alloc]initWithFrame:myRect];
			if([tmpString intValue]==1){
				datePicker.enabled=NO;
				[tmpSwitch setOn:YES];
			}
			[tmpSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
			[cell.contentView addSubview:tmpSwitch];
			[tmpSwitch release];
			 */
			break;
		default:
			break;
	}
	//cell.detailTextLabel.text=myString;
	
	//[cell setHighlighted:YES animated:YES];
	/*
	if(flag==row){
		//[cell setSelected:YES];
		//[cell setHighlighted:YES];
		
		//cell.selected=YES;
		//cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}else{ 
		[cell setHighlighted:NO];
		//cell.selected=NO;
		//cell.accessoryType = UITableViewCellAccessoryNone;
	}
	*/
	//[myString release];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	NSRange range;
	range.location=0;
	range.length=14;
	
	switch (row) {
		case 0:
			flag=row;
			float sec=1*365*24*60*60;
			
			[datePicker setDate:[DateTimeUtil getDateFromString:[[tableDatas objectAtIndex:row] substringWithRange:range]]];
			NSDate *now=[datePicker date];
			[datePicker setMinimumDate:[now addTimeInterval:(-1*sec)]];
			[datePicker setMaximumDate:[now addTimeInterval:(1*sec)]];
			break;
		case 1:
			flag=row;
			
			[datePicker setDate:[DateTimeUtil getDateFromString:[[tableDatas objectAtIndex:row] substringWithRange:range]]];
			NSString *tmpString=[[tableDatas objectAtIndex:0] substringWithRange:range];
			[datePicker setMinimumDate:[DateTimeUtil getDateFromString:tmpString]];
			range.length=8;
			tmpString=[[tableDatas objectAtIndex:0] substringWithRange:range];
			[datePicker setMaximumDate:[DateTimeUtil getDateFromString:[NSString stringWithFormat:@"%@235900",tmpString]]];
	
			break;
		case 2:
			break;
		default:
			break;
	}
	//[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
	//[tableView deselectRowAtIndexPath:indexPath animated:NO]; 
}

- (void) updateSwitch:(UISwitch *) aSwitch forItem: (NSString *) anItem
{
	[self switchChange:aSwitch];
}

-(IBAction) switchChange:(id) sender{
	if([sender isOn]){
		[[tableDatas objectAtIndex:2] setString:@"1"];
		NSRange range;
		range.location=0;
		range.length=8;
		NSString *tmpString=[[tableDatas objectAtIndex:0] substringWithRange:range];
		flag=0;
		[datePicker setDate:[DateTimeUtil getDateFromString:[NSString stringWithFormat:@"%@000000",tmpString]]];
		[self pickerChange:datePicker];
		flag=1;
		[datePicker setDate:[DateTimeUtil getDateFromString:[NSString stringWithFormat:@"%@235900",tmpString]]];
		[self pickerChange:datePicker];
		datePicker.enabled=NO;
	}else{
		[[tableDatas objectAtIndex:2] setString:@"0"];
		datePicker.enabled=YES;
	}
}

-(IBAction) pickerChange:(id) sender{
	
	if(flag==0)
		[[tableDatas objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%@#%@",[DateTimeUtil getStringFromDate:[datePicker date] forKind:0],[DateTimeUtil getStringFromDate:[datePicker date] forKind:1]]];
	else if(flag==1)
		[[tableDatas objectAtIndex:1] setString:[NSMutableString stringWithFormat:@"%@#%@",[DateTimeUtil getStringFromDate:[datePicker date] forKind:0],[DateTimeUtil getStringFromDate:[datePicker date] forKind:2]]];
	
	NSArray *tmp1=[[tableDatas objectAtIndex:0] componentsSeparatedByString:@"#"];
	NSArray *tmp2=[[tableDatas objectAtIndex:1] componentsSeparatedByString:@"#"];
	[[tableDatas objectAtIndex:2] setString:[NSMutableString stringWithFormat:@"%d",[DateTimeUtil chkAllDay:[tmp1 objectAtIndex:0] endDate:[tmp2 objectAtIndex:0]] ]];
	
	if([[tmp1 objectAtIndex:0] compare:[tmp2 objectAtIndex:0]]!=NSOrderedAscending){
		NSDate *newDate;
		int hour=0;
		int min=0;
		NSRange range;
		NSString *tmpString;
		
		if(flag==0){
			range.location=8;
			range.length=4;
			tmpString=[[tmp1 objectAtIndex:0] substringWithRange:range];
			hour=[tmpString intValue]/100;
			min=[tmpString intValue]%100;
			if(hour==23)
				min=59-min;
			else
				min=60;

			newDate=[DateTimeUtil getDiffDate:[DateTimeUtil getDateFromString:[tmp1 objectAtIndex:0]] mins:min];
			[[tableDatas objectAtIndex:1] setString:[NSMutableString stringWithFormat:@"%@#%@",[DateTimeUtil getStringFromDate:newDate forKind:0],[DateTimeUtil getStringFromDate:newDate forKind:2]]];
		}else{
			range.location=8;
			range.length=4;
			tmpString=[[tmp2 objectAtIndex:0] substringWithRange:range];
			hour=[tmpString intValue]/100;
			min=[tmpString intValue]%100;
			
			if(hour>0 || (hour==0 && min>0)){
				if(hour>0)
					min=-60;
				else 
					min=-1*min;

				newDate=[DateTimeUtil getDiffDate:[DateTimeUtil getDateFromString:[tmp2 objectAtIndex:0]] mins:min];
				[[tableDatas objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%@#%@",[DateTimeUtil getStringFromDate:newDate forKind:0],[DateTimeUtil getStringFromDate:newDate forKind:1]]];
			}else{
				newDate=[DateTimeUtil getDateFromString:[tmp2 objectAtIndex:0]];
				[[tableDatas objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%@#%@",[DateTimeUtil getStringFromDate:newDate forKind:0],[DateTimeUtil getStringFromDate:newDate forKind:1]]];
				newDate=[DateTimeUtil getDiffDate:[DateTimeUtil getDateFromString:[tmp2 objectAtIndex:0]] mins:60];
				[[tableDatas objectAtIndex:1] setString:[NSMutableString stringWithFormat:@"%@#%@",[DateTimeUtil getStringFromDate:newDate forKind:0],[DateTimeUtil getStringFromDate:newDate forKind:2]]];
			}
		}
	}
	
	
	[self.myTableView reloadData];
	
	NSIndexPath *indexPath=[NSIndexPath indexPathForRow:flag inSection:0];
	[myTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
}

@end
