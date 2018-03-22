
#import "avTouchViewController.h"
#import "avTouchController.h"
#import "Music01AppDelegate.h"
#import "Constants.h"
#import "Song.h"
#import "LyricViewController.h"

#define kArmBaseX    160.0
#define kArmBaseY    440.0
#define HORIZ_MIN	 100

//CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

@implementation avTouchViewController

@synthesize myDictionary;
@synthesize rbtPicker,pickerViewArray;
@synthesize timeTypes;
@synthesize groupTypes;
@synthesize xmlData;
@synthesize titleMap;
@synthesize ruleMap;
@synthesize configMap;
@synthesize waitAlert;
@synthesize lyricContent;
@synthesize sourcetype;
@synthesize lyricViewController;

#pragma mark -
#pragma mark UIPickerView

-(void)createPicker
{
	[rbtPicker release];
	//float height = 316.0f;
	rbtPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f,0.0f, 10.0f, 10.0f)];
	//rbtPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f,416.0f - height, 10.0f, 10.0f)];
	rbtPicker.delegate = self;
	rbtPicker.showsSelectionIndicator = YES;
	rbtPicker.dataSource=self;
	rbtPicker.hidden=TRUE;
	[self.view addSubview:rbtPicker];
	[self.view sendSubviewToBack:rbtPicker];
	//NSLog(@"createPicker");
}
-(void)showPicker
{
	rbtPicker.hidden=FALSE;
	[self.view bringSubviewToFront:rbtPicker];
	//NSLog(@"rbtPicker reveal");
}
-(void)hiddenPicker
{
	rbtPicker.hidden=TRUE;
	[self.view sendSubviewToBack:rbtPicker];
	//NSLog(@"rbtPicker hidden");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark -
#pragma mark lyric methods
-(void)createLyricButton
{
	//NSLog(@"createLyricButton");
	UIButton *showLyricButton = [[UIButton buttonWithType:UIButtonTypeInfoLight] initWithFrame:CGRectMake(250.0f, 350.0f, 80.0f, 20.0f)];
	[showLyricButton setTitle:@"歌詞" forState:UIControlStateNormal];
	showLyricButton.backgroundColor = [UIColor clearColor];
	[showLyricButton addTarget:self action:@selector(showLyric) forControlEvents:UIControlEventTouchUpInside];	
	showLyricButton.tag =showLyricButtonIndex;	
	showLyricButton.hidden=TRUE;
	[self.view addSubview:showLyricButton];
	
	UIButton *hiddenLyricButton = [[UIButton buttonWithType:UIButtonTypeInfoLight] initWithFrame:CGRectMake(250.0f, 350.0f, 80.0f, 20.0f)];
	[hiddenLyricButton setTitle:@"歌詞" forState:UIControlStateNormal];
	hiddenLyricButton.backgroundColor = [UIColor clearColor];
	[hiddenLyricButton addTarget:self action:@selector(hiddenLyric) forControlEvents:UIControlEventTouchUpInside];
	hiddenLyricButton.tag =hiddenLyricButtonIndex;	
	hiddenLyricButton.hidden=TRUE;
	[self.view addSubview:hiddenLyricButton];
	
	lyricViewController = [[LyricViewController alloc] initWithNibName:@"LyricViewController" bundle:nil];
	lyricViewController.view.tag=LyricContentIndex;
	lyricViewController.view.hidden=TRUE;
	[self.view addSubview:lyricViewController.view];
	
	/*UIWebView *lyricView=[[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[lyricView setScalesPageToFit:YES];
	lyricView.backgroundColor = [UIColor clearColor];
	lyricView.tag=LyricContentIndex;
	lyricView.hidden=TRUE;
	
	[self.view addSubview:lyricView];*/

}
-(void)changeNavButton:(NSString *)name
{
	if([sourcetype isEqualToString:@"03"]){
		UIBarButtonItem *addButton;
		UIBarButtonItem *cancelButton;
		if([name isEqualToString:@"下載"]){
			addButton = [[[UIBarButtonItem alloc]
						  initWithTitle:NSLocalizedString(@"下載", @"")
						  style:UIBarButtonItemStyleBordered
						  target:self
						  action:@selector(configAction:)] autorelease];
			
			self.navigationItem.leftBarButtonItem = nil;	
			self.navigationItem.rightBarButtonItem = addButton;	
		}else if([name isEqualToString:@"設定"]){
			addButton = [[[UIBarButtonItem alloc]
						  initWithTitle:NSLocalizedString(@"設定", @"")
						  style:UIBarButtonItemStyleDone
						  target:self
						  action:@selector(addAction:)] autorelease];
			cancelButton = [[[UIBarButtonItem alloc]
							 initWithTitle:NSLocalizedString(@"取消", @"")
							 style:UIBarButtonItemStyleBordered
							 target:self
							 action:@selector(cancelConfig:)] autorelease];
			self.navigationItem.leftBarButtonItem = cancelButton;	
			self.navigationItem.rightBarButtonItem = addButton;	
		}else if([name isEqualToString:@"歌詞"]){
			cancelButton = [[[UIBarButtonItem alloc]
							 initWithTitle:NSLocalizedString(@"返回", @"")
							 style:UIBarButtonItemStyleBordered
							 target:self
							 action:@selector(hiddenLyric:)] autorelease];
			self.navigationItem.leftBarButtonItem = cancelButton;	
		}
		//self.navigationItem.rightBarButtonItem = addButton;	
		self.navigationController.hidesBottomBarWhenPushed = YES;
	}
}

-(void)initWithDynLyric
{
	//Song *singleSong=(Song *)[myDictionary objectForKey:InstanceOfObject] ;
	NSMutableString *tmpUrl = [[NSMutableString alloc] initWithString:@"http://musicphone.emome.net/MAS/DoTask?Task=getDynamicLyric&xsl=pcIni.xsl&sourcetype=03&productid=551189"];
	//[tmpUrl appendString:singleSong.productid];
	//[singleSong release];
	(void) [[URLXmlConnection alloc] initWithURL:[[NSURL alloc] initWithString:tmpUrl] delegate:self  atIndex:@"DynLyric"];	
}
-(void)initWithLyric
{
	//[lyricContent release];
	Song *singleSong=(Song *)[myDictionary objectForKey:InstanceOfObject] ;
	NSMutableString *tmpUrl = [[NSMutableString alloc] initWithString:@"http://musicphone.emome.net/MAS/DoTask?Task=getLyric&xsl=pcIni.xsl&sourcetype=03&productid="];
	[tmpUrl appendString:singleSong.productid];
	//[singleSong release];
	(void) [[URLXmlConnection alloc] initWithURL:[[NSURL alloc] initWithString:tmpUrl] delegate:self  atIndex:@"Lyric"];
}
-(void)clearLyric
{
	[self.view viewWithTag:hiddenLyricButtonIndex].hidden=TRUE;
	[self.view viewWithTag:showLyricButtonIndex].hidden=TRUE;
	[self.view viewWithTag:LyricContentIndex].hidden=TRUE;
}
-(void)hiddenLyric:(id)sender
{
	[self changeNavButton:@"下載"];
	CGContextRef context=UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[self.view superview]  cache:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:2.0];
		
	[self.view viewWithTag:hiddenLyricButtonIndex].hidden=TRUE;
	[self.view viewWithTag:showLyricButtonIndex].hidden=FALSE;
	[self.view viewWithTag:LyricContentIndex].hidden=TRUE;
	
	[UIView commitAnimations];
}
-(void)showLyric:(NSString *)direction
{
	//lyricViewController = [[LyricViewController alloc] initWithNibName:@"LyricViewController" bundle:nil];
	//[self.view addSubview:lyricViewController.view];
	//[self.navigationController pushViewController:lyricViewController animated:NO];		
	
	[self changeNavButton:@"歌詞"];

	
	CGContextRef context=UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	if([direction isEqualToString:@"left"])
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[self.view superview]  cache:YES];
	else
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[self.view superview]  cache:YES];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:2.0];
		
	[self.view viewWithTag:hiddenLyricButtonIndex].hidden=FALSE;
	[self.view viewWithTag:showLyricButtonIndex].hidden=TRUE;
	[self.view viewWithTag:LyricContentIndex].hidden=FALSE;

	[UIView commitAnimations];
}
-(void)setDynLyric:(NSString *)lyric
{
	[controller initDynLyric:lyric];
}
-(void)setLyric
{
	if(self.lyricContent){
		//[(UIWebView *)[self.view viewWithTag:LyricContentIndex] loadHTMLString:self.lyricContent baseURL:nil];
		[self.view viewWithTag:LyricContentIndex].hidden=TRUE;		
		[self.view viewWithTag:showLyricButtonIndex].hidden=FALSE;
		//lyricViewController = [[LyricViewController alloc] initWithNibName:@"LyricViewController" bundle:nil];
		[lyricViewController setLyricContent:self.lyricContent];
		
		//lyricViewController.view.tag=LyricContentIndex;
		//lyricViewController.view.hidden=TRUE;
		//[self.view addSubview:lyricViewController.view];
		
	}
}


// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
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

/*-(void)setSourcetype:(NSString *)type
{
	self.sourcetype=type;
}*/
-(void)setDictionary:(NSMutableDictionary *)theDictionary
{
	self.myDictionary=theDictionary;
}

// Implement loadView to create a view hierarchy programmatically.
/*- (void)loadView {

	[[avTouchController alloc] init];
}*/

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {	
    [super viewDidLoad];
	[self initAppDelegate];
	
	self.navigationController.hidesBottomBarWhenPushed = YES;

	self.configMap=[[NSMutableDictionary alloc] init];
	
	self.titleMap = [NSDictionary dictionaryWithObjectsAndKeys:
					 @"基本音",@"basic",@"白天音",@"daylight",@"晚上音",@"night",@"週末音",@"weekend",@"群組一",@"group1",@"群組二",@"group2",@"群組三",@"group3",@"群組四",@"group4",@"群組五",@"group5",nil];
	self.ruleMap = [NSDictionary dictionaryWithObjectsAndKeys:
					@"0",@"基本音",@"6",@"白天音",@"7",@"晚上音",@"8",@"週末音",@"1",@"group1",@"2",@"group2",@"3",@"group3",@"4",@"group4",@"5",@"group5",nil];
	
	if(sourcetype==nil)
		sourcetype=@"03";
	[self createLyricButton];
	[self changeNavButton:@"下載"];
}

