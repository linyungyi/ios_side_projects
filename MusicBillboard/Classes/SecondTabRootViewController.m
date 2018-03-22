//
//  SecondTabRootViewController.m
//  Music01
//
//  Created by albert on 2009/6/18.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecondTabRootViewController.h"
#import "CustomCell.h"
#import "SecondTabViewController01.h"
#import "Constants.h";
#import "Music01AppDelegate.h"

/* offset in  WSArray*/
const int wsOffset = 3;

@implementation SecondTabRootViewController

@synthesize myTableView;
@synthesize secondTabViewController01;
@synthesize myTableSection;
@synthesize mySectionRow;
@synthesize activityIndicator;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
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
	activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	activityIndicator.frame = CGRectMake(141.0f, 187.0f, 37.0f, 37.0f);
	[self.view addSubview:activityIndicator];

	self.navigationItem.title=@"每週排行榜";
	[self initAppDelegate];
	[self initDataSource];
}
- (void)viewWillAppear:(BOOL)animated
{
	myTableView.backgroundColor = [UIColor clearColor];
	if([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault)
	{
		self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	}else if([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleBlackOpaque)
	{
		self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque ;
	}else if([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleBlackTranslucent)
	{
		self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent ;
	}
}

- (void)initDataSource{
	//section
	self.myTableSection = nil;
	//menu list
	//mySectionRow00 = [[NSArray alloc] initWithObjects:@"總排行",@"國語（男）",@"國語（女）",@"國語（團體）",@"台語",@"日韓",@"西洋",@"情調",nil];
	self.mySectionRow =  [[NSMutableArray alloc] init];
	[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								@"總排行", PrimaryLabel,
								 nil]];
	[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"國語（男）", PrimaryLabel,
							 nil]];
	[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"國語（女）", PrimaryLabel,
							 nil]];
	[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"國語（團體）", PrimaryLabel,
							 nil]];
	[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"台語", PrimaryLabel,
							 nil]];
	[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"日韓", PrimaryLabel,
							 nil]];
	[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"西洋", PrimaryLabel,
							 nil]];
	[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"情調", PrimaryLabel,
							 nil]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	int count=0;
	NSString *debugString;
	debugString=@"tableView:numberOfRowsInSection";
	@try{
		//count=[mySectionRow00 count];
		count=[mySectionRow count];
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
	if(myTableSection == nil)
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

/*
-(CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section{
	return HeightForHeade0;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return HeightForRow5;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	NSString *title=@"";
	NSString *debugString;
	debugString=@"tableView:titleForHeaderInSection";
	if(myTableSection == nil)
		return title;
	@try{
		title =[myTableSection objectAtIndex:section];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
		//title=@" ";
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
	if (cell == nil) {
		cell = [[[[CustomCell alloc] initWithViewStyle:STYLE5] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	@try{

		cell.dataDictionary = [mySectionRow objectAtIndex:indexPath.row];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *debugString;
	debugString=@"tableView:didSelectRowAtIndexPath";
	bool didLoad = false;
	switch (indexPath.row+wsOffset) {
		case RankTotal:
			if( appDelegate.rTotalList != nil)
				didLoad = true;
			break;
		case RankMaleArtist:
			if( appDelegate.rMaleList != nil)
				didLoad = true;
			break;
		case RankFemaleArtist:
			if( appDelegate.rFemaleList != nil)
				didLoad = true;
			break;
		case RankGroup:
			if( appDelegate.rGroupList != nil)
				didLoad = true;
			break;
		case RankTaiwan:
			if( appDelegate.rTaiwanList != nil)
				didLoad = true;
			break;
		case RankJapanKorea:
			if( appDelegate.rJapanList != nil)
				didLoad = true;
			break;
		case RankWestern:
			if( appDelegate.rWesternList != nil)
				didLoad = true;
			break;
		case RankMood:
			if( appDelegate.rMoodList != nil)
				didLoad = true;
			break;
		default:
			NSLog(@"%@[%@] >> %@ %d",NSStringFromClass([self class]),debugString,@"There is no switch-definition at index",indexPath.row+wsOffset);
			break;
	}
	
	if(didLoad)
	{
		if(self.secondTabViewController01 == nil){
			SecondTabViewController01 *view01 = [[SecondTabViewController01 alloc] initWithNibName:@"SecondTabView01" bundle:[NSBundle mainBundle]];
			self.secondTabViewController01 = view01;
			[view01 release];
		}
		
		[self.secondTabViewController01 setCategoryId:(indexPath.row+wsOffset)];
		[self.navigationController pushViewController:secondTabViewController01 animated:YES];	
		
		return;
	}
	
	(void) [[URLXmlConnection alloc] initWithURL:[(NSArray *)appDelegate.WSArray objectAtIndex:indexPath.row+wsOffset] delegate:self atIndex:indexPath];
	[self startAnimation];
	
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
	[myTableView release];
	[secondTabViewController01 release];
	[mySectionRow release];
	[activityIndicator release];
    [super dealloc];
}

/* show the user that loading activity has started */

- (void) startAnimation
{
	[self.activityIndicator startAnimating];
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = YES;
}


/* show the user that loading activity has stopped */

- (void) stopAnimation
{
	[self.activityIndicator stopAnimating];
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = NO;
}

- (void) xmlConnectionDidFail:(URLXmlConnection *)theConnection atIndex:(NSIndexPath *)index
{
	
}
//- (void) xmlConnectionDidFinish:(URLXmlConnection *)theConnection recData:(NSMutableData *)theData atIndex:(NSIndexPath *)index
- (void) xmlConnectionDidFinish:(URLXmlConnection *)theConnection recData:(NSMutableData *)theData atIndex:(id)index
{
	[self stopAnimation];
	NSIndexPath *indexPath = (NSIndexPath *)index;
	if(self.secondTabViewController01 == nil){
		SecondTabViewController01 *view01 = [[SecondTabViewController01 alloc] initWithNibName:@"SecondTabView01" bundle:[NSBundle mainBundle]];
		self.secondTabViewController01 = view01;
		[view01 release];
	}
	[self.secondTabViewController01 setData:theData];
	[self.secondTabViewController01 setCategoryId:(indexPath.row+wsOffset)];
	[self.navigationController pushViewController:secondTabViewController01 animated:YES];	
	
}

@end
