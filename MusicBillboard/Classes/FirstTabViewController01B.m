//
//  FirstTabViewController01B.m
//  Music01
//
//  Created by albert on 2009/7/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FirstTabViewController01B.h"
#import "Music01AppDelegate.h"
#import "CustomCell.h"
#import "Constants.h"
#import "avTouchViewController.h"

@implementation FirstTabViewController01B
@synthesize myTableView;
@synthesize myTableSection;
@synthesize mySectionRow;
@synthesize avController;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

-(void)setDictionary:(NSMutableDictionary *)theDictionary{
	myDictionary=theDictionary;
}

-(void)initAppDelegate {
	if(appDelegate == nil)
		appDelegate = (Music01AppDelegate *)[[UIApplication sharedApplication] delegate];
}

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.myTableSection = [[NSMutableArray alloc] init];
	self.mySectionRow = [[NSMutableArray alloc] init];	
	[self initAppDelegate];
}

- (void)viewWillAppear:(BOOL)animated
{
	myTableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor clearColor];
	[self initDataSource];
	[self.myTableView reloadData];
}

- (void)initDataSource{
	NSString *debugString;
	debugString=@"initDataSource";
	[self.myTableSection removeAllObjects];
	[self.mySectionRow removeAllObjects];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

	int count=0;
	NSString *debugString;
	debugString=@"tableView:numberOfRowsInSection";
	@try{
		//count=[mySectionRow00 count];
		if([mySectionRow count] <= section)
			count = 0;
		else
			count=[[mySectionRow objectAtIndex:section] count];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}
	@finally {
		return count;
	}
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	int count=1;
	NSString *debugString;
	debugString=@"numberOfSectionsInTableView";
	if(myTableSection == nil || [myTableSection count] == 0)
		return count;
	@try{
		count=[myTableSection count];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}
	@finally {
		return count;
	}
	
}

-(CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section{
	if(section==0)
		return HeightForHeader1;
	else
		return HeightForHeader0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//NSLog([NSString stringWithFormat:@"a:%d",indexPath.row );
	if(indexPath.row == 0 && indexPath.section == 0)
		return HeightForRow1;
	else
		return HeightForRow0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

	NSString *title=@"";
	NSString *debugString;
	debugString=@"tableView:titleForHeaderInSection";
	if(myTableSection == nil || [myTableSection count] == 0)
		return title;
	@try{
		title =[myTableSection objectAtIndex:section];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}
	@finally {
		return title;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"Cell";	
	NSString *debugString;
	debugString=@"tableView:cellForRowAtIndexPath";
	CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	NSDictionary *showData;
	int showStyle;
	
	if(indexPath.row ==0 && indexPath.section == 0)
	{
		showStyle=STYLE1;
		//showData = [myTableSection objectAtIndex:indexPath.row];
	}else
	{
		showStyle=STYLE0;
		//showData = [[mySectionRow objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	}
	showData = [[mySectionRow objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	if (cell == nil) {
		cell = [[[[CustomCell alloc] initWithViewStyle:showStyle] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	@try{
		cell.dataDictionary = [showData retain];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}@finally {
		[showData release];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	/*
	 if(self.firstTabViewController01 == nil){
	 FirstTabViewController01 *view01 = [[FirstTabViewController01 alloc] initWithNibName:@"FirstTabView01" bundle:[NSBundle mainBundle]];
	 self.firstTabViewController01 = view01;
	 [view01 release];
	 }
	 
	 [self.navigationController pushViewController:firstTabViewController01 animated:YES];	*/
	if(indexPath.row == 0 && indexPath.section == 0)
		return;
	if(self.avController == nil){
		avTouchViewController *view01 = [[avTouchViewController alloc] initWithNibName:@"avTouchViewController" bundle:[NSBundle mainBundle]];
		self.avController = view01;
		[view01 release];
	}
	[avController setDictionary:[[mySectionRow objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
	[self.navigationController setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:avController animated:YES];	
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	
	[myDictionary release];
	[myTableView release];
	[myTableSection release];
	[mySectionRow release];
    [super dealloc];
}

@end
