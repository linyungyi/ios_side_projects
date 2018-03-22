//
//  SecondTabViewController01.m
//  Music01
//
//  Created by albert on 2009/6/18.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecondTabViewController01.h"
#import "Music01AppDelegate.h"
#import "CustomCell.h"
#import "Constants.h"
#import "avTouchViewController.h"
#import "URLCacheAlert.h"
#import "Song.h"

@implementation SecondTabViewController01
@synthesize myTableView;
@synthesize myTableSection;
@synthesize mySectionRow;
@synthesize avController;
@synthesize xmlData;
@synthesize arrayData;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization

    }
    return self;
}

-(void)setCategoryId:(NSInteger)theCategoryid{
	categoryId = theCategoryid;
	//NSLog([NSString stringWithFormat:@"%d",categoryId]);
}

-(void)initAppDelegate {
	if(appDelegate == nil)
		appDelegate = (Music01AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)setData:(NSData *)theData
{
	self.xmlData = theData;
	
	//NSLog([[NSString alloc] initWithData:self.xmlData encoding:NSUTF8StringEncoding]);
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
	self.arrayData = [[NSMutableArray alloc] init];
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
	[self.arrayData removeAllObjects];

	if(self.xmlData != nil)
	{
		[appDelegate initDataSource:categoryId orLink:nil withData:self.xmlData];
		self.xmlData = nil;
	}
		
	switch (categoryId) {
		case RankTotal:
			if( appDelegate.rTotalList == nil)
				[appDelegate initDataSource:RankTotal orLink:nil withData:nil];
			[arrayData addObjectsFromArray:appDelegate.rTotalList];
			//NSLog([NSString stringWithFormat:@"1.%d",categoryId]);
			/*for (Song *element in appDelegate.rTotalList) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
				if(element.song != nil)
					[rowData setObject:element.song forKey:PrimaryLabel];
				if(element.singer != nil)
					[rowData setObject:element.singer forKey:SecondaryLabel];
				if(element.productid != nil)
					[rowData setObject:element.productid forKey:ThirdLabel];
				if(element.cpname != nil)
					[rowData setObject:element.cpname forKey:FourthLabel];
				[rowData setObject:DefaultImage forKey:ImageView];
				if(element.price != nil)
					[rowData setObject:element.price forKey:FifthLabel];
				if(element.img_artist != nil)
					[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
				[rowData setObject:element forKey:InstanceOfObject];
				[self.mySectionRow addObject:rowData];
				
			}*/
			break;
		case RankMaleArtist:
			if( appDelegate.rMaleList == nil)
				[appDelegate initDataSource:RankMaleArtist orLink:nil withData:nil];
			[arrayData addObjectsFromArray:appDelegate.rMaleList];
			//NSLog([NSString stringWithFormat:@"2.%d",categoryId]);
			/*
			for (Song *element in appDelegate.rMaleList) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
				[rowData setObject:element.song forKey:PrimaryLabel];
				[rowData setObject:element.singer forKey:SecondaryLabel];
				[rowData setObject:element.productid forKey:ThirdLabel];
				[rowData setObject:element.cpname forKey:FourthLabel];
				[rowData setObject:DefaultImage forKey:ImageView];
				[rowData setObject:element.price forKey:FifthLabel];	
				[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
				[rowData setObject:element forKey:InstanceOfObject];
				[self.mySectionRow addObject:rowData];
			}*/
			break;
		case RankFemaleArtist:
			if( appDelegate.rFemaleList == nil)
				[appDelegate initDataSource:RankFemaleArtist orLink:nil withData:nil];
			[arrayData addObjectsFromArray:appDelegate.rFemaleList];
			//NSLog([NSString stringWithFormat:@"3.%d",categoryId]);
			/*
			for (Song *element in appDelegate.rFemaleList) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
				[rowData setObject:element.song forKey:PrimaryLabel];
				[rowData setObject:element.singer forKey:SecondaryLabel];
				[rowData setObject:element.productid forKey:ThirdLabel];
				[rowData setObject:element.cpname forKey:FourthLabel];
				[rowData setObject:DefaultImage forKey:ImageView];
				[rowData setObject:element.price forKey:FifthLabel];
				[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
				[rowData setObject:element forKey:InstanceOfObject];
				[self.mySectionRow addObject:rowData];
				
			}
			 */
			break;
		case RankGroup:
			if( appDelegate.rGroupList == nil)
				[appDelegate initDataSource:RankGroup orLink:nil withData:nil];
			[arrayData addObjectsFromArray:appDelegate.rGroupList];
			//NSLog([NSString stringWithFormat:@"%d",categoryId]);
			/*
			for (Song *element in appDelegate.rGroupList) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
				[rowData setObject:element.song forKey:PrimaryLabel];
				[rowData setObject:element.singer forKey:SecondaryLabel];
				[rowData setObject:element.productid forKey:ThirdLabel];
				[rowData setObject:element.cpname forKey:FourthLabel];
				[rowData setObject:DefaultImage forKey:ImageView];
				[rowData setObject:element.price forKey:FifthLabel];
				[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
				[rowData setObject:element forKey:InstanceOfObject];
				[self.mySectionRow addObject:rowData];
				
			}*/
			break;
		case RankTaiwan:
			if( appDelegate.rTaiwanList == nil)
				[appDelegate initDataSource:RankTaiwan orLink:nil withData:nil];
			[arrayData addObjectsFromArray:appDelegate.rTaiwanList];
			//NSLog([NSString stringWithFormat:@"%d",categoryId]);
			/*
			for (Song *element in appDelegate.rTaiwanList) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
				[rowData setObject:element.song forKey:PrimaryLabel];
				[rowData setObject:element.singer forKey:SecondaryLabel];
				[rowData setObject:element.productid forKey:ThirdLabel];
				[rowData setObject:element.cpname forKey:FourthLabel];
				[rowData setObject:DefaultImage forKey:ImageView];
				[rowData setObject:element.price forKey:FifthLabel];
				[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
				[rowData setObject:element forKey:InstanceOfObject];
				[self.mySectionRow addObject:rowData];
				
			}*/
			break;
		case RankJapanKorea:
			if( appDelegate.rJapanList == nil)
				[appDelegate initDataSource:RankJapanKorea orLink:nil withData:nil];
			[arrayData addObjectsFromArray:appDelegate.rJapanList];
			//NSLog([NSString stringWithFormat:@"%d",categoryId]);
			/*
			for (Song *element in appDelegate.rJapanList) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
				[rowData setObject:element.song forKey:PrimaryLabel];
				[rowData setObject:element.singer forKey:SecondaryLabel];
				[rowData setObject:element.productid forKey:ThirdLabel];
				[rowData setObject:element.cpname forKey:FourthLabel];
				[rowData setObject:DefaultImage forKey:ImageView];
				[rowData setObject:element.price forKey:FifthLabel];
				[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
				[rowData setObject:element forKey:InstanceOfObject];
				[self.mySectionRow addObject:rowData];
				
			}*/
			break;
		case RankWestern:
			if( appDelegate.rWesternList == nil)
				[appDelegate initDataSource:RankWestern orLink:nil withData:nil];
			[arrayData addObjectsFromArray:appDelegate.rWesternList];
			//NSLog([NSString stringWithFormat:@"%d",categoryId]);
			/*
			for (Song *element in appDelegate.rWesternList) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
				[rowData setObject:element.song forKey:PrimaryLabel];
				[rowData setObject:element.singer forKey:SecondaryLabel];
				[rowData setObject:element.productid forKey:ThirdLabel];
				[rowData setObject:element.cpname forKey:FourthLabel];
				[rowData setObject:DefaultImage forKey:ImageView];
				[rowData setObject:element.price forKey:FifthLabel];
				[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
				[rowData setObject:element forKey:InstanceOfObject];
				[self.mySectionRow addObject:rowData];
				
			}*/
			break;
		case RankMood:
			if( appDelegate.rMoodList == nil)
				[appDelegate initDataSource:RankMood orLink:nil withData:nil];
			[arrayData addObjectsFromArray:appDelegate.rMoodList];
			//NSLog([NSString stringWithFormat:@"%d",categoryId]);
			/*
			for (Song *element in appDelegate.rMoodList) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
				[rowData setObject:element.song forKey:PrimaryLabel];
				[rowData setObject:element.singer forKey:SecondaryLabel];
				[rowData setObject:element.productid forKey:ThirdLabel];
				[rowData setObject:element.cpname forKey:FourthLabel];
				[rowData setObject:DefaultImage forKey:ImageView];
				[rowData setObject:element.price forKey:FifthLabel];
				[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
				[rowData setObject:element forKey:InstanceOfObject];
				[self.mySectionRow addObject:rowData];
				
			}*/
			break;
		default:
			NSLog(@"%@[%@] >> %@ %d",NSStringFromClass([self class]),debugString,@"There is no switch-definition at index",categoryId);
			break;
	}

	for (Song *element in arrayData) {
		NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
		if(element.song != nil)
			[rowData setObject:element.song forKey:PrimaryLabel];
		if(element.singer != nil)
			[rowData setObject:element.singer forKey:SecondaryLabel];
		if(element.productid != nil)
			[rowData setObject:element.productid forKey:ThirdLabel];
		if(element.cpname != nil)
			[rowData setObject:element.cpname forKey:FourthLabel];
		[rowData setObject:DefaultImage forKey:ImageView];
		if(element.price != nil)
			[rowData setObject:element.price forKey:FifthLabel];
		if(element.img_artist != nil)
			[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
		[rowData setObject:element forKey:InstanceOfObject];
		[self.mySectionRow addObject:rowData];
	}

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
	if(myTableSection == nil || [myTableSection count]==0)
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
	return HeightForRow6;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

	NSString *title=@"";
	NSString *debugString;
	debugString=@"tableView:titleForHeaderInSection";
	if(myTableSection == nil || [myTableSection count]==0)
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
		cell = [[[[CustomCell alloc] initWithViewStyle:STYLE6] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
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

	if(self.avController == nil){
		avTouchViewController *view01 = [[avTouchViewController alloc] initWithNibName:@"avTouchViewController" bundle:[NSBundle mainBundle]];
		self.avController = view01;
		[view01 release];
	}
	[avController setDictionary:[mySectionRow objectAtIndex:indexPath.row]];
	//[avController setUri:[[mySectionRow objectAtIndex:indexPath.row] objectForKey:FilePath]];
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
	[myTableView release];
	[myTableSection release];
	[mySectionRow release];
    [super dealloc];
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
	NSString *fileName = [[theURL path] lastPathComponent];
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
