//
//  NotifyTimeViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/4/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NotifyTimeViewController.h"
#import "RuleArray.h"

@implementation NotifyTimeViewController

@synthesize tableDatas;
@synthesize todoEvent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		RuleArray *ruleArray=[[RuleArray alloc]init];
		self.tableDatas=[ruleArray notifyRule1];
		[ruleArray release];
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
	
	[self.tableView reloadData];
	RuleArray *ruleArray=[[RuleArray alloc]init];
	
	int row=0;
	
	NSArray *tmpArray=[[[todoEvent objectAtIndex:4] objectAtIndex:0] componentsSeparatedByString:@"#"];
	
	row=[ruleArray getNotifyRowNo:[[tmpArray objectAtIndex:0]intValue]];
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
	
	NSArray *tmpArray=[[[todoEvent objectAtIndex:4] objectAtIndex:0] componentsSeparatedByString:@"#"];
	
	row=[ruleArray getNotifyRowNo:[[tmpArray objectAtIndex:0]intValue]];
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
    return [self.tableDatas count];
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
	cell.textLabel.text=[tableDatas objectAtIndex:row];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	NSUInteger row = [indexPath row];
	
	if(row==0){
		[[[todoEvent objectAtIndex:4] objectAtIndex:0] setString:@"-1"];
	}else{
		RuleArray *ruleArray=[[RuleArray alloc]init];
		[[[todoEvent objectAtIndex:4] objectAtIndex:0] setString:[NSString stringWithFormat:@"%@#%@",[[ruleArray notifyRule2] objectAtIndex:row],[tableDatas objectAtIndex:row]]];
		[ruleArray release];
	}
		
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
	[tableDatas release];
    [super dealloc];
}


@end

