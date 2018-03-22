//
//  MySongsViewController.m
//  Music01
//
//  Created by bko on 2009/8/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "URLXmlConnection.h"
#import "URLCacheConnection.h"
#import "MySongsViewController.h"
#import "CustomCell.h"
#import "Music01AppDelegate.h"
#import "XMLParser.h"
#import "Constants.h"
#import "Song.h"
#import "avTouchViewController.h"


@implementation MySongsViewController

@synthesize mysongTableView,mysongDic,mySectionRow,appDelegate,xmlData,activityIndicator;

@synthesize avController;
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
	
	//for my songs 
	uploadButton = [[UIBarButtonItem alloc]
				 initWithTitle:@"同步"
				 style:UIBarButtonItemStyleBordered
				 target:self
				 action:@selector(synMySong:)] ;	
	self.navigationItem.rightBarButtonItem = uploadButton;
	addfinish=NO;
	deletefinish=NO;
	[self initAppDelegate];
	
	//load the playlist form server in the first time
	//connect to server				
	NSURL *nUrl=[[NSURL alloc] initWithString:@"http://musicphone.emome.net/MAS/DoTask?Task=MySongList&xsl=pcIni.xsl&type=mobile"];
	[self startAnimation];
	(void) [[URLXmlConnection alloc] initWithURL:nUrl delegate:self atIndex:@"newlist"];
	[nUrl release];	
	
	
}

- (void)viewWillAppear:(BOOL)animated
{
	//reload mysongTableView when local add new songs to playlistDic
	[self initDataSource:nil];
		
}