- (void)viewWillAppear:(BOOL)animated
{
	NSLog(@"viewWillAppear");
	[self changeNavButton:@"下載"];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

	Song *singleSong=(Song *)[myDictionary objectForKey:InstanceOfObject] ;
	
	[controller setSongObj:singleSong];
	[controller showAlbum];
	[controller getMusicFile];
	//sourcetype=@"06";
	if([sourcetype isEqualToString:@"06"]){
		[controller setPlaylist:appDelegate.playlistDic];		
	}
	[self initWithLyric];
	[self initWithDynLyric];
}
- (void)viewWillDisappear:(BOOL)animated
{
	//NSLog(@"viewWillDisappear");
	[controller playerClose];
	[self hiddenPicker];
	[self clearLyric];
}
- (BOOL)hidesBottomBarWhenPushed{
	return TRUE;
}
#pragma mark -
#pragma mark alertWithoutButton methods

-(void)hiddenConfigWait
{
	[waitAlert dismissWithClickedButtonIndex:0 animated:NO];
}
-(void)showConfigWait:(NSString *)title  message:(NSString *)msg 
{
	waitAlert=[[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
	[waitAlert show];
}

#pragma mark -
#pragma mark RBT methods

-(void)confirmAction{
	NSMutableString *titleMsg=[[NSMutableString alloc] initWithString:@"鈴聲下載"];
	NSString *oldRingId = [self.groupTypes objectAtIndex:[rbtPicker selectedRowInComponent:kGroupComponent]];		
	
	[titleMsg appendString:(NSString *)[self.timeTypes objectAtIndex:[rbtPicker selectedRowInComponent:kTimeComponent]]];
	if([oldRingId length]>6){
		[titleMsg appendString:@"\n取代"];
		[titleMsg appendString:(NSString *)[self.groupTypes objectAtIndex:[rbtPicker selectedRowInComponent:kGroupComponent]]];
	}else{
		[titleMsg appendString:@"\n設定於"];
		[titleMsg appendString:(NSString *)[self.groupTypes objectAtIndex:[rbtPicker selectedRowInComponent:kGroupComponent]]];
	}
	Song *singleSong=(Song *)[myDictionary objectForKey:InstanceOfObject] ;
	NSMutableString *alertMsg=[[NSMutableString alloc] initWithString:@"歌曲名稱："];
	if(singleSong.song==nil)
		[alertMsg appendString:@""];
	else
		[alertMsg appendString:singleSong.song];
	[alertMsg appendString:@"\n作者："];
	if(singleSong.singer==nil)
		[alertMsg appendString:@""];
	else
		[alertMsg appendString:singleSong.singer];
	[alertMsg appendString:@"\n歌曲代號："];
	[alertMsg appendString:singleSong.productid];
	[alertMsg appendString:@"\n答鈴下載費："];
	if(singleSong.price==nil)
		[alertMsg appendString:@""];
	else
		[alertMsg appendString:singleSong.price];
	[alertMsg appendString:@"元"];
	
	UIAlertView *confirmAlert =
	[[UIAlertView alloc] initWithTitle:titleMsg message:alertMsg
							  delegate:self cancelButtonTitle:@"取消" 
					 otherButtonTitles:@"確定", nil];
	[confirmAlert show];
	//[confirmAlert release];
	//[titleMsg release];
	//[titleMsg release];
	//[singleSong release];
}
-(void)initUserData
{
	int index=0;
	//if([appDelegate.rbtMember isEqualToString:@"Y"])
	//{
		NSArray *timeArray=[[NSArray alloc] initWithObjects:@"基本音",@"白天音",@"晚上音",@"週末音",nil];
		self.timeTypes=timeArray;
		[timeArray release];
	
		NSArray *groupArray=[[NSArray alloc] initWithObjects:@"一",@"二",@"三",@"四",@"五",nil];
		self.groupTypes=groupArray;
		[groupArray release];
		
		NSArray *array=[[appDelegate.userProfile allKeys] sortedArrayUsingSelector:@selector(compare:)];
		for(NSString *element in array)
		{
			//NSLog(@"userProfile key:%@",element);
			index=0;
			NSMutableArray *songArray=[[[NSMutableArray alloc] initWithObjects:@"一",@"二",@"三",@"四",@"五",nil] autorelease];
			for(Song *song in [appDelegate.userProfile objectForKey:element])
			{
				[songArray replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"%@  %@",song.productid,song.song]];
				index++;
			}
			[self.configMap setObject:songArray forKey:[titleMap objectForKey:element]];
		}
		self.groupTypes=[self.configMap objectForKey:@"基本音"];
		[self createPicker];
		[self showPicker];
	//}else{
	//}
}

-(void)getUserConfig
{
	//[controller startAnimation:@"rbtConfig"];
	[self showConfigWait:@"請稍候" message:@"下載答鈴設定中"];
	(void) [[URLXmlConnection alloc] initWithURL:[(NSArray *)appDelegate.WSArray objectAtIndex:UserProfile] delegate:self atIndex:@"UserProfile"];
	//NSLog([(NSArray *)appDelegate.WSArray objectAtIndex:UserProfile]);
}
- (void)configAction:(id)sender
{
	[self changeNavButton:@"設定"];
	[self getUserConfig];
}
- (void)addAction:(id)sender
{
	[self hiddenPicker];
	[self confirmAction];
}
-(void)cancelConfig:(id)sender
{
	[self hiddenPicker];
	[self changeNavButton:@"下載"];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1)
	{
		Song *singleSong=(Song *)[myDictionary objectForKey:InstanceOfObject] ;

		NSString *newRingId = singleSong.productid;		
		NSString *oldRingId = [self.groupTypes objectAtIndex:[rbtPicker selectedRowInComponent:kGroupComponent]];		
		NSString *tmpRuleId = [self.ruleMap objectForKey:(NSString *)[self.timeTypes objectAtIndex:[rbtPicker selectedRowInComponent:kTimeComponent]]]; 

		//NSLog(@"oldRingId:%@",oldRingId);
		NSMutableString *tmpUrl = [[NSMutableString alloc] initWithString:@"http://musicphone.emome.net/MAS/irbtConfig.jsp?cmdtype=updaterbt&PRODUCTID="];
		[tmpUrl appendString:newRingId];
		[tmpUrl appendString:@"&RULEID="];
		[tmpUrl appendString:tmpRuleId];
		if([oldRingId length]>6){
			NSRange r={0,6};
			[tmpUrl appendString:@"&OLDPRODUCTID="];
			[tmpUrl appendString:[oldRingId substringWithRange:r]];
		}
		//NSLog(@"tmpUrl:%@",tmpUrl);
		(void) [[URLXmlConnection alloc] initWithURL:[[NSURL alloc] initWithString:tmpUrl] delegate:self  atIndex:@"UpdateRBT"];
		//[tmpUrl release];
		[self changeNavButton:@"下載"];
		[self showConfigWait:@"請稍候" message:@"答鈴設定中"];
	}else{
		[self changeNavButton:@"下載"];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark -
#pragma mark URLXmlConnectionDelegate methods
- (void) xmlConnectionDidFail:(URLXmlConnection *)theConnection atIndex:(NSIndexPath *)index
{
	[self hiddenConfigWait];	
}
- (void) xmlConnectionDidFinish:(URLXmlConnection *)theConnection recData:(NSMutableData *)theData atIndex:(id)index;
{
	NSString *tmpStr = (NSString *)index;
	if([tmpStr isEqualToString:@"UserProfile"]){
		[self hiddenConfigWait];
		self.xmlData=theData;;	
		[appDelegate initDataSource:UserProfile orLink:nil withData:self.xmlData];
		[self initUserData];
	}else if([tmpStr isEqualToString:@"UpdateRBT"]){
		[self hiddenConfigWait];
	}else if([tmpStr isEqualToString:@"DynLyric"]){
		NSString *newLyric=[[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&lt;br /&gt;" withString:@"<br />"];
		NSRange range=[newLyric rangeOfString:@"<lyric>"];
		//NSLog(@"DynLyric1:%@",newLyric);
		if(range.length >0 ){
			NSRange startrange=[newLyric rangeOfString:@"<lyric>"];
			NSRange endrange=[newLyric rangeOfString:@"</lyric>"];
			NSInteger startnumber=startrange.location+startrange.length;
			NSInteger lenghnumber=endrange.location-startnumber;
			NSRange sub={startnumber,lenghnumber};
			newLyric=[newLyric substringWithRange:sub];
			[self setDynLyric:newLyric];
		}
	}else if([tmpStr isEqualToString:@"Lyric"]){
		//NSString *newLyric=[[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&lt;br /&gt;" withString:@"</p><p>"];
		NSString *newLyric=[[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"&lt;br /&gt;" withString:@"<br />"];
		
		newLyric=[newLyric stringByReplacingOccurrencesOfString:@"<p></p>" withString:@"<br />"];
		NSRange range=[newLyric rangeOfString:@"<lyric>"];
		if(range.length >0 ){
			NSRange startrange=[newLyric rangeOfString:@"<lyric>"];
			NSRange endrange=[newLyric rangeOfString:@"</lyric>"];
			NSInteger startnumber=startrange.location+startrange.length;
			NSInteger lenghnumber=endrange.location-startnumber;
			NSRange sub={startnumber,lenghnumber};
			newLyric=[newLyric substringWithRange:sub];
			
			self.lyricContent=[[NSMutableString alloc] initWithString:@"<html><body style=\"background-color: transparent;\"><style type=\"text/css\"> p {margin-left:40px; margin-right:40px; margin-top:40px; margin-bottom:40px; }</style><font face=\"helvetica\" size=+10>"];	
			[self.lyricContent appendString:@"<p>"];
			[self.lyricContent appendString:newLyric];
			[self.lyricContent appendString:@"</p></font></body></html>"];
			[self setLyric];
		}
	}
}

#pragma mark -

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Picker Data Source Methods
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 2;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if(component==kTimeComponent)
		return [self.timeTypes count];
	return [self.groupTypes count];
	
}
#pragma mark Picker Delegate Methods
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	if(component==kTimeComponent)
		return [self.timeTypes objectAtIndex:row];
	return [self.groupTypes objectAtIndex:row];
}
// Respond to user selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if(component==kTimeComponent){
	self.groupTypes=[self.configMap objectForKey:[self.timeTypes objectAtIndex:[rbtPicker selectedRowInComponent:kTimeComponent]]];	
	[rbtPicker selectRow:kTimeComponent inComponent:kGroupComponent animated:YES];
	[rbtPicker reloadComponent:kGroupComponent];
	}
}

- (void) submitConfig:(UIButton *)button{
	//NSLog(@"submitConfig");
}
#pragma mark -
#pragma mark === Touch handling ===

/*
 MetronomeView is a "responder" and will receive touch event messages because it implements the follow messages.  By default, a UIView doesn't handle multi-touch events (see setMultipleTouchEnabled:), which is what we want for this simple app.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
    lastLocation = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
	
    CGFloat xDisplacement = location.x - lastLocation.x;
    CGFloat yDisplacement = location.y - lastLocation.y;
    CGFloat xDisplacementAbs = fabs(xDisplacement);
    CGFloat yDisplacementAbs = fabs(yDisplacement);
	
    // If the displacement is vertical, drag the weight up or down. This will impact the speed of the oscillation.
    if ((xDisplacementAbs < yDisplacementAbs) && (yDisplacementAbs > 1)) {  
        lastLocation = location;
    } else if (xDisplacementAbs >= yDisplacementAbs) {  
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    CGFloat xDisplacement = location.x - lastLocation.x;
    CGFloat yDisplacement = location.y - lastLocation.y;
    CGFloat xDisplacementAbs = fabs(xDisplacement);
    CGFloat yDisplacementAbs = fabs(yDisplacement);
    
	//NSLog(@"xDisplacementAbs%@",[self.view viewWithTag:LyricContentIndex].hidden);
    if ((xDisplacementAbs > yDisplacementAbs) && (xDisplacementAbs > HORIZ_MIN) ) {
		if([self.view viewWithTag:LyricContentIndex].hidden){
			//NSLog(@"showLyric:%f",xDisplacement);
			if(xDisplacement>0)
				[self showLyric:@"left"];
			else
				[self showLyric:@"right"];				
		}else{
			//NSLog(@"hiddenLyric");
			//[self hiddenLyric];
		}
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesCancelled");
}



@end
