//
//  ThirdTabRootViewController.m
//  Music01
//
//  Created by albert on 2009/6/22.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ThirdTabRootViewController.h"
#import "CustomCell.h"
#import "Constants.h"
#import "ThirdTabViewController01.h"
#import "Music01AppDelegate.h"
#import "Activity.h"
#import "ThirdTabViewController01B.h"

@implementation ThirdTabRootViewController
@synthesize myTableView;
@synthesize myTableSection;
@synthesize mySectionRow;
@synthesize thirdTabViewController01;
@synthesize activityIndicator;
@synthesize xmlData;
@synthesize thirdTabViewController01B;


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
	
	self.myTableSection = [[NSMutableArray alloc] init];
	self.mySectionRow = [[NSMutableArray alloc] init];	
	[self initAppDelegate];

}
- (void)viewWillAppear:(BOOL)animated
{
	//self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque ;
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
	if([self.mySectionRow count] == 0)
		[self initDataSource];

}
-(void)showResult{
	[self stopAnimation];
	if( appDelegate.activityList == nil)
	{
		if(xmlData != nil)
		{
			[appDelegate initDataSource:Activities orLink:nil withData:self.xmlData];
		}else
		{
			[appDelegate initDataSource:Activities orLink:nil withData:nil];
		}
	}
	
	for (Activity *element in appDelegate.activityList) {
		NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
		if(element.name != nil)
			[rowData setObject:element.name forKey:PrimaryLabel];
		if(element.content != nil)
			[rowData setObject:element.content forKey:SecondaryLabel];
		if(element.beginDate != nil)
			[rowData setObject:element.beginDate forKey:ThirdLabel];
		if(element.endDate != nil)
			[rowData setObject:element.endDate forKey:FourthLabel];
		[rowData setObject:DefaultImage forKey:ImageView];
		if(element.img != nil)
			[rowData setObject:[NSURL URLWithString:element.img] forKey:ImageUrl];
		if(element.url != nil)
			[rowData setObject:element.url forKey:ContentListUrl];	
		//NSLog(element.img);
		[rowData setObject:element forKey:InstanceOfObject];
		[self.mySectionRow addObject:rowData];
	}
	[self.myTableView reloadData];
}
- (void)initDataSource{

	NSString *debugString;
	debugString=@"initDataSource";

	[self startAnimation];
	if(appDelegate.activityList == nil)
		(void) [[URLXmlConnection alloc] initWithURL:[(NSArray *)appDelegate.WSArray objectAtIndex:Activities] delegate:self atIndex:nil];
	else
		if([self.mySectionRow count]==0)
			[self showResult];
		else
			[self stopAnimation];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	int count=0;
	NSString *debugString;
	debugString=@"tableView:numberOfRowsInSection";
	@try{
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
	if(myTableSection == nil  || [myTableSection count]==0)
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
 return HeightForHeader0;
 }
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return HeightForRow4;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	NSString *title=@"";
	NSString *debugString;
	debugString=@"tableView:titleForHeaderInSection";
	if(myTableSection == nil  || [myTableSection count]==0)
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
	if (cell == nil) {
		cell = [[[[CustomCell alloc] initWithViewStyle:STYLE4] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	@try{
		if([[mySectionRow objectAtIndex:indexPath.row] objectForKey:ImageUrl] != nil)
			[self cacheImageWithURL:[[mySectionRow objectAtIndex:indexPath.row] objectForKey:ImageUrl] atIndex:indexPath];
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

	[self startAnimation];
	(void) [[URLXmlConnection alloc] initWithURL:[NSURL URLWithString:[[mySectionRow objectAtIndex:indexPath.row] objectForKey:ContentListUrl]] delegate:self atIndex:indexPath];
}

/*
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	//return UITableViewCellAccessoryDetailDisclosureButton;
	return UITableViewCellAccessoryDisclosureIndicator;
}
*/
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
	[thirdTabViewController01 release];
	[myTableSection release];
	[mySectionRow release];
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

#pragma mark -
#pragma mark URLXmlConnectionDelegate methods

- (void) xmlConnectionDidFail:(URLXmlConnection *)theConnection atIndex:(NSIndexPath *)index
{
	
}
//- (void) xmlConnectionDidFinish:(URLXmlConnection *)theConnection recData:(NSMutableData *)theData atIndex:(NSIndexPath *)index
- (void) xmlConnectionDidFinish:(URLXmlConnection *)theConnection recData:(NSMutableData *)theData atIndex:(id)index
{
	[self stopAnimation];
	NSIndexPath *indexPath = (NSIndexPath *)index;
	if(index == nil)
	{
		self.xmlData = theData;
		[self showResult];
	}else
	{
		if(self.thirdTabViewController01B == nil){
			ThirdTabViewController01B *view01B = [[ThirdTabViewController01B alloc] initWithNibName:@"ThirdTabViewController01B" bundle:[NSBundle mainBundle]];
			self.thirdTabViewController01B = view01B;
			[view01B release];
		}
		thirdTabViewController01B.activityDictionary = [mySectionRow objectAtIndex:indexPath.row];
		[thirdTabViewController01B setData:theData];
		[self.navigationController pushViewController:thirdTabViewController01B animated:YES];
	}
	
}

/*
 ------------------------------------------------------------------------
 URLCacheConnectionDelegate protocol methods
 ------------------------------------------------------------------------
 */

#pragma mark -
#pragma mark URLCacheConnectionDelegate methods

/* display new or existing cached image */
- (void) cacheImageWithURL:(NSURL *)theURL atIndex:(NSIndexPath *)index
{
	/* get the path to the cached image */
	//Music01AppDelegate *appDelegate = (Music01AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *fileName = [NSString stringWithFormat:@"%@%@.%@",[[[theURL path] pathComponents] objectAtIndex:2],[[[theURL path] pathComponents] objectAtIndex:3],[[theURL path] pathExtension]];
	NSString *filePath = [appDelegate.dataPath stringByAppendingPathComponent:fileName];
	
	//NSLog(@"1");
	if([appDelegate imgExistsAtCache:fileName])
	{
		//NSLog([NSString stringWithFormat:@"2 : %d",index]);
		//NSLog(filePath);
		[[mySectionRow objectAtIndex:index.row] setObject:filePath forKey:ImageView];

		return;
	}
	//NSLog(@"3");
	
	(void) [[URLCacheConnection alloc] initWithURL:theURL delegate:self cacheFilePath:filePath defaultFilePath:DefaultImage atIndex:index];
	
}

- (void) connectionDidFail:(URLCacheConnection *)theConnection atIndex:(NSIndexPath *)index
{	
	//NSLog(@"6");
	[theConnection release];
}

- (void) connectionDidFinish:(URLCacheConnection *)theConnection atCacheFilePath:(NSString *)theAtCacheFilePath atIndex:(NSIndexPath *)index
{	
	//NSLog(@"5");
	if(![theAtCacheFilePath isEqualToString:DefaultImage])
	{
		[[mySectionRow objectAtIndex:index.row] setObject:theAtCacheFilePath forKey:ImageView];
		[appDelegate.imgCacheDictionary setObject:[NSNumber numberWithInt:1] forKey:[theAtCacheFilePath lastPathComponent]];
		[self.myTableView reloadData];	
	}

	[theConnection release];
	
}


@end
