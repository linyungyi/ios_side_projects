//
//  SettingChtViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/5.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingChtViewController.h"
#import "ChtDetailViewController.h"
#import "SyncDetailViewController.h"
#import "AutoDetailViewController.h"
#import "LabelSwitchCell.h"
#import "RuleArray.h"
#import "MyCalendarAppDelegate.h"
#import "ProfileUtil.h"

@implementation SettingChtViewController
//@synthesize serviceSwitch;
//@synthesize syncSwitch,idTextField,pwdTextField;
@synthesize myTableView,syncDatas;
//@synthesize syncLabel,syncButton;

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
	//self.title=@"CHT服務設定";
	
	//BOOL tmpBOOL=[[NSUserDefaults standardUserDefaults] boolForKey:CHTSERVICE];
	/*
	BOOL tmpBOOL=[ProfileUtil boolForKey:CHTSERVICE];
	[serviceSwitch setOn:tmpBOOL];
	
	if(tmpBOOL==NO)
		myTableView.hidden=YES;
	*/
	
	NSString *tmpString;
	
	
	RuleArray *ruleArray=[[RuleArray alloc]init];
	NSMutableArray *myArray = [[NSMutableArray alloc]init];
	//tmpString=[[NSUserDefaults standardUserDefaults] stringForKey:KEEPRULE];
	tmpString=[ProfileUtil stringForKey:KEEPRULE];
	if(tmpString==nil)
		tmpString=@"9";
	[myArray addObject:[NSMutableString stringWithString:[[ruleArray keepRule1] objectAtIndex:[ruleArray getKeepRowNo:[tmpString intValue]] ] ]];
	
	//tmpString=[[NSUserDefaults standardUserDefaults] stringForKey:SYNCRULE];
	tmpString=[ProfileUtil stringForKey:SYNCRULE];
	if(tmpString==nil)
		tmpString=@"C";
	[myArray addObject:[NSMutableString stringWithString:[[ruleArray syncRule1] objectAtIndex:[ruleArray getSyncRowNo:tmpString] ] ]];
	
	
	//tmpString=[[NSUserDefaults standardUserDefaults] stringForKey:AUTORULE];
	tmpString=[ProfileUtil stringForKey:AUTORULE];
	if(tmpString==nil)
		tmpString=@"-1";
	[myArray addObject:[NSMutableString stringWithString:[[ruleArray autoRule1] objectAtIndex:[ruleArray getAutoRowNo:[tmpString intValue]] ] ]];
	
	
	[ruleArray release];
	
	
	
	
	//[myArray addObject:@""];
	self.syncDatas=myArray;
	[myArray release];
	
	self.myTableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor clearColor];
	//self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUNDIMG]];
	
	/*
	if(tmpString)
		syncButton.titleLabel.text=tmpString;
	else
		syncButton.titleLabel.text=@"無";
	*/
	//syncButton.titleLabel=[[[UILabel alloc]init] setText:tmpString] autorelease];
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	
	RuleArray *ruleArray=[[RuleArray alloc]init];
	//NSString *tmpString=[[NSUserDefaults standardUserDefaults] stringForKey:KEEPRULE];
	NSString *tmpString=[ProfileUtil stringForKey:KEEPRULE];
	if(tmpString==nil)
		tmpString=@"9";
	[[syncDatas objectAtIndex:0] setString:[[ruleArray keepRule1] objectAtIndex:[ruleArray getKeepRowNo:[tmpString intValue]] ]];
	
	//tmpString=[[NSUserDefaults standardUserDefaults] stringForKey:SYNCRULE];
	tmpString=[ProfileUtil stringForKey:SYNCRULE];
	if(tmpString==nil)
		tmpString=@"C";
	[[syncDatas objectAtIndex:1] setString:[[ruleArray syncRule1] objectAtIndex:[ruleArray getSyncRowNo:tmpString] ]];
	
	//tmpString=[[NSUserDefaults standardUserDefaults] stringForKey:AUTORULE];
	tmpString=[ProfileUtil stringForKey:AUTORULE];
	if(tmpString==nil)
		tmpString=@"-1";
	[[syncDatas objectAtIndex:2] setString:[[ruleArray autoRule1] objectAtIndex:[ruleArray getAutoRowNo:[tmpString intValue]] ]];
	
	[myTableView reloadData];
	[ruleArray release]; 
	
	//syncButton.titleLabel.text=tmpString;
	//syncLabel.text="aaa";
}

- (void)dealloc {
	[syncDatas release];
	[myTableView release];
	//[serviceSwitch release];
	//[idTextField release];
	//[pwdTextField release];
	//[syncSwitch release];
	//[syncButton release];
	//[syncLabel release];
    [super dealloc];
}
/*
-(IBAction)showDetail:(id)sender{
	ChtDetailViewController *nextController = [[[ChtDetailViewController alloc] initWithNibName:@"ChtDetailView" bundle:nil ] autorelease];
	
	//ChtDetailViewController *nextController = [[[ChtDetailViewController alloc] init] autorelease];
	
    [self.navigationController pushViewController:nextController animated:YES];
}

-(IBAction) setChtService:(id)sender{
	DoLog(DEBUG,@"%d",[sender isOn]);
	
	BOOL tmpBOOL=[sender isOn];
	
	//[[NSUserDefaults standardUserDefaults] setBool:tmpBOOL forKey:CHTSERVICE];
	[ProfileUtil setBool:tmpBOOL forKey:CHTSERVICE];
	
	if(tmpBOOL==YES){
		//NSString *tmpString=[[NSUserDefaults standardUserDefaults] stringForKey:SERVICEID];
		NSString *tmpString=[ProfileUtil stringForKey:SERVICEID];
		if(tmpString==nil)
			[self firstTimeEnable];
		myTableView.hidden=NO;
	}else{
		[ProfileUtil setInteger:-1 forKey:AUTORULE];
		//[ProfileUtil setBool:NO forKey:AUTOSYNC];
		[myTableView reloadData];
		myTableView.hidden=YES;
	}
}
 */
