//
//  RedoDateViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RedoDateViewController.h"
#import "DateTimeUtil.h"

@implementation RedoDateViewController
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
	[myArray addObject:[NSMutableString stringWithString:[[todoEvent objectAtIndex:3] objectAtIndex:1]]];
	self.tableDatas = myArray;
	[myArray release];
	
	NSArray *tmp1=[[[todoEvent objectAtIndex:3] objectAtIndex:1] componentsSeparatedByString:@"#"];
	[datePicker setDate:[DateTimeUtil getDateFromString:[tmp1 objectAtIndex:0]]];
	
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
	[datePicker release];
    [super dealloc];
}

-(IBAction) doJob:(id)sender{
	
	[[[todoEvent objectAtIndex:3] objectAtIndex:1] setString:[tableDatas objectAtIndex:0]];
	
	[[self parentViewController] viewWillAppear:YES];
	[self.navigationController popViewControllerAnimated:YES];
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
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
	NSString *tmpString=[tableDatas objectAtIndex:row];
	
	NSArray *tmpArray;
	switch (row) {
		case 0:
			tmpArray=[tmpString componentsSeparatedByString:@"#"];
			cell.textLabel.text=@"重複結束";
			cell.detailTextLabel.text=[tmpArray objectAtIndex:1];
			break;
		default:
			break;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/*
	NSUInteger row = [indexPath row];
    */
}

/*
-(NSString *) getStringFromDate:(NSDate *) myDate forKind:(NSInteger) kind{
	if(myDate == nil)
		return nil;
	
	NSDateFormatter *form=[[NSDateFormatter alloc]init];
	
	if(kind!=0)
		[form setDateFormat:@"yyyy/MM/dd HH:mm"];
	else
		[form setDateFormat:@"yyyyMMddHHmmss"];
		 
	NSString *str=[form stringFromDate:myDate];
	
	[form release];
	
	return str;
}

-(NSDate *) getDateFromString:(NSString *) myDatetime{
	if([myDatetime length]!=14)
		return nil;
	
	NSRange range;
	
	range.location=0;
	range.length=4;
	int year=[[myDatetime substringWithRange:range]intValue];
	range.location=4;
	range.length=2;
	int month=[[myDatetime substringWithRange:range]intValue];
	range.location=6;
	int day=[[myDatetime substringWithRange:range]intValue];
	range.location=8;
	int hour=[[myDatetime substringWithRange:range]intValue];
	range.location=10;
	int min=[[myDatetime substringWithRange:range]intValue];
	range.location=12;
	int sec=[[myDatetime substringWithRange:range]intValue];
	
	NSDateComponents *cmp=[[NSDateComponents alloc]init];
	[cmp setYear:year];
	[cmp setMonth:month];
	[cmp setDay:day];
	[cmp setHour:hour];
	[cmp setMinute:min];
	[cmp setSecond:sec];
	
	NSCalendar *cal=[NSCalendar currentCalendar];
	NSDate *date=[cal dateFromComponents:cmp];
	[cmp release];
	return date;
}
*/

-(IBAction) pickerChange:(id) sender{
	[[tableDatas objectAtIndex:0] setString:[NSString stringWithFormat:@"%@#%@",[DateTimeUtil getStringFromDate:[datePicker date] forKind:0],[DateTimeUtil getStringFromDate:[datePicker date] forKind:1]]];
	[self.myTableView reloadData];
}

@end
