//
//  FourthTabRootViewController.m
//  Music01
//
//  Created by albert on 2009/6/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FourthTabRootViewController.h"
#import "FourthTabViewController01.h"
#import "CustomCell.h"
#import "Constants.h"
#import "Music01AppDelegate.h"
#import "SongSearch.h"

@implementation FourthTabRootViewController
@synthesize myTableView;
@synthesize myTableSection;
@synthesize mySectionRow;
@synthesize sBar;
//@synthesize fourthTabViewController01;
@synthesize myQuery;
@synthesize activityIndicator;
@synthesize searchConnection;
@synthesize	searchData;

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
	defaultTintColor = self.sBar.tintColor;
	//sBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0,0,320,50)];
	//sBar.delegate = self;
	//[self.view addSubview:sBar];

	self.myTableSection = [[NSMutableArray alloc] init];
	self.mySectionRow = [[NSMutableDictionary alloc] init];	
	[self initAppDelegate];
	[self initDataSource];
	//NSMutableArray *dataSource; //will be storing all the data
	//NSMutableArray *tableData;//will be storing data that will be displayed in table
	//NSMutableArray *searchedData;//will be storing data matching with the search string
	//[tableData addObjectsFromArray:dataSource];//on launch it should display all the records 
}
- (void)viewWillAppear:(BOOL)animated
{
	//myTableView.backgroundColor = [UIColor clearColor];
	//self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque ;
	if([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault)
	{
		self.sBar.tintColor = defaultTintColor;
		self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	}else if([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleBlackOpaque)
	{
		self.sBar.tintColor = [UIColor darkGrayColor];
		self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque ;
	}else if([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleBlackTranslucent)
	{
		self.sBar.tintColor = [UIColor darkGrayColor];
		self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent ;
	}
	//[self stopAnimation];
}

- (void)initDataSource{
	NSString *debugString;
	debugString=@"initDataSource";
	//section
	//self.myTableSection =[[NSArray alloc] initWithObjects:@"熱門主題",@"關鍵字",nil];
	//menu list
	//mySectionRow00 = [[NSArray alloc] initWithObjects:@"總排行",@"國語（男）",@"國語（女）",@"國語（團體）",@"台語",@"日韓",@"西洋",@"情調",nil];
	//self.mySectionRow =  [[NSMutableArray alloc] init];
	//for(int i=0;i<2;i++)
	//{
	/*	[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 @"早點回家", PrimaryLabel,
								 @" ", SecondaryLabel,
								 @"綠綠綠", KeyWord,
								 nil]];
		[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 @"蘇打綠", PrimaryLabel,
								 @" ", SecondaryLabel,
								 @"綠綠綠", KeyWord,
								 nil]];	
	*/
	//}
	if( appDelegate.searchTopicList == nil)
		[appDelegate initDataSource:SearchTopicKeyword orLink:nil withData:nil];
	
	self.mySectionRow = appDelegate.searchTopicList;
	for(NSString *element in [appDelegate.searchTopicList allKeys])
	{
		[self.myTableSection addObject:element];
		/*NSLog(element);
		for(SongSearch *song in [appDelegate.searchTopicList objectForKey:element])
		{
			NSLog(song.title);
		}*/
	}
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	// only show the status bar’s cancel button while in edit mode
	sBar.showsCancelButton = YES;
	sBar.autocorrectionType = UITextAutocorrectionTypeNo;
	
	// flush the previous search content
	//[mySectionRow removeAllObjects];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	sBar.showsCancelButton = NO;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	self.myQuery = searchText;
	/*
	 This method will be called whenever text in the search bar is changed. 
	 We should update tableData array accordingly. So the first line[tableData removeAllObjects]; 
	 removes all the searched records from previous search string.Then we check if the search 
	 string is null so that we should return immediately with and empty tableData.
	 If the searchString is not null then we will go through each object in dataSource and select 
	 those objects which have the occurrence of search string in beginning. You can modify the 
	 code to have any kind of search though.The last line[myTableView reloadData]; refreshes the 
	 table view. What ever be the content of tableData will be shown now.
	 */
	//[mySectionRow removeAllObjects];// remove all data that belongs to previous search
	//NSLog(@"doing search");
	//[self initDataSource];
	/*
	if([searchText isEqualToString:@""]searchText==nil){
		[myTableView reloadData];
		return;
	}
	NSInteger counter = 0;
	for(NSString *name in dataSource)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
		NSRange r = [name rangeOfString:searchText];
		if(r.location != NSNotFound)
		{
			if(r.location== 0)//that is we are checking only the start of the names.
			{
				[tableData addObject:name];
			}
		}
		//if you want that the searched records should have search string occurance at any place, here is an alternative implementation of
		//if(r.location != NSNotFound)
		//[tableData addObject:name];
		counter++;
		[pool release];
	}*/
	
	//[myTableView reloadData];
}
/*We should also show all the records if the search string is cleared or cancelled. For that add the following code:*/

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	// if a valid search was entered but the user wanted to cancel, bring back the main list content
	
	//[mySectionRow removeAllObjects];
	/*[mySectionRow addObjectsFromArray:dataSource];
	@try{
		[myTableView reloadData];
	}
	@catch(NSException *e){
	}
	 */
	NSLog(@"cancel");
	[sBar resignFirstResponder];
	sBar.text = @"";
}
// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	NSLog(@"click");
	//[self initDataSource];
	[searchBar resignFirstResponder];
	[self showResult:myQuery];
}
	


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	int count=0;
	NSString *debugString;
	debugString=@"tableView:numberOfRowsInSection";
	@try{
		count=[[mySectionRow objectForKey:[myTableSection objectAtIndex:section]] count];
		//NSLog([NSString stringWithFormat:@"%d",count]);
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


-(CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section{
	return HeightForHeader3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return HeightForRow3;
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
	}
	@finally {
		return title;
	}
	 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";	
	NSString *debugString;
	debugString=@"tableView:cellForRowAtIndexPath";
	/*CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[[CustomCell alloc] initWithViewStyle:STYLE3] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	@try{
		cell.dataDictionary = [mySectionRow objectAtIndex:indexPath.row];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}*/
	
	UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell==nil){
		cell=[[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier]autorelease];
	}
	SongSearch *aSongSearch=[[mySectionRow objectForKey:[myTableSection objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	//cell.text = aSongSearch.title;
	cell.textLabel.text=aSongSearch.title;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	/*
	if(self.fourthTabViewController01 == nil){
		FourthTabViewController01 *view01 = [[FourthTabViewController01 alloc] initWithNibName:@"FourthTabView01" bundle:[NSBundle mainBundle]];
		self.fourthTabViewController01 = view01;
		[view01 release];
	}
	[self.fourthTabViewController01 setSearch:myQuery];
	[self.navigationController pushViewController:fourthTabViewController01 animated:YES];	
	 */
	SongSearch *aSongSearch=[[mySectionRow objectForKey:[myTableSection objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
	[self showResult:aSongSearch.keyword];
	NSLog(aSongSearch.keyword);
	//for 中文轉換
	/*NSString *searchWord =[[NSString alloc] initWithString:aSongSearch.keyword];
	//NSLog(aSongSearch.keyword);
	NSMutableString *msgString=[[NSMutableString alloc] init];
	for(int i=0;i<[searchWord length];i++){
		if([searchWord characterAtIndex:i]>0x007f){
			NSInteger n=[searchWord characterAtIndex:i];		
			
			NSString *hexString = [NSString stringWithFormat:@"\\u%x", n];
			[msgString appendString:hexString];
		}else{
			NSRange r={i,1};
			
			[msgString appendString:[searchWord substringWithRange:r]];
			//NSLog(@"test substring-> %@",[searchWord substringWithRange:r]);
		}
	}
	//NSLog(@"test0.....a-> %@",msgString);	
	NSMutableURLRequest *searchURLRequest = [NSMutableURLRequest requestWithURL:[appDelegate.WSArray objectAtIndex:Searching]];	
	[searchURLRequest addValue:msgString forHTTPHeaderField:@"topicid"];	
	self.searchConnection = [[[NSURLConnection alloc] initWithRequest:searchURLRequest delegate:self] autorelease];
	
	[searchWord release];
	[msgString release];
	
	NSAssert(self.searchConnection != nil, @"Failure to create URL connection.");
	
	[self startAnimation];*/
}
/*
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryDisclosureIndicator;
}
*/
-(void)showResult:(NSString *)strQuery
{
	/*
	if(self.fourthTabViewController01 == nil){
		FourthTabViewController01 *view01 = [[FourthTabViewController01 alloc] initWithNibName:@"FourthTabView01" bundle:[NSBundle mainBundle]];
		self.fourthTabViewController01 = view01;
		[view01 release];
	}
	[self.fourthTabViewController01 setSearch:myQuery];
	[self.navigationController pushViewController:fourthTabViewController01 animated:YES];	
	*/

	//for 中文轉換
	NSString *searchWord =[[NSString alloc] initWithString:strQuery];
	//NSLog(aSongSearch.keyword);
	NSMutableString *msgString=[[NSMutableString alloc] init];
	for(int i=0;i<[searchWord length];i++){
		if([searchWord characterAtIndex:i]>0x007f){
			NSInteger n=[searchWord characterAtIndex:i];		
			
			NSString *hexString = [NSString stringWithFormat:@"\\u%x", n];
			[msgString appendString:hexString];
		}else{
			NSRange r={i,1};
			
			[msgString appendString:[searchWord substringWithRange:r]];
			//NSLog(@"test substring-> %@",[searchWord substringWithRange:r]);
		}
	}
	//NSLog(@"test0.....a-> %@",msgString);	
	NSMutableURLRequest *searchURLRequest = [NSMutableURLRequest requestWithURL:[appDelegate.WSArray objectAtIndex:Searching]];	
	[searchURLRequest addValue:msgString forHTTPHeaderField:@"topicid"];	
	self.searchConnection = [[[NSURLConnection alloc] initWithRequest:searchURLRequest delegate:self] autorelease];
	
	[searchWord release];
	[msgString release];
	
	NSAssert(self.searchConnection != nil, @"Failure to create URL connection.");
	
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

#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how the connection object,
// which is working in the background, can asynchronously communicate back to its delegate on the thread from which it was
// started - in this case, the main thread.

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
    self.searchData = [NSMutableData data];
	//NSLog(@"test1.....searchData->%d",[searchData length]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
    [searchData appendData:data];
	//NSLog(@"test2.....searchData->%d",[searchData length]);
}

/*- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
 if ([error code] == kCFURLErrorNotConnectedToInternet) {
 // if we can identify the error, we can present a more precise message to the user.
 NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Connection Error", @"Error message displayed when not connected to the Internet.") forKey:NSLocalizedDescriptionKey];
 NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
 [self handleError:noConnectionError];
 } else {
 // otherwise handle the error generically
 [self handleError:error];
 }
 self.searchConnection = nil;
 }*/

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.searchConnection = nil;
    [self stopAnimation];  
    // Spawn a thread to fetch the earthquake data so that the UI is not blocked while the application parses the XML data.
    //
    // IMPORTANT! - Don't access UIKit objects on secondary threads.
    //
    //[NSThread detachNewThreadSelector:@selector(parseEarthquakeData:) toTarget:self withObject:earthquakeData];
    // earthquakeData will be retained by the thread until parseEarthquakeData: has finished executing, so we no longer need
    // a reference to it in the main thread.
    //self.searchData = nil;
	//NSString *rMesg=[[NSString alloc] initWithData:searchData encoding:NSUTF8StringEncoding];
	
	//NSLog(@"test3.....");
	//[rMesg release];	
	
	
	//SongViewController *songViewController=[[SongViewController alloc] initWithNibName:@"SongViewController" bundle:nil];
	//songViewController.xmlData=searchData;	
	//[self.navigationController pushViewController:songViewController animated:YES];
	FourthTabViewController01 *view01 = [[FourthTabViewController01 alloc] initWithNibName:@"FourthTabView01" bundle:[NSBundle mainBundle]];

	[view01 setData:searchData];
	[self.navigationController pushViewController:view01 animated:YES];
}


@end
