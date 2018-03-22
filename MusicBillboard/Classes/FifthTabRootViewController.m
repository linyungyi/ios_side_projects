//
//  FifthTabRootViewController.m
//  Music01
//
//  Created by albert on 2009/6/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FifthTabRootViewController.h"
#import "CustomCell.h"
#import "Constants.h"
#import "Music01AppDelegate.h"
#import "Song.h"

@implementation FifthTabRootViewController

@synthesize myTableView;
@synthesize myTableSection;
@synthesize mySectionRow;
@synthesize titleMap;
@synthesize activityIndicator;
@synthesize xmlData;
@synthesize	ruleMap;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

-(void)initAppDelegate {
	if(appDelegate == nil)
		appDelegate = (Music01AppDelegate *)[[UIApplication sharedApplication] delegate];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	UIBarButtonItem *addButton = [[[UIBarButtonItem alloc]
								   initWithTitle:NSLocalizedString(@"申租", @"")
								   style:UIBarButtonItemStyleBordered
								   target:self
								   action:@selector(EditTable:)] autorelease];
	self.navigationItem.rightBarButtonItem = addButton;	
	
	[super viewDidLoad];
	activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	activityIndicator.frame = CGRectMake(141.0f, 187.0f, 37.0f, 37.0f);
	[self.view addSubview:activityIndicator];
	
	self.titleMap = [NSDictionary dictionaryWithObjectsAndKeys:
	 @"基本音",@"basic",@"白天音",@"daylight",@"晚上音",@"night",@"週末音",@"weekend",@"群組一",@"group1",@"群組二",@"group2",@"群組三",@"group3",@"群組四",@"group4",@"群組五",@"group5",nil];
	self.ruleMap = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithInt:0],@"basic",[NSNumber numberWithInt:6],@"daylight",[NSNumber numberWithInt:7],@"night",[NSNumber numberWithInt:8],@"weekend",[NSNumber numberWithInt:1],@"group1",[NSNumber numberWithInt:2],@"group2",[NSNumber numberWithInt:3],@"group3",[NSNumber numberWithInt:4],@"group4",[NSNumber numberWithInt:5],@"group5",nil];
	self.myTableSection = [[NSMutableArray alloc] init];
	self.mySectionRow = [[NSMutableArray alloc] init];
	[self initAppDelegate];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	//myTableView.backgroundColor = [UIColor clearColor];
	//self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque ;
	//myTableView.backgroundColor = [UIColor clearColor];
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
	
	//[self.myTableView reloadData];

}

-(void)viewDidAppear:(BOOL)animated
{
	[self initDataSource];
	[self.myTableView reloadData];
	//[self stopAnimation];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(appDelegate.rbtMember != nil)
	{
		//NSLog(@"a");
		if([appDelegate.rbtMember isEqualToString:@"Y"])
		{
			//NSLog(@"b");
			[super setEditing:NO animated:NO]; 
			[myTableView setEditing:NO animated:NO];
			[self.navigationItem.rightBarButtonItem setTitle:@"編輯"];
			[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];	
		}
	}
}

