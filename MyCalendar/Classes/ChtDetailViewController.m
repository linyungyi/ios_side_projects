//
//  ChtDetailViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ChtDetailViewController.h"
#import "RuleArray.h"
#import "ProfileUtil.h"

@implementation ChtDetailViewController
@synthesize syncDatas;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
     if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		 RuleArray *ruleArray=[[RuleArray alloc]init];
		 self.syncDatas=[ruleArray keepRule1];
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

	//self.title=@"資料保存期限";
	
	[self.tableView reloadData];
	RuleArray *ruleArray=[[RuleArray alloc]init];
	
	int row=0;
	row=[ruleArray getKeepRowNo:[ProfileUtil integerForKey:KEEPRULE]];
	if(row<0)
		row=0;
	
	NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
	[ruleArray release];
	[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
	
	self.view.backgroundColor = [UIColor clearColor];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self.tableView reloadData];
	RuleArray *ruleArray=[[RuleArray alloc]init];
	
	int row=0;
	row=[ruleArray getKeepRowNo:[ProfileUtil integerForKey:KEEPRULE]];
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
     return [self.syncDatas count];
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
	cell.textLabel.text=[syncDatas objectAtIndex:row];
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	NSUInteger row = [indexPath row];
    //NSString *tmpString = [syncDatas objectAtIndex:row];
	
	RuleArray *ruleArray=[[RuleArray alloc]init];
	//[[NSUserDefaults standardUserDefaults] setObject:[[ruleArray keepRule2] objectAtIndex:row] forKey:KEEPRULE];
	[ProfileUtil setString:[[ruleArray keepRule2] objectAtIndex:row] forKey:KEEPRULE];
	[ruleArray release];
	
	//[[NSUserDefaults standardUserDefaults] setObject:tmpString forKey:@"keepDetail"];
	//[[NSUserDefaults standardUserDefaults] synchronize];
	
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
	[syncDatas release];
    [super dealloc];
}


@end

