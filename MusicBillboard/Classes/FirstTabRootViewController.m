//
//  FirstTabRootViewController.m
//  Music01
//
//  Created by albert on 2009/6/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FirstTabRootViewController.h"
#import "FirstTabViewController01.h"
//#import "FirstTabViewController01B.h"
#import "Music01AppDelegate.h"
#import "CustomCell.h"
#import "Constants.h"
#import "avTouchViewController.h"
#import "URLCacheAlert.h"
#import "Song.h"
#import "Album.h"
#import "MusicBox.h"
#import "FirstTabViewController01C.h"
#import "FirstTabViewController01D.h"

@implementation FirstTabRootViewController

@synthesize myTableView;
@synthesize firstTabViewController01;
//@synthesize firstTabViewController01B;
@synthesize firstTabViewController01C;
@synthesize firstTabViewController01D;
@synthesize myTableSection;
@synthesize mySectionRow;
@synthesize avController;
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

	//mysong-----------------
	appDelegate.playlistDic=[[NSMutableDictionary alloc] init];
	appDelegate.serverlistDic=[[NSMutableDictionary alloc] init];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	[super viewDidLoad];
	
	// segmented control as the custom title view
	NSArray *segmentTextContent = [NSArray arrayWithObjects:
								   NSLocalizedString(@"單曲", @""),
								   NSLocalizedString(@"專輯", @""),
								   NSLocalizedString(@"音樂盒", @""),
								   nil];
	//UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	
	//mysongs
	segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.selectedSegmentIndex = 0;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	
	defaultTintColor = [segmentedControl.tintColor retain];	// keep track of this for later
	
	segmentedControl.frame = CGRectMake(0, 0, 200, 30.0);
	selectedSegment = [segmentedControl selectedSegmentIndex];
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];	
	//nb.topItem.titleView =segmentedControl;
	self.navigationItem.titleView = segmentedControl;
	//[segmentedControl release];
	
	activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	activityIndicator.frame = CGRectMake(141.0f, 187.0f, 37.0f, 37.0f);
	[self.view addSubview:activityIndicator];

	self.myTableSection = [[NSMutableArray alloc] init];
	self.mySectionRow = [[NSMutableArray alloc] init];
	
	
	//for my songs--------------------------------- 
	addButton = [[UIBarButtonItem alloc]
				 initWithTitle:@"最愛"
				 style:UIBarButtonItemStyleBordered
				 target:self
				 action:@selector(AddMySong:)] ;	
	self.navigationItem.rightBarButtonItem = addButton;	
	editor=false;
	cancelButton= [[UIBarButtonItem alloc]
				   initWithTitle:@"取消"
				   style:UIBarButtonItemStyleBordered
				   target:self
				   action:@selector(cancelMySong:)] ;	
	
	//-----------------------------------------------
	
	
	[self initAppDelegate];
	[self initDataSource];

}

//mysong---------------------
#pragma mark -
#pragma mark MySongs 
-(void) AddMySong:(id)sender{
	
	if(!editor){
		self.navigationItem.rightBarButtonItem.title=@"完成";
		self.navigationItem.leftBarButtonItem = cancelButton;	
		self.navigationItem.titleView=nil;
		
		editor=true;	
		tmpAddSongsDic=[[NSMutableDictionary alloc] init];
		tmpRemoveSongsDic=[[NSMutableDictionary alloc] init];	
		tmpSongsDic=[[NSMutableDictionary alloc] initWithDictionary:appDelegate.playlistDic];
		
	}else{
		self.navigationItem.rightBarButtonItem.title=@"最愛";
		self.navigationItem.leftBarButtonItem = nil;	
		self.navigationItem.titleView=segmentedControl;		
		
		
		[appDelegate.playlistDic addEntriesFromDictionary:tmpAddSongsDic];		
		[appDelegate.playlistDic removeObjectsForKeys:[tmpRemoveSongsDic allKeys]];
		[tmpAddSongsDic release];
		[tmpRemoveSongsDic release];
		[tmpSongsDic release];
		editor=false;
	}
	
	[myTableView reloadData];
}