-(void)showResult{
	//if( appDelegate.userProfile == nil)
		[appDelegate initDataSource:UserProfile orLink:nil withData:self.xmlData];
	
	if([appDelegate.rbtMember isEqualToString:@"Y"])
	{
		//NSLog(@"c");
		[super setEditing:NO animated:NO]; 
		[myTableView setEditing:NO animated:NO];
		[self.navigationItem.rightBarButtonItem setTitle:@"編輯"];
		[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
	}
	
	NSArray *array=[[appDelegate.userProfile allKeys] sortedArrayUsingSelector:@selector(compare:)];
	for(NSString *element in array)
	{
		[self.myTableSection addObject:[titleMap objectForKey:element]];
		
		NSMutableArray *arraySong = [[NSMutableArray alloc] init];
		for(Song *song in [appDelegate.userProfile objectForKey:element])
		{
			NSMutableDictionary *Data = [[NSMutableDictionary alloc] init];
			[Data setObject:[NSString stringWithFormat:@"%@  %@",song.song,song.singer] forKey:PrimaryLabel];
			[Data setObject:[NSString stringWithFormat:@"答鈴編號：%@",song.productid] forKey:SecondaryLabel];
			[Data setObject:DefaultImage forKey:ImageView];
			[Data setObject:song.productid forKey:RingID];
			[Data setObject:[ruleMap objectForKey:element] forKey:RuleID];

			if(song.img_artist != nil)
				[Data setObject:[NSURL URLWithString:song.img_artist] forKey:ImageUrl];
			//NSLog(song.img_artist);
			[arraySong addObject:Data];
		}
		[self.mySectionRow addObject:arraySong];
		
	}
}

- (void)initDataSource{
	[self startAnimation];
	[self.myTableSection removeAllObjects];
	[self.mySectionRow removeAllObjects];
	
	(void) [[URLXmlConnection alloc] initWithURL:[(NSArray *)appDelegate.WSArray objectAtIndex:UserProfile] delegate:self atIndex:@"UserProfile"];
	
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

	int count=0;
	NSString *debugString;
	debugString=@"tableView:numberOfRowsInSection";
	@try{
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
	CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[[CustomCell alloc] initWithViewStyle:STYLE3] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		//cell.hidesAccessoryWhenEditing =  YES;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	@try{
		if([[[mySectionRow objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:ImageUrl] != nil)
			[self cacheImageWithURL:[[[mySectionRow objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:ImageUrl] atIndex:indexPath];

		cell.dataDictionary = [[mySectionRow objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}
	return cell;
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.secondTabViewController01 == nil){
		SecondTabViewController01 *view01 = [[SecondTabViewController01 alloc] initWithNibName:@"SecondTabView01" bundle:[NSBundle mainBundle]];
		self.secondTabViewController01 = view01;
		[view01 release];
	}
	
	[self.navigationController pushViewController:secondTabViewController01 animated:YES];	
	
}*/

// Update the data model according to edit actions delete or insert.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSString *tmpRingId = [[[mySectionRow objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:RingID];		
		NSString *tmpRuleId = [[[[mySectionRow objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:RuleID] stringValue]; 
		NSMutableString *tmpUrl = [[NSMutableString alloc] initWithString:@"http://musicphone.emome.net/MAS/irbtConfig.jsp?cmdtype=deleterbt&PRODUCTID="];
		[tmpUrl appendString:tmpRingId];
		[tmpUrl appendString:@"&RULEID="];
		[tmpUrl appendString:tmpRuleId];
		
		(void) [[URLXmlConnection alloc] initWithURL:[[NSURL alloc] initWithString:tmpUrl] delegate:self atIndex:indexPath];
		[tmpUrl release];
		[self startAnimation];
		
        //[[mySectionRow objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row] ;
		//[myTableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [[mySectionRow objectAtIndex:indexPath.section] insertObject:@"New Song" atIndex:[[mySectionRow objectAtIndex:indexPath.section] count]];
		[myTableView reloadData];
    }
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Determine whether a given row is eligible for reordering or not.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
// Process the row move. This means updating the data model to correct the item indices.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
	  toIndexPath:(NSIndexPath *)toIndexPath {
	NSMutableDictionary *item = [[[mySectionRow objectAtIndex:fromIndexPath.section] objectAtIndex:fromIndexPath.row] retain];
	[[mySectionRow objectAtIndex:fromIndexPath.section] removeObject:item];
	[[mySectionRow objectAtIndex:toIndexPath.section] insertObject:item atIndex:toIndexPath.row];
	[item release];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {

	[myTableView release];
	[myTableSection release];
	[mySectionRow release];
	[titleMap release];
	[activityIndicator release];	
    [super dealloc];
}

- (IBAction) EditTable:(id)sender{
	//NSLog(@"ddd");
	if(appDelegate.rbtMember != nil)
	{
		//NSLog(@"ccc");
		if([appDelegate.rbtMember isEqualToString:@"Y"])
		{
			//NSLog(@"bbb");
			if(self.editing)
			{
				[super setEditing:NO animated:NO]; 
				[myTableView setEditing:NO animated:NO];
				[myTableView reloadData];
				[self.navigationItem.rightBarButtonItem setTitle:@"編輯"];
				[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
			}
			else
			{
				[super setEditing:YES animated:YES]; 
				[myTableView setEditing:YES animated:YES];
				[myTableView reloadData];
				[self.navigationItem.rightBarButtonItem setTitle:@"完成"];
				[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
			}			
		}else
		{
			//NSLog(@"aaa");
			UIAlertView *confirmAlert =
			[[UIAlertView alloc] initWithTitle:@"申租來電答鈴" message:@"確定申租？"
									  delegate:self cancelButtonTitle:@"取消" 
							 otherButtonTitles:@"確定", nil];
			[confirmAlert show];
			[confirmAlert release];
		}
	}
 
}
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	
	if(buttonIndex == 1)
	{
		//NSLog(@"ok");
		NSMutableString *tmpUrl = [[NSMutableString alloc] initWithString:@"http://musicphone.emome.net/MAS/rbtConfig.jsp?cmdtype=adduser"];
		
		(void) [[URLXmlConnection alloc] initWithURL:[[NSURL alloc] initWithString:tmpUrl] delegate:self atIndex:@"NewUser"];
		[tmpUrl release];
		[self startAnimation];
		
	}
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
	[self stopAnimation];
}
//- (void) xmlConnectionDidFinish:(URLXmlConnection *)theConnection recData:(NSMutableData *)theData atIndex:(NSIndexPath *)index
- (void) xmlConnectionDidFinish:(URLXmlConnection *)theConnection recData:(NSMutableData *)theData atIndex:(id)index
{
	[self stopAnimation];
	self.xmlData=theData;
	
	if([index isKindOfClass:[NSIndexPath class]])
	{
		NSIndexPath *indexPath = (NSIndexPath *)index;
		@try{
			NSString *rMesg=[[NSString alloc] initWithData:self.xmlData encoding:NSUTF8StringEncoding];
			NSRange startrange=[rMesg rangeOfString:@"<result>"];
			NSRange endrange=[rMesg rangeOfString:@"</result>"];
			NSInteger startnumber=startrange.location+startrange.length;
			NSInteger lenghnumber=endrange.location-startnumber;
			NSRange sub={startnumber,lenghnumber};
			NSString *sMsg=[rMesg substringWithRange:sub];
			if([sMsg isEqualToString:@"success"]){
				UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"答鈴設定" message:@"刪除成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
				[alert show];
				//刪除tableview項目
				[[mySectionRow objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row] ;
				
			}else if([sMsg isEqualToString:@"fail"]){
				UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"答鈴設定" message:@"刪除失敗" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
				[alert show];
			}	
		}@catch (NSException *ex) {
			UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"答鈴設定" message:@"伺服器發生錯誤" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
			[alert show];
		}
	}else
	{
		if([index isKindOfClass:[NSString class]])
		{
			NSString *tmpStr = (NSString *)index;
			if([tmpStr isEqualToString:@"UserProfile"])
			{
				[self showResult];
			}else if([tmpStr isEqualToString:@"NewUser"])
			{
				@try{
					NSString *rMesg=[[NSString alloc] initWithData:self.xmlData encoding:NSUTF8StringEncoding];
					//NSLog(rMesg);
					NSRange startrange=[rMesg rangeOfString:@"<result>"];
					NSRange endrange=[rMesg rangeOfString:@"</result>"];
					NSInteger startnumber=startrange.location+startrange.length;
					NSInteger lenghnumber=endrange.location-startnumber;
					NSRange sub={startnumber,lenghnumber};
					NSString *sMsg=[rMesg substringWithRange:sub];
					if([sMsg isEqualToString:@"success"]){
						UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"申請來電答鈴" message:@"申租成功" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
						[alert show];
						
						[super setEditing:NO animated:NO]; 
						[myTableView setEditing:NO animated:NO];
						[self.navigationItem.rightBarButtonItem setTitle:@"編輯"];
						[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
						
						appDelegate.rbtMember = @"Y";
						
					}else if([sMsg isEqualToString:@"fail"]){
						UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"申請來電答鈴" message:@"申租失敗" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
						[alert show];
					}	
				}@catch (NSException *ex) {
					UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"申請來電答鈴" message:@"伺服器發生錯誤" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
					[alert show];
				}
				
			}
		}
	}
	
	[myTableView reloadData];
	
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
		[[[mySectionRow objectAtIndex:index.section] objectAtIndex:index.row] setObject:filePath forKey:ImageView];

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
		[[[mySectionRow objectAtIndex:index.section] objectAtIndex:index.row] setObject:theAtCacheFilePath forKey:ImageView];
		[appDelegate.imgCacheDictionary setObject:[NSNumber numberWithInt:1] forKey:[theAtCacheFilePath lastPathComponent]];
		[self.myTableView reloadData];
	}

	[theConnection release];
	
}


@end
