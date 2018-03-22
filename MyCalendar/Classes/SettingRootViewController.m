//
//  SettingRootViewController.m
//  MyCalendar
//
//  Created by yves ho on 2010/2/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingRootViewController.h"
#import "SettingChtViewController.h"
#import "ProfileUtil.h"
#import "LabelSwitchCell.h"
#import "CategoryViewController.h"
#import "ServiceDescriptionViewController.h"
#import "UserInfoViewController.h"
#import "InterfaceUtil.h"

#import "SettingTestViewController.h"

@implementation SettingRootViewController

/*
@synthesize mySwitch,myButton;
@synthesize myTestButton;
*/
@synthesize myTableView,tableDatas;
//@synthesize navigationBar;

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
	//self.myTestButton.hidden=YES;
	//BOOL tmpBOOL=[[NSUserDefaults standardUserDefaults] boolForKey:@"eventNotify"];
	BOOL tmpBOOL=[ProfileUtil boolForKey:EVENTNOTIFY];
	[mySwitch setOn:tmpBOOL];
	//[self showCht:nil];
	*/
	
	NSMutableArray *myArray = [[NSMutableArray alloc]init];
	[myArray addObject:@"事件通知"];
	[myArray addObject:@"分類設定"];
	[myArray addObject:@"帳號設定"];
	[myArray addObject:@"服務設定"];
	[myArray addObject:@"服務說明"];	
	[myArray addObject:@"測試用"];
	
	self.tableDatas=myArray;
	[myArray release];
	
	self.myTableView.backgroundColor = [UIColor clearColor];
	
	NSString *redirect=[[NSUserDefaults standardUserDefaults] objectForKey:REDIRECTFLAG];
	if(redirect!=nil && [redirect isEqualToString:@"SERVICEDESCRIPTION"]==YES){
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:REDIRECTFLAG];
		UserInfoViewController *userController = [[[UserInfoViewController alloc] initWithNibName:@"UserInfoView" bundle:nil ] autorelease];
		userController.title=@"帳號設定";
		userController.defaultView=userController.view;
		userController.view=userController.webView;
		[self.navigationController pushViewController:userController animated:YES];
	}
	
	/*
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calen_head.png"]]; 
	[self.navigationBar insertSubview:backgroundView atIndex:0]; 
	[backgroundView release];
	*/
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	
	[self.myTableView reloadData];
	
	NSString *redirect=[[NSUserDefaults standardUserDefaults] objectForKey:REDIRECTFLAG];
	if(redirect!=nil && [redirect isEqualToString:@"SERVICEDESCRIPTION"]==YES){
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:REDIRECTFLAG];
		UserInfoViewController *userController = [[[UserInfoViewController alloc] initWithNibName:@"UserInfoView" bundle:nil ] autorelease];
		userController.title=@"帳號設定";
		userController.defaultView=userController.view;
		userController.view=userController.webView;
		[self.navigationController pushViewController:userController animated:YES];
	}
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
	/*
	[myTestButton release];
	[mySwitch release];
	[myButton release];
	*/
	//[navigationBar release];	
	[myTableView release];
	[tableDatas release];
    [super dealloc];
}

/*
-(IBAction) showTest:(id)sender{
	DoLog(DEBUG,@"showCht");
	SettingTestViewController *nextController = [[SettingTestViewController alloc] initWithNibName:
												@"SettingTestView" bundle:nil];
	
	[nextController viewWillAppear:YES];
    [self.navigationController pushViewController:nextController animated:YES];
	
}

-(IBAction) showCht:(id)sender{
	DoLog(DEBUG,@"showCht");
	SettingChtViewController *nextController = [[SettingChtViewController alloc] initWithNibName:
																						  @"SettingChtView" bundle:nil];
	
    [self.navigationController pushViewController:nextController animated:YES];
	
}

-(IBAction) setEventNotify:(id)sender{
	DoLog(DEBUG,@"%d",[sender isOn]);
	
	BOOL tmpBOOL=[sender isOn];
	
	//[[NSUserDefaults standardUserDefaults] setBool:tmpBOOL forKey:@"eventNotify"];
	[ProfileUtil setBool:tmpBOOL forKey:EVENTNOTIFY];
}
*/