-(void) cancelMySong:(id)sender{
	
	self.navigationItem.rightBarButtonItem.title=@"最愛";
	self.navigationItem.leftBarButtonItem = nil;	
	self.navigationItem.titleView=segmentedControl;
	editor=false;	
	[myTableView reloadData];
	[tmpSongsDic release];
	[tmpAddSongsDic release];
	[tmpRemoveSongsDic release];
	
}


#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
	//myTableView.backgroundColor = [UIColor clearColor];
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
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)self.navigationItem.titleView;
	
	// before we show this view make sure the segmentedControl matches the nav bar style
	if (self.navigationController.navigationBar.barStyle == UIBarStyleBlackTranslucent ||
		self.navigationController.navigationBar.barStyle == UIBarStyleBlackOpaque) 
	{
		segmentedControl.tintColor = [UIColor darkGrayColor];
	}
	else
	{
		segmentedControl.tintColor = defaultTintColor;
	}
	
}


- (void)segmentAction:(id)sender
{
	UISegmentedControl* segCtl = sender;
	// the segmented control was clicked, handle it here 
	//NSLog(@"segment clicked %d", [segCtl selectedSegmentIndex]);
	selectedSegment = [segCtl selectedSegmentIndex];
	[self initDataSource];
	[self.myTableView reloadData];
	
	//[segCtl release];
	
}