/*
- (void) updateSwitch:(UISwitch *) aSwitch forItem: (NSString *) anItem
{
	BOOL tmpBOOL=[aSwitch isOn];
	if([anItem intValue]==1){
		//[[NSUserDefaults standardUserDefaults] setBool:tmpBOOL forKey:AUTOSYNC];
		//[ProfileUtil setBool:tmpBOOL forKey:AUTOSYNC];
		DoLog(DEBUG,@"%d",tmpBOOL);
	}
}
*/
/*
-(IBAction) setAutoSync:(id)sender{
	DoLog(DEBUG,@"%d",[sender isOn]);
	
	BOOL tmpBOOL=[sender isOn];
	
	//[[NSUserDefaults standardUserDefaults] setBool:tmpBOOL forKey:@"autoSync"];
	
}


-(IBAction) setChtId:(id)sender{
	DoLog(DEBUG,@"%d",[sender text]);
	
	NSString *tmpString=[sender text];
	
	[[NSUserDefaults standardUserDefaults] setObject:tmpString forKey:@"chtId"];
}

-(IBAction) setChtPwd:(id)sender{
	DoLog(DEBUG,@"%d",[sender text]);
	
	NSString *tmpString=[sender text];
	
	[[NSUserDefaults standardUserDefaults] setObject:tmpString forKey:@"chtPwd"];
}
*/

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.syncDatas count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    NSString *CellIdentifier;
	
	if(row<=3)
		CellIdentifier= @"Cell";
	else
		CellIdentifier=[NSString stringWithFormat:@"%d_Cell",row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		if(row!=3)
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		else
			cell = [[[NSBundle mainBundle] loadNibNamed:@"LabelSwitchCell" owner:self options:nil] lastObject];		
    }
    
    // Set up the cell...
	NSString *myString=[syncDatas objectAtIndex:row];
	//BOOL tmpBOOL;
	
	switch (row) {
		case 0:
			cell.textLabel.text = @"手機資料保留期限";
			cell.detailTextLabel.text=myString;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case 1:
			cell.textLabel.text = @"衝突處理原則";
			cell.detailTextLabel.text=myString;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case 2:
			cell.textLabel.text = @"自動同步";
			cell.detailTextLabel.text=myString;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		/*
		case 3:
			((LabelSwitchCell *)cell).customLabel.text = @"自動同步";
			((LabelSwitchCell *)cell).viewController=self;
			((LabelSwitchCell *)cell).myTag=1;
			//tmpBOOL=[[NSUserDefaults standardUserDefaults] boolForKey:AUTOSYNC];
			tmpBOOL=[ProfileUtil boolForKey:AUTOSYNC];
			[((LabelSwitchCell *)cell).customSwitch setOn:tmpBOOL];
			break;
		*/
		default:
			break;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	NSUInteger row = [indexPath row];
	
	ChtDetailViewController *chtDetailController;
	SyncDetailViewController *syncDetailController;
	AutoDetailViewController *autoDetailController;
	
	switch (row) {
		case 0:
			chtDetailController = [[[ChtDetailViewController alloc] initWithNibName:@"ChtDetailView" bundle:nil ] autorelease];
			chtDetailController.title=@"手機資料保留期限";
			[self.navigationController pushViewController:chtDetailController animated:YES];
			break;
		case 1:
			syncDetailController = [[[SyncDetailViewController alloc] initWithNibName:@"SyncDetailView" bundle:nil ] autorelease];
			syncDetailController.title=@"衝突處理原則";
			[self.navigationController pushViewController:syncDetailController animated:YES];
			break;
		case 2:
			autoDetailController = [[[AutoDetailViewController alloc] initWithNibName:@"AutoDetailView" bundle:nil ] autorelease];
			autoDetailController.title=@"自動同步";
			[self.navigationController pushViewController:autoDetailController animated:YES];
			break;
		/*
		case 3:
			break;
		*/	
		default:
			break;
	}
	[myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:NO];
}


-(void) firstTimeEnable{
	DoLog(DEBUG,@"uniqueIdentifier=%@",[[UIDevice currentDevice] uniqueIdentifier]);
	DoLog(DEBUG,@"name=%@",[[UIDevice currentDevice] name]);
	DoLog(DEBUG,@"systemName=%@",[[UIDevice currentDevice] systemName]);
	DoLog(DEBUG,@"systemVersion=%@",[[UIDevice currentDevice] systemVersion]);
	DoLog(DEBUG,@"model=%@",[[UIDevice currentDevice] model]);
	DoLog(DEBUG,@"localizedModel=%@",[[UIDevice currentDevice] localizedModel]);
	DoLog(DEBUG,@"lang=%@",[[NSLocale preferredLanguages] objectAtIndex:0]);
	/*
	NSString *num = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
	
	if(num==nil || [num length]<=0)
		num=DEFAULTMSISDN;
	else
		DoLog(DEBUG,@"phone number=%@",num);
	num=DEFAULTMSISDN;
	
	//[[NSUserDefaults standardUserDefaults] setObject:DEFAULTSID forKey:SERVICEID];
	[ProfileUtil setString:DEFAULTSID forKey:SERVICEID];
	//[[NSUserDefaults standardUserDefaults] setObject:num forKey:AUTHID];
	[ProfileUtil setString:num forKey:AUTHID];
	*/
}

@end