- (void) updateSwitch:(UISwitch *) aSwitch forItem: (NSString *) anItem
{
	BOOL tmpBOOL=[aSwitch isOn];
	if([anItem intValue]==1){
		[ProfileUtil setBool:tmpBOOL forKey:EVENTNOTIFY];
		/*
		if(tmpBOOL==YES)
			[NSThread detachNewThreadSelector:@selector(sendGlobalEnable:) toTarget:self withObject:@"1"];
		else
			[NSThread detachNewThreadSelector:@selector(sendGlobalEnable:) toTarget:self withObject:@"0"];
		*/
	}
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.tableDatas count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    NSString *CellIdentifier;
	
	if(row!=0)
		CellIdentifier= @"Cell";
	else
		CellIdentifier=[NSString stringWithFormat:@"%d_Cell",row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if(row!=0)
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		else
			cell = [[[NSBundle mainBundle] loadNibNamed:@"LabelSwitchCell" owner:self options:nil] lastObject];		
    }
    
    // Set up the cell...
	
	if(row==0){
		((LabelSwitchCell *)cell).customLabel.text = [tableDatas objectAtIndex:row];
		((LabelSwitchCell *)cell).viewController=self;
		((LabelSwitchCell *)cell).myTag=1;
		BOOL tmpBOOL=[ProfileUtil boolForKey:EVENTNOTIFY];
		[((LabelSwitchCell *)cell).customSwitch setOn:tmpBOOL];
	}else{
		cell.textLabel.text = [tableDatas objectAtIndex:row];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	NSUInteger row = [indexPath row];
	
	CategoryTableViewController *categoryController;
	UserInfoViewController *userController;
	SettingChtViewController *chtController;
	ServiceDescriptionViewController *serviceController;
	SettingTestViewController *testController;
	NSString *serviceId=nil;
	
	switch (row) {
		case 0:
			break;
		case 1:
			serviceId=[ProfileUtil stringForKey:SERVICEID];
			
			if(serviceId==nil || [serviceId length]<=0 || [serviceId longLongValue]==0){
				UIAlertView *baseAlert = [[UIAlertView alloc]
										  initWithTitle:@"完整版才能設定分類"
										  message:@"請申裝服務,謝謝"
										  delegate:self cancelButtonTitle:@"確定"
										  otherButtonTitles:nil];
				[baseAlert show];
				[baseAlert release];
			}else{ 
				categoryController = [[[CategoryTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];	
				categoryController.title=@"分類設定";
				[self.navigationController pushViewController:categoryController animated:YES];
			}
			break;
		case 2:
			userController = [[[UserInfoViewController alloc] initWithNibName:@"UserInfoView" bundle:nil ] autorelease];
			userController.title=@"帳號設定";
			[self.navigationController pushViewController:userController animated:YES];
			break;
		case 3:
			chtController = [[[SettingChtViewController alloc] initWithNibName:@"SettingChtView" bundle:nil ] autorelease];
			chtController.title=@"服務設定";
			[self.navigationController pushViewController:chtController animated:YES];
			break;
		case 4:
			serviceController = [[[ServiceDescriptionViewController alloc] init] autorelease];	
			serviceController.title=@"服務說明";
			[self.navigationController pushViewController:serviceController animated:YES];
			break;
		case 5:
			testController = [[[SettingTestViewController alloc] initWithNibName:@"SettingTestView" bundle:nil ] autorelease];
			[self.navigationController pushViewController:testController animated:YES];
			break;
		default:
			break;
	}
	[myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:NO];
}

-(void) sendGlobalEnable:(NSString *)enableFlag{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSInteger resultCode=0;
	
	if([enableFlag intValue]==0)
		resultCode=[InterfaceUtil updGlobalNotification:NO];
	else
		resultCode=[InterfaceUtil updGlobalNotification:YES];
	
	if(resultCode==0){
		if([enableFlag intValue]==0)
			[ProfileUtil setBool:NO forKey:EVENTNOTIFY];
		else
			[ProfileUtil setBool:YES forKey:EVENTNOTIFY];
	}else{
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"通知更新失敗"
							  message:@"請稍候再試,謝謝"
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[self.myTableView reloadData];
	[pool release];
}

@end