- (void)initDataSource{
	[self.myTableSection removeAllObjects];
	[self.mySectionRow removeAllObjects];
	//Music01AppDelegate *appDelegate = (Music01AppDelegate *)[[UIApplication sharedApplication] delegate];
	//if(self.mySectionRow == nil)
	//	self.mySectionRow = [[NSMutableArray alloc] init];
	
	switch (selectedSegment) {
		case 0:

			//section
			//myTableSection = nil;
			//row
			//self.mySectionRow = [[[DataSourceDelegate alloc] initWithDelegate] initRecommandWithKey: RecommandSingleSong];
			//NSLog(@"1");
			if( appDelegate.singleList == nil)
				[appDelegate initDataSource:RecommandSingleSong orLink:nil withData:nil];
			for (Song *element in appDelegate.singleList) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
				if(element.song != nil)
					[rowData setObject:element.song forKey:PrimaryLabel];
				if(element.singer != nil)
					[rowData setObject:element.singer forKey:SecondaryLabel];
				if(element.productid != nil)
					[rowData setObject:element.productid forKey:ThirdLabel];
				if(element.cpname != nil)
					[rowData setObject:element.cpname forKey:FourthLabel];
				if(element.price != nil)
					[rowData setObject:element.price forKey:FifthLabel];
				[rowData setObject:DefaultImage forKey:ImageView];
				if(element.img_artist != nil)
					[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
				[rowData setObject:element forKey:InstanceOfObject];
				[self.mySectionRow addObject:rowData];
				
			}
			
			break;
		case 1:

			//section
			//myTableSection = nil;
			//self.mySectionRow =  [[[DataSourceDelegate alloc] initWithDelegate] initRecommandWithKey: RecommandAlbum];
			//NSLog(@"2");
			if( appDelegate.cdList == nil)
				[appDelegate initDataSource:RecommandAlbum orLink:nil withData:nil];
			for (Album *element in appDelegate.cdList) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
				if(element.AlbumName != nil)
					[rowData setObject:element.AlbumName forKey:PrimaryLabel];
				if(element.Artist != nil)
					[rowData setObject:element.Artist forKey:SecondaryLabel];
				if(element.IssueDate != nil)
					[rowData setObject:element.IssueDate forKey:ThirdLabel];
				if(element.Publisher != nil)
					[rowData setObject:element.Publisher forKey:FourthLabel];				
				[rowData setObject:DefaultImage forKey:ImageView];
				if(element.img_artist != nil)
					[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
				if(element.ListURL != nil)
					[rowData setObject:element.ListURL forKey:ContentListUrl];
				[rowData setObject:element forKey:InstanceOfObject];
				[self.mySectionRow addObject:rowData];
				
			}
			break;
		case 2:

			//section
			//myTableSection = nil;
			//self.mySectionRow =  [[[DataSourceDelegate alloc] initWithDelegate] initRecommandWithKey: RecommandMusicBox];
			//NSLog(@"3");
			if( appDelegate.musicboxList == nil)
				[appDelegate initDataSource:RecommandMusicBox orLink:nil withData:nil];
			for (MusicBox *element in appDelegate.musicboxList) {
				NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
				if(element.MUSICBOXNAME != nil)
					[rowData setObject:element.MUSICBOXNAME forKey:PrimaryLabel];
				if(element.CONTENTSHORT != nil)
					[rowData setObject:element.CONTENTSHORT forKey:SecondaryLabel];
				if(element.MUSICBOXID != nil)
					[rowData setObject:element.MUSICBOXID forKey:ThirdLabel];
				if(element.CPNAME != nil)
					[rowData setObject:element.CPNAME forKey:FourthLabel];
				if(element.PRICE != nil)
					[rowData setObject:element.PRICE forKey:FifthLabel];
				[rowData setObject:DefaultImage forKey:ImageView];
				if(element.SmallIcon != nil)
					[rowData setObject:[NSURL URLWithString:element.SmallIcon] forKey:ImageUrl];
				if(element.ListURL != nil)
					[rowData setObject:element.ListURL forKey:ContentListUrl];
				[rowData setObject:element forKey:InstanceOfObject];
				[self.mySectionRow addObject:rowData];
				
			}
			break;
			
		default:

			break;
	}
	
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	//return (section == 0) ? 2: 1;
	/*int ret=0;
	switch (selectedSegment) {
		case 0:
			ret=3;
			break;
		case 1:
			ret=(section == 0) ? 2: 1;;
			break;
		case 2:
			ret=4;
			break;

		default:
			ret=1;
			break;
	}
	return ret;*/
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
	//return 2;
	/*int ret=0;
	switch (selectedSegment) {
		case 0:
			ret=1;
			break;
		case 1:
			ret=2;
			break;
		case 2:
			ret=1;
			break;
			
		default:
			ret=1;
			break;
	}
	return ret;	*/
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

-(CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section{
	int HeightForHeader;
	switch (selectedSegment) {
		case 0:
		case 1:
			HeightForHeader = HeightForHeader6;
			break;
		case 2:
			HeightForHeader = HeightForHeader9;
			break;
		default:
			HeightForHeader = HeightForHeader6;
			break;
	}
	return HeightForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int HeightForRow;
	switch (selectedSegment) {
		case 0:
		case 1:
			HeightForRow = HeightForRow6;
			break;
		case 2:
			HeightForRow = HeightForRow9;
			break;
		default:
			HeightForRow = HeightForRow6;
			break;
	}		
	return HeightForRow;

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	//return [NSString stringWithFormat:@"歌手 %d",section];
	//return [NSString stringWithFormat:@"春．日光"];
	/*NSString *ret;
	switch (selectedSegment) {
		case 0:
			ret=[NSString stringWithFormat:@""];
			break;
		case 1:
			ret=[NSString stringWithFormat:@"春．日光"];
			break;
		case 2:
			ret=[NSString stringWithFormat:@""];;
			break;
			
		default:
			ret=[NSString stringWithFormat:@""];;
			break;
	}
	
	return ret;		*/
	NSString *title=@"";
	NSString *debugString;
	debugString=@"tableView:titleForHeaderInSection";

	if(myTableSection == nil || [myTableSection count] == 0)
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
	/*UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell"];
	if (cell == nil) {
		CGRect rect;
		rect = CGRectMake(0.0,0.0,320.0,60.0);
		cell = [[[UITableViewCell alloc] initWithFrame:rect reuseIdentifier:@"TestCell"] autorelease];
		
	}
	cell.text = [NSString stringWithFormat:@"%@ %d %@ %d",@"蘇打綠" , indexPath.section ,@"早點回家" , indexPath.row];
	return cell;*/
	
	static NSString *CellIdentifier = @"Cell";	
	NSString *debugString;
	int      style = STYLE6;
	debugString=@"tableView:cellForRowAtIndexPath";
	
	switch (selectedSegment) {
		case 0:
		case 1:
			CellIdentifier = @"Cell";
			style = STYLE6;
			break;
		case 2:
			CellIdentifier = @"Cell2";
			style = STYLE9;
			break;
		default:
			CellIdentifier = @"Cell";
			style = STYLE6;
			break;
	}
	
	
	CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	//NSLog([NSString stringWithFormat:@"1.%@ %d",CellIdentifier,style]);
	//if (cell == nil) {
		cell = [[[[CustomCell alloc] initWithViewStyle:style] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		//NSLog([NSString stringWithFormat:@"2.%@ %d",CellIdentifier,style]);
	//}
	
	@try{
		//cell.primaryLabel.text = [mySectionRow00 objectAtIndex:indexPath.row];
		//cell.secondaryLabel.text = [mySectionRow01 objectAtIndex:indexPath.row];
		//cell.myImageView.image = [UIImage imageNamed:[mySectionRow02 objectAtIndex:indexPath.row]];
		if([[mySectionRow objectAtIndex:indexPath.row] objectForKey:ImageUrl] != nil)
			[self cacheImageWithURL:[[mySectionRow objectAtIndex:indexPath.row] objectForKey:ImageUrl] atIndex:indexPath];
		cell.dataDictionary = [mySectionRow objectAtIndex:indexPath.row];
		
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}
	
	//mysong--------------------
	if(editor &&[tmpSongsDic objectForKey:[cell.dataDictionary objectForKey:ThirdLabel]]!=nil){
		
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		
	}else {
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	//------------------------
	
	
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

	[self.navigationController pushViewController:firstTabViewController01 animated:YES];	
	 */
	//FirstTabViewController01C *fTabviewController01C;
	//FirstTabViewController01D *fTabviewController01D;
	switch (selectedSegment) {
		case 0:
			
			//mysong-----------------------
			if(editor){
				
				
				NSString *aID=[[mySectionRow objectAtIndex:indexPath.row] objectForKey:ThirdLabel];
				
				if([[tableView cellForRowAtIndexPath:indexPath] accessoryType] ==UITableViewCellAccessoryCheckmark){
					[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
					[tmpSongsDic removeObjectForKey:aID];
					[tmpRemoveSongsDic setObject:[[mySectionRow objectAtIndex:indexPath.row] objectForKey:InstanceOfObject] forKey:aID];
					
				}else{
					[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
					[tmpSongsDic setObject:[mySectionRow objectAtIndex:indexPath.row] forKey:aID];
					[tmpAddSongsDic setObject:[[mySectionRow objectAtIndex:indexPath.row] objectForKey:InstanceOfObject] forKey:aID];
				}
				NSLog(@"FirstTabRootViewController(), editor, playlistDic-> %d, id-> %@",appDelegate.playlistDic.count,aID);
				
			}else{
				
				if(self.avController == nil){
					avTouchViewController *view01 = [[avTouchViewController alloc] initWithNibName:@"avTouchViewController" bundle:[NSBundle mainBundle] ];
					self.avController = view01;
					[view01 release];
				}
				[avController setDictionary:[mySectionRow objectAtIndex:indexPath.row]];
				[self.navigationController setHidesBottomBarWhenPushed:YES];
				[self.navigationController pushViewController:avController animated:YES];	
			}
			break;
		case 1:
			/*if(self.firstTabViewController01B == nil){
				FirstTabViewController01B *view01b = [[FirstTabViewController01B alloc] initWithNibName:@"FirstTabView01B" bundle:[NSBundle mainBundle]];
				self.firstTabViewController01B = view01b;
				[view01b release];
			}
			[firstTabViewController01B setDictionary:[mySectionRow objectAtIndex:indexPath.row]];
			[self.navigationController pushViewController:firstTabViewController01B animated:YES];	*/
			
			
			/*fTabviewController01C = [[FirstTabViewController01C alloc] initWithNibName:@"FirstTabViewController01C" bundle:[NSBundle mainBundle]];
			fTabviewController01C.albumDictionary=[mySectionRow objectAtIndex:indexPath.row];
			[self.navigationController pushViewController:fTabviewController01C animated:YES];	*/
			
			[self startAnimation];
			(void) [[URLXmlConnection alloc] initWithURL:[NSURL URLWithString:[[mySectionRow objectAtIndex:indexPath.row] objectForKey:ContentListUrl]] delegate:self atIndex:indexPath];
			
			break;
		case 2:
			/*if(self.firstTabViewController01B == nil){
				FirstTabViewController01B *view01b = [[FirstTabViewController01B alloc] initWithNibName:@"FirstTabView01B" bundle:[NSBundle mainBundle]];
				self.firstTabViewController01B = view01b;
				[view01b release];
			}
			[firstTabViewController01B setDictionary:[mySectionRow objectAtIndex:indexPath.row]];
			[self.navigationController pushViewController:firstTabViewController01B animated:YES];	*/
			
			/*fTabviewController01D = [[FirstTabViewController01D alloc] initWithNibName:@"FirstTabViewController01D" bundle:[NSBundle mainBundle]];
			fTabviewController01D.musicBoxDictionary= [mySectionRow objectAtIndex:indexPath.row];
			[self.navigationController pushViewController:fTabviewController01D animated:YES];	*/
			
			[self startAnimation];
			(void) [[URLXmlConnection alloc] initWithURL:[NSURL URLWithString:[[mySectionRow objectAtIndex:indexPath.row] objectForKey:ContentListUrl]] delegate:self atIndex:indexPath];
			
			break;
		default:
			break;
	}
	
}
/*
- (BOOL)hidesBottomBarWhenPushed{
	return TRUE;
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

	[myTableSection release];
	[mySectionRow release];
	[avController release];
	[defaultTintColor release];
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
	
	if(!editor){
		NSIndexPath *indexPath = (NSIndexPath *)index;
		switch (selectedSegment) {
				
			case 1:
				if(self.firstTabViewController01C == nil){
					FirstTabViewController01C *view01c = [[FirstTabViewController01C alloc] initWithNibName:@"FirstTabViewController01C" bundle:[NSBundle mainBundle]];
					self.firstTabViewController01C = view01c;
					[view01c release];
				}
				[firstTabViewController01C setData:theData];
				firstTabViewController01C.albumDictionary=[mySectionRow objectAtIndex:indexPath.row];
				
				[self.navigationController pushViewController:firstTabViewController01C animated:YES];	
				
				break;
			case 2:
				if(self.firstTabViewController01D == nil){
					FirstTabViewController01D *view01d = [[FirstTabViewController01D alloc] initWithNibName:@"FirstTabViewController01D" bundle:[NSBundle mainBundle]];
					self.firstTabViewController01D = view01d;
					[view01d release];
				}
				[firstTabViewController01D setData:theData];
				firstTabViewController01D.musicBoxDictionary=[mySectionRow objectAtIndex:indexPath.row];
				
				[self.navigationController pushViewController:firstTabViewController01D animated:YES];	
				
				break;
			default:
				break;
		}
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
	NSString *fileName = [[theURL path] lastPathComponent];
	NSString *filePath = [appDelegate.dataPath stringByAppendingPathComponent:fileName];
	
	//NSLog(@"1");
	if([appDelegate imgExistsAtCache:fileName])
	{
		//NSLog([NSString stringWithFormat:@"2 : %d",index]);
		//NSLog(filePath);
		[[mySectionRow objectAtIndex:index.row] setObject:filePath forKey:ImageView];
		//NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
		//m=(NSMutableDictionary *)[mySectionRow objectAtIndex:index];
		//[m setObject:filePath forKey:ImageView];
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
