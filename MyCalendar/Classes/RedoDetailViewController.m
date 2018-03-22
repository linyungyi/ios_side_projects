//
//  RedoDetailViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RedoDetailViewController.h"
#import "TodoEvent.h"
#import "RuleArray.h"
#import "DateTimeUtil.h"

@implementation RedoDetailViewController

@synthesize redoDatas;
@synthesize todoEvent;
/*
- (id)initWithRedoArray:(NSArray *)myArray nib:(NSString *)nibNameOrNil{
	if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
		self.redoDatas = myArray;
    }
    return self;
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		RuleArray *ruleArray = [[RuleArray alloc]init];
		self.redoDatas=[ruleArray redoRule1];
		[ruleArray release];
		/*
		NSMutableArray *myArray = [[NSMutableArray alloc]init];
		[myArray addObject:@"不重複"];
		[myArray addObject:@"每天"];
		[myArray addObject:@"每週"];
		[myArray addObject:@"每月"];
		[myArray addObject:@"每年"]; 
		self.redoDatas = myArray;
		[myArray release];
		 */
    }
    return self;
}

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */


- (void)viewDidLoad {
    [super viewDidLoad];

	self.title=@"事件重複";
	
	[self.tableView reloadData];
	RuleArray *ruleArray=[[RuleArray alloc]init];
	
	int row=0;
	
	NSArray *tmpArray=[[[todoEvent objectAtIndex:3] objectAtIndex:0] componentsSeparatedByString:@"#"];
	
	row=[ruleArray getRedoRowNo:[[tmpArray objectAtIndex:0]intValue]];
	if(row<0)
		row=0;
	
	NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
	[ruleArray release];
	[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUNDIMG]];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
	 
	 [self.tableView reloadData];
	 RuleArray *ruleArray=[[RuleArray alloc]init];
	 
	 int row=0;
	 
	 NSArray *tmpArray=[[[todoEvent objectAtIndex:3] objectAtIndex:0] componentsSeparatedByString:@"#"];
	 
	 row=[ruleArray getRedoRowNo:[[tmpArray objectAtIndex:0]intValue]];
	 if(row<0)
		 row=0;
	 
	 NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
	 [ruleArray release];
	 [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
	 
 }
 
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.redoDatas count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSUInteger row = [indexPath row];
	NSString *myString=[redoDatas objectAtIndex:row];
	cell.textLabel.text = myString;
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	NSUInteger row = [indexPath row];
	RuleArray *ruleArray=[[RuleArray alloc]init];
	[[[todoEvent objectAtIndex:3] objectAtIndex:0] setString:[NSString stringWithFormat:@"%@#%@",[[ruleArray redoRule2] objectAtIndex:row],[redoDatas objectAtIndex:row]]];
	
	
	if(row==0){
		if([[todoEvent objectAtIndex:3] count]==2)
			[[todoEvent objectAtIndex:3] removeObject:[[todoEvent objectAtIndex:3]objectAtIndex:1] ];
	}else{
		
		NSArray *tmpArray=[[[todoEvent objectAtIndex:2] objectAtIndex:1] componentsSeparatedByString:@"#"];
		NSDate *tmpDate=[DateTimeUtil getDateFromString:[tmpArray objectAtIndex:0]];
		tmpDate=[DateTimeUtil getNewDate:tmpDate days:[[[ruleArray redoRule3] objectAtIndex:row]intValue]];
		NSString *tmpString=[NSMutableString stringWithFormat:@"%@#%@",[DateTimeUtil getStringFromDate:tmpDate forKind:0],[DateTimeUtil getStringFromDate:tmpDate forKind:1]];
		
		if([[todoEvent objectAtIndex:3] count]==1){
			[[todoEvent objectAtIndex:3] addObject:tmpString];
		}else{
			tmpArray=[[[todoEvent objectAtIndex:3] objectAtIndex:1] componentsSeparatedByString:@"#"];
			if([tmpDate compare:[DateTimeUtil getDateFromString:[tmpArray objectAtIndex:0]]]==NSOrderedDescending)
				[[[todoEvent objectAtIndex:3] objectAtIndex:1] setString:tmpString];
		}
 
	}
	[ruleArray release];
	
	[[self parentViewController] viewWillAppear:YES];
	[self.navigationController popViewControllerAnimated:YES];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


- (void)dealloc {
	[todoEvent release];
	[redoDatas release];
    [super dealloc];
}



@end

