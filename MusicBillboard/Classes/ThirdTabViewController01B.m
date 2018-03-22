//
//  ThirdTabViewContorller01B.m
//  Music01
//
//  Created by bko on 2009/8/11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ThirdTabViewController01B.h"
#import "Song.h"
#import "avTouchViewController.h"
#import "Music01AppDelegate.h"
#import "Constants.h"
#import "CustomCell.h"
#import "XMLParser.h"
#import "URLCacheAlert.h"
#import "DetailAlert.h"
@implementation ThirdTabViewController01B

@synthesize songsTableView,appDelegate,avController,contentLabel,activityDictionary,mySectionRow,picView;
@synthesize xmlData;
@synthesize activityIndicator;
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
	activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	activityIndicator.frame = CGRectMake(141.0f, 187.0f, 37.0f, 37.0f);
	[self.view addSubview:activityIndicator];
	
	self.mySectionRow = [[NSMutableArray alloc] init];
	
	UIBarButtonItem *infoButton = [[[UIBarButtonItem alloc]
								   initWithTitle:NSLocalizedString(@"詳情", @"")
								   style:UIBarButtonItemStyleBordered
								   target:self
								   action:@selector(showInfo:)] autorelease];
	
	self.navigationItem.rightBarButtonItem=infoButton;
	
	detailView = [[DetailAlert alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 240.0f)];
	[self.view addSubview:detailView];
	clicked=NO;
	[self initAppDelegate];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[self initActivityInfo];
	[self initDataSource];
	[self.songsTableView reloadData];
}
/*
-(void)viewDidAppear:(BOOL)animated
{
	[self startAnimation];
	[self initActivityInfo];
	[self initDataSource];
	[self.songsTableView reloadData];
	[self stopAnimation];
}*/

-(void)setData:(NSData *)theData
{
	self.xmlData = theData;
}

-(void)initAppDelegate{
	if(appDelegate == nil)
		appDelegate = (Music01AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)initDataSource{
	[self.mySectionRow removeAllObjects];
	//NSString *songsUrl=[activityDictionary objectForKey:ContentListUrl];
	//NSLog(@"musicbox_songs_url-> %@",songsUrl);
	
	//NSArray *tmpArray=[appDelegate initSongsDataSource:songsUrl];

	NSString *debugString;
	debugString=@"initDataSource";
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
	//Initialize the delegate.
	XMLParser *parser = [[XMLParser alloc] initXMLParser];
	
	//Set delegate
	[xmlParser setDelegate:parser];
	
	//Start parsing the XML file.
	BOOL success = [xmlParser parse];
	
	if(!success)
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,@"Fail Parse Xml");
	
	NSArray *tmpArray=[[[NSArray alloc] initWithArray:parser.finishedParserArray] autorelease];
	
	for (Song *element in tmpArray) {
		NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
		if(element.song!= nil)
			[rowData setObject:element.song forKey:PrimaryLabel];
		if(element.singer!= nil)
			[rowData setObject:element.singer forKey:SecondaryLabel];
		if(element.productid!= nil)
			[rowData setObject:element.productid forKey:ThirdLabel];
		//[rowData setObject:element.cpname forKey:FourthLabel];
		[rowData setObject:DefaultImage forKey:ImageView];		
		if(element.price!= nil)
			[rowData setObject:element.price forKey:FifthLabel];
		[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
		[rowData setObject:element forKey:InstanceOfObject];
		[self.mySectionRow addObject:rowData];
		[rowData release];
	}
	
}
-(void)initActivityInfo{
	contentLabel.text=[activityDictionary objectForKey:PrimaryLabel];
	/*NSMutableString *tmpstring=[[NSMutableString alloc] initWithString:[activityDictionary objectForKey:ThirdLabel]];
	NSString *end=[activityDictionary objectForKey:FourthLabel];
	[tmpstring appendString:@" ~ "];
	[tmpstring appendString:end];
	dateLabel.text=tmpstring;
	[tmpstring release];*/
	//NSLog(@"test3-> %@",[activityDictionary objectForKey:SecondaryLabel]);
	[detailView setMessage:[activityDictionary objectForKey:SecondaryLabel]];
	
	NSString *imgpath=[activityDictionary objectForKey:ImageView];	
	if([[imgpath pathComponents] count]==1 ){		
		picView.image=[UIImage imageNamed:imgpath];
	}
	else
		picView.image=[UIImage imageWithContentsOfFile:imgpath];
	picView.frame = CGRectMake(10, 20, 60, 60);
		
	
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


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
	[songsTableView release];
	[appDelegate release];
	[avController release];
	[contentLabel release];
	//[dateLabel release];
	[activityDictionary release];
	[mySectionRow release];
	[picView release];
	[detailView release];
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
#pragma mark show infomation methods
- (void) showInfo:(id)sender{
		
	
	 //TestAlert *aView=[[[NSBundle mainBundle] loadNibNamed:@"TestAlert" owner:self options:nil] objectAtIndex:0];
	//[aView presentView];	
	//if(click)
	
	//detailView = [[DetailAlert alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 240.0f)];
	//[self.view addSubview:detailView];
	if(clicked){
		[self.navigationItem.rightBarButtonItem setTitle:@"詳情"];
		[detailView removeView];
		clicked=NO;
		//NSLog(@"test1");
	}else{
		[self.navigationItem.rightBarButtonItem setTitle:@"返回"];
		[detailView presentView];
		clicked=YES;
		//NSLog(@"test2");
	}
}


#pragma mark -
#pragma mark UITableViewDataSource methods

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
		
		//cell.dataDictionary = [mySectionRow objectAtIndex:indexPath.row];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}
	return cell;
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


#pragma mark -
#pragma mark UITableViewDelegate methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return HeightForRow6;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if(self.avController == nil){
		avTouchViewController *view01 = [[avTouchViewController alloc] initWithNibName:@"avTouchViewController" bundle:[NSBundle mainBundle] ];
		self.avController = view01;
		[view01 release];
	}
	[avController setDictionary:[mySectionRow objectAtIndex:indexPath.row]];
	[self.navigationController setHidesBottomBarWhenPushed:YES];
	[self.navigationController pushViewController:avController animated:YES];	
	
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
		[self.songsTableView reloadData];	
	}

	[theConnection release];
	
}


@end
