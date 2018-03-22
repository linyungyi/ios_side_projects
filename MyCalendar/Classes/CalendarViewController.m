//
//  CalendarViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalendarViewController.h"
#import "MySqlite.h"
#import "RuleArray.h"
#import "MyCalendarAppDelegate.h"
#import "ProfileUtil.h"

@implementation CalendarViewController
@synthesize navController;
@synthesize rootViewController;
@synthesize syncOperation;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	/*
	DoLog(INFO,@"%@",self.navController.navigationBar);
	DoLog(INFO,@"%@",self.navController.navigationItem);
	DoLog(INFO,@"%@",self.navController.navigationItem.leftBarButtonItem);
	
	 MyCalendarAppDelegate *app=[[UIApplication sharedApplication]delegate];
	 NSArray *tmpArray=[app.rootController viewControllers];
	 for(UIViewController *viewController in tmpArray){
	 DoLog(INFO,@"viewController=%@",[viewController description]);
	 if([viewController isKindOfClass:[self class]]==NO)
	 [viewController viewDidLoad];
	 //DoLog(INFO,@"%d",[viewController isKindOfClass:[CalendarViewController class]]);
	 //viewController.tabBarItem.badgeValue=@"1"; 
	 //viewController.tabBarItem.enabled=NO;
	 }
	 app.rootController.selectedIndex=3;
	 
	UITextField *textField;  
	UITextField *textField2;  
	
	UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Username and password"  
													 message:@"\n\n\n" // IMPORTANT  
													delegate:nil  
										   cancelButtonTitle:@"Cancel"  
										   otherButtonTitles:@"Enter", nil];  
	
	textField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 260.0, 25.0)];   
	[textField setBackgroundColor:[UIColor whiteColor]];  
	[textField setPlaceholder:@"username"];  
	[prompt addSubview:textField];  
	
	textField2 = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 85.0, 260.0, 25.0)];   
	[textField2 setBackgroundColor:[UIColor whiteColor]];  
	[textField2 setPlaceholder:@"password"];  
	[textField2 setSecureTextEntry:YES];  
	[prompt addSubview:textField2];  
	
	// set place  
	[prompt setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)];  
	[prompt show];  
	[prompt release];  
	
	// set cursor and show keyboard  
	[textField becomeFirstResponder];
	*/
	
	/*
	NSString *tmpString=[ProfileUtil stringForKey:FIRSTTIME];
	
	if(tmpString==nil)
		[self firstTimeInstall];
	*/
	
	MySqlite *mySqlite=[[MySqlite alloc]init];
	[mySqlite checkDatabase];
	[mySqlite release];
	//BOOL success=[MySqlite checkDatabase];
	//DoLog(DEBUG,[NSString stringWithFormat:@"%d",success]);
	
	//[self.rootViewController viewWillAppear:YES];
	/*
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calen_head.png"]]; 
	[navController.navigationBar insertSubview:backgroundView atIndex:0]; 
	[backgroundView release];
	*/
	
	self.navController.navigationBar.tintColor = [UIColor colorWithRed:128/255.0 green:64/255.0 blue:0/255.0 alpha:1.0f];
	self.navController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUNDIMG]];
	[self.view addSubview: navController.view];
}

- (void)viewWillAppear:(BOOL)animated{ 
	[super viewWillAppear:YES]; 
	
	DoLog(DEBUG,@"CalendarViewController viewWillAppear");
    [self.rootViewController viewWillAppear:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[syncOperation release];
	[rootViewController release];
	[navController release];
    [super dealloc];
}

- (void) firstTimeInstall{
	[ProfileUtil setBool:NO forKey:FIRSTTIME];
	
	RuleArray *ruleArray = [[RuleArray alloc]init];
	UIActionSheet *actionSheet = [[UIActionSheet alloc]
								  initWithTitle:@"從網路取得行事曆資料"
								  delegate:self
								  cancelButtonTitle:@"不"
								  destructiveButtonTitle:[[ruleArray keepRule1] objectAtIndex:0]
								  otherButtonTitles:[[ruleArray keepRule1] objectAtIndex:1],
								  [[ruleArray keepRule1] objectAtIndex:2],
								  [[ruleArray keepRule1] objectAtIndex:3],
								  [[ruleArray keepRule1] objectAtIndex:4],
								  [[ruleArray keepRule1] objectAtIndex:5],
								  nil
								  ];
	[actionSheet showInView:self.view];
	[actionSheet release];
	[ruleArray release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [actionSheet cancelButtonIndex])
	{
		RuleArray *ruleArray = [[RuleArray alloc]init];
		DoLog(DEBUG,@"%@:%@",[[ruleArray keepRule2] objectAtIndex:buttonIndex],[[ruleArray keepRule1] objectAtIndex:buttonIndex]);
		//[[NSUserDefaults standardUserDefaults] setObject:[[ruleArray keepRule2] objectAtIndex:buttonIndex] forKey:KEEPRULE];
		[ProfileUtil setString:[[ruleArray keepRule2] objectAtIndex:buttonIndex] forKey:KEEPRULE];
		
		[ruleArray release];
		
		
		MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
		if(myApp.syncStatus==NO){
			myApp.syncStatus=YES;
			self.syncOperation=[[SyncOperation alloc]init];
			syncOperation.delegate = self;
			[myApp.operationQueue addOperation:syncOperation];
		}
		
	}
}

- (void) doneSyncing:(NSString *)isStop{
	MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
	myApp.syncStatus=NO;
	
	NSArray *tmpArray=[myApp.rootController viewControllers];
	for(UIViewController *viewController in tmpArray){
		//DoLog(DEBUG,@"%@",[viewController description]);
		[viewController viewWillAppear:YES]; 
	}
	
	if([isStop intValue]!=0)
		DoLog(DEBUG,@"fail");
	else
		DoLog(DEBUG,@"success");
	[self.syncOperation release];
	self.syncOperation=nil;
}

-(void) setProgress:(NSString *)p{
}


@end