-(void)initAppDelegate{
	if(appDelegate == nil)
		appDelegate = (Music01AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)initDataSource:(NSArray *) tArray{
	
	//init listDic from server
	if(tArray!=nil){
		[appDelegate.serverlistDic removeAllObjects];
		[appDelegate.playlistDic removeAllObjects];	
		for (Song *element in tArray) {			
			[appDelegate.serverlistDic setObject:element forKey:element.productid];
			[appDelegate.playlistDic setObject:element forKey:element.productid];
		}
	}
	
	
	NSLog(@"MySongs, initDataSource(), serverlistDic-> %d",appDelegate.serverlistDic.count);
	NSLog(@"Mysongs, initDataSource(), playlistDic-> %d",appDelegate.playlistDic.count);
	
	NSEnumerator *enumerator = [appDelegate.playlistDic objectEnumerator];
	self.mySectionRow = [[NSMutableArray alloc] init];
	Song *element;
	while ((element = [enumerator nextObject])) {
		NSMutableDictionary *rowData = [[NSMutableDictionary alloc] init];
		[rowData setObject:element.song forKey:PrimaryLabel];
		[rowData setObject:element.singer forKey:SecondaryLabel];
		[rowData setObject:element.productid forKey:ThirdLabel];		
		[rowData setObject:@"question.png" forKey:ImageView];		
		[rowData setObject:[NSURL URLWithString:element.img_artist] forKey:ImageUrl];
		[rowData setObject:element forKey:InstanceOfObject];			
		[self.mySectionRow addObject:rowData];
		[rowData release];	
	}	
		
	[mysongTableView reloadData];

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
	[mysongDic release];
	[avController release];
	[appDelegate release];
	[xmlData release];
	[mySectionRow release];
	[mysongTableView release];
	[activityIndicator release];
	[uploadButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark parsing xmlData

-(NSArray *) parseXml:(NSData *) tdata{
	NSString *debugString=@"xmlConnectionDidFinish";
	
	//parser
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:tdata];	
	//Initialize the delegate.
	XMLParser *parser = [[XMLParser alloc] initXMLParser];	
	//Set delegate
	[xmlParser setDelegate:parser];	
	//Start parsing the XML file.
	BOOL success = [xmlParser parse];	
	if(!success)
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,@"Fail Parse Xml");
	else
		NSLog(@"pasered success");
	
	NSArray *tmpArray=[[NSArray alloc] initWithArray:parser.finishedParserArray];		
	NSLog(@"MysongsViewController, parseXml(), tmpArray-> %d",tmpArray.count);
	
	return tmpArray;

} 

#pragma mark -
#pragma mark syn MySongs

-(void) synMySong:(id)sender{
	
	NSArray *localkeys=[appDelegate.playlistDic allKeys];
	
	for (int i=0; i<localkeys.count; i++) {
		
		if([appDelegate.serverlistDic objectForKey:[localkeys objectAtIndex:i]]!=nil){
			[appDelegate.serverlistDic removeObjectForKey:[localkeys objectAtIndex:i]];
			[appDelegate.playlistDic removeObjectForKey:[localkeys objectAtIndex:i]];
		} 
	}
	NSLog(@"synMySong()->numbers of delete, serverlistDic-> %d",appDelegate.serverlistDic.count);
	NSLog(@"synMySong()->numbers of add, playlistDic-> %d",appDelegate.playlistDic.count );

	
	 // send localplist to server
	 // set Add url
	 NSMutableString *addsongsString=[[NSMutableString alloc] init];
	 NSArray *addsongsIdArray=[appDelegate.playlistDic allKeys];
	 for(int i=0;i<addsongsIdArray.count;i++){		
		 [addsongsString appendString:[addsongsIdArray objectAtIndex:i]];
	 	 if(i!=addsongsIdArray.count-1)
			 [addsongsString appendString:@"-"];
	 }
	NSMutableString *addurl=[[NSMutableString alloc] initWithString:@"http://musicphone.emome.net/MAS/DoTask?Task=EditSongList&xsl=pcIni.xsl&action=A&songlist="];
	[addurl appendString:addsongsString];
	[addsongsString release];
	NSURL *nAddUrl=[[NSURL alloc] initWithString:addurl];
	 NSLog(@"add songsString url-> %@",addurl);
	
	// set del url
	NSMutableString *delsongsString=[[NSMutableString alloc] init];
	NSArray *delsongsIdArray=[appDelegate.serverlistDic allKeys];
	for(int i=0;i<delsongsIdArray.count;i++){		
		[delsongsString appendString:[delsongsIdArray objectAtIndex:i]];
		if(i!=delsongsIdArray.count-1)
			[delsongsString appendString:@"-"];
	}
	NSMutableString *delurl=[[NSMutableString alloc] initWithString:@"http://musicphone.emome.net/MAS/DoTask?Task=EditSongList&xsl=pcIni.xsl&action=D&songlist="];
	[delurl appendString:delsongsString];
	[delsongsString release];
	NSURL *nDelUrl=[[NSURL alloc] initWithString:delurl];
	NSLog(@"delete songsString url-> %@",delsongsString);
	 
	

	
	//connect to server				
	[self startAnimation];

	
	if(appDelegate.playlistDic.count!=0){
		(void) [[URLXmlConnection alloc] initWithURL:nAddUrl delegate:self atIndex:@"add"];
		NSLog(@"add songs to server");
	}else{
		addfinish=YES;
	}
	if(appDelegate.serverlistDic.count!=0){
		(void) [[URLXmlConnection alloc] initWithURL:nDelUrl delegate:self atIndex:@"del"];
		NSLog(@"delete songs to server");
	}else {
		deletefinish=YES;
	}

	if(appDelegate.serverlistDic.count==0 && appDelegate.playlistDic.count==0){
		addfinish=NO;
		deletefinish=NO;
		//set newlist url
		NSURL *nUrl=[[NSURL alloc] initWithString:@"http://musicphone.emome.net/MAS/DoTask?Task=MySongList&xsl=pcIni.xsl&type=mobile"];
		(void) [[URLXmlConnection alloc] initWithURL:nUrl delegate:self atIndex:@"reloadlist"];
		[nUrl release];
		
	}
	
	[addurl release];
	[delurl release];
	[nAddUrl release];
	[nDelUrl release];
		
	
}

#pragma mark -
#pragma mark Animation
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
#pragma mark xmlConnection
- (void) xmlConnectionDidFail:(URLXmlConnection *)theConnection atIndex:(NSIndexPath *)index
{
	UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"MySongsViewController" message:@"connect fail" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
	[alert show];
	[self stopAnimation];
}
- (void) xmlConnectionDidFinish:(URLXmlConnection *)theConnection recData:(NSMutableData *)theData atIndex:(id)index

{	
	NSLog(@"xmlConnectionDidFinish(), type-> %@",index);
	[self stopAnimation];
	NSLog(@"test1-> %@",(NSString *)index);
	
	if([(NSString *)index isEqualToString:@"add"]){
		addfinish=YES;
	}else if([(NSString *)index isEqualToString:@"del"]){
		deletefinish=YES;
	}
	
	//when add and delete finished, reload the playlist from server
	if(addfinish && deletefinish){
		addfinish=NO;
		deletefinish=NO;
		//set newlist url
		NSURL *nUrl=[[NSURL alloc] initWithString:@"http://musicphone.emome.net/MAS/DoTask?Task=MySongList&xsl=pcIni.xsl&type=mobile"];
		(void) [[URLXmlConnection alloc] initWithURL:nUrl delegate:self atIndex:@"reloadlist"];
		[nUrl release];
		
	}
	
	
	if([(NSString *)index isEqualToString:@"newlist"] || [(NSString *)index isEqualToString:@"reloadlist"]){
		NSLog(@"test2-> %@",index);
		[self initDataSource:[self parseXml:theData]];		
		
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

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		/*NSString *tmpRingId = [[[mySectionRow objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:RingID];		
		NSString *tmpRuleId = [[[[mySectionRow objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:RuleID] stringValue]; 
		NSMutableString *tmpUrl = [[NSMutableString alloc] initWithString:@"http://musicphone.emome.net/MAS/rbtConfig.jsp?cmdtype=deleterbt&PRODUCTID="];
		[tmpUrl appendString:tmpRingId];
		[tmpUrl appendString:@"&RULEID="];
		[tmpUrl appendString:tmpRuleId];
		
		(void) [[URLXmlConnection alloc] initWithURL:[[NSURL alloc] initWithString:tmpUrl] delegate:self atIndex:indexPath];
		[tmpUrl release];
		[self startAnimation];*/
		
		NSString *songID=[[mySectionRow objectAtIndex:indexPath.row] objectForKey:ThirdLabel];
		NSLog(@"delete id-> %@",songID);
		[appDelegate.playlistDic removeObjectForKey:songID];
        [mySectionRow removeObjectAtIndex:indexPath.row] ;
		[mysongTableView reloadData];
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
	avController.sourcetype=@"06";
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
	NSString *fileName = [[theURL path] lastPathComponent];
	NSString *filePath = [appDelegate.dataPath stringByAppendingPathComponent:fileName];
	
	
	if([appDelegate imgExistsAtCache:fileName])
	{
		
		[[mySectionRow objectAtIndex:index.row] setObject:filePath forKey:ImageView];
		return;
	}
	
	
	(void) [[URLCacheConnection alloc] initWithURL:theURL delegate:self cacheFilePath:filePath defaultFilePath:nil atIndex:index];
	
}

- (void) connectionDidFail:(URLCacheConnection *)theConnection atIndex:(NSIndexPath *)index
{	
	
	[theConnection release];
}

- (void) connectionDidFinish:(URLCacheConnection *)theConnection atCacheFilePath:(NSString *)theAtCacheFilePath atIndex:(NSIndexPath *)index
{	
		
	[[mySectionRow objectAtIndex:index.row] setObject:theAtCacheFilePath forKey:ImageView];
	[appDelegate.imgCacheDictionary setObject:[NSNumber numberWithInt:1] forKey:[theAtCacheFilePath lastPathComponent]];
	[self.mysongTableView reloadData];
	[theConnection release];
	
}

@end
