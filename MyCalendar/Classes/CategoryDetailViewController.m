//
//  CategoryDetailViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CategoryDetailViewController.h"
#import "TodoCategory.h"
#import "CategoryTableViewController.h"
#import "LabelCell.h"
#import "MySqlite.h"
#import "DateTimeUtil.h"
#import "MyCalendarAppDelegate.h"
#import "RuleArray.h"

@implementation CategoryDetailViewController
@synthesize todoCategory,colorRgb;
@synthesize myLabel,myTableView,myTextField,mySwitch;
@synthesize tableDatas,delButton;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		TodoCategory *myCategory = [[TodoCategory alloc]init];
		myCategory.folderId=@"";
		myCategory.colorRgb=255255255;
		myCategory.displayFlag=1;
		self.todoCategory=myCategory;
		[myCategory release];
		
		self.title=@"分類新增";
		
	}
    return self;
}


/*
-(id)initWithNibName{
	if(self = [ super init ]){
	}
	return self;
}
*/

-(id)initWithCategoryId:(NSString *)cId nib:(NSString *)nibNameOrNil{
	if(self = [ super initWithNibName:nibNameOrNil bundle:nil ]){
		MySqlite *mySqlite=[[MySqlite alloc]init];
		self.todoCategory=[[[TodoCategory alloc]initWithCategoryId:cId database:mySqlite.database]autorelease];
		[mySqlite release];
		self.title=@"分類編輯";
		
		//self.myColor=[[CategoryColorTable alloc]init];
	}
	return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	/*
	NSMutableArray *myArray = [[NSMutableArray alloc]init];
	for(int i=255;i>0;i-=50){
		for(int j=255;j>0;j-=50){
			for(int k=255;k>0;k-=50){
				[myArray addObject:[NSString stringWithFormat:@"%03d%03d%03d",i,j,k]];
			}
		}
	}
	self.tableDatas = myArray;
	[myArray release];
	*/
	self.tableDatas=[RuleArray getColorArray];
	
	myTextField.text=todoCategory.folderName;
	
	if(todoCategory.displayFlag==1)
		[mySwitch setOn:YES];
	else if(todoCategory.displayFlag==0)
		[mySwitch setOn:NO];
	else
		[mySwitch setOn:YES];
	
	NSInteger r = self.todoCategory.colorRgb/1000000;
	NSInteger g = (self.todoCategory.colorRgb%1000000)/1000;
	NSInteger b = self.todoCategory.colorRgb%1000;
	
	colorRgb=r*1000000+g*1000+b;
	//myLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
	
	NSString *colorImage=[NSString stringWithFormat:@"calenfolder_small_%@.png",[RuleArray getColorDictionary:colorRgb]];
	if(colorImage!=nil)
		[myLabel setImage:[UIImage imageNamed:colorImage]];
	
	MySqlite *mySqlite = [[MySqlite alloc]init];
	if([todoCategory.folderId length]<=0 || [mySqlite getTodoCategoryCount]<=1 || todoCategory.folderType==1)
		[delButton setHidden:YES];
	else
		[delButton setHidden:NO];
	/*
	if(todoCategory.folderId>0)
		delButton.titleLabel.text=@"刪除";
	else
		delButton.titleLabel.text=@"取消";
	*/
	[mySqlite release];
	
	
	self.view.backgroundColor=[UIColor clearColor];
	//self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"calendar_weekly_bg.png"]];
	
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"儲存" style:UIBarButtonItemStyleBordered target:self action:@selector(doJob:)] autorelease];
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
	[tableDatas release];
	[delButton release];
	[todoCategory release];
	[myLabel release];
	[myTableView release];
	[myTextField release];
	[mySwitch release];
    [super dealloc];
}


-(IBAction) doJob:(id)sender{
	
	//MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
	//DoLog(DEBUG,@"%d",myApp.syncStatus);
	//if(myApp.syncStatus==YES){
	//	UIAlertView *baseAlert = [[UIAlertView alloc]
	//							  initWithTitle:@"資料同步中無法新增刪除與修改"
	//							  message:@"請稍候再執行,謝謝"
	//							  delegate:self cancelButtonTitle:@"確定"
	//							  otherButtonTitles:nil];
	//	[baseAlert show];
	//	[baseAlert release];
	//}else{
	
	
	UIAlertView *baseAlert;
	MySqlite *mySqlite=[[MySqlite alloc]init];
	
	
	if([todoCategory.folderId length]>0)
		self.todoCategory=[[[TodoCategory alloc]initWithCategoryId:todoCategory.folderId database:mySqlite.database]autorelease];
	
	if([self.myTextField.text length]>MAXFOLDERNAME || ([todoCategory.folderId length]<=0 && [mySqlite getTodoCategoryCount]>=MAXFOLDERSIZE)){
		NSString *msg=nil;
		
		if([self.myTextField.text length]>MAXFOLDERNAME)
			msg=[NSString stringWithFormat:@"名稱最多%d字,超過%d字",MAXFOLDERNAME,([self.myTextField.text length]-MAXFOLDERNAME)];
		else
			msg=[NSString stringWithFormat:@"分類最多%d個,目前%d個",MAXFOLDERSIZE,[mySqlite getTodoCategoryCount]];
		
		baseAlert = [[UIAlertView alloc]
					 initWithTitle:@"失敗"
					 message:msg
					 delegate:self cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
	}else if([[NSUserDefaults standardUserDefaults] boolForKey:RESTORESYNCFLAG]==YES){
		baseAlert = [[UIAlertView alloc]
					 initWithTitle:@"資料同步還原中無法新增刪除與修改"
					 message:@"請稍候再執行,謝謝"
					 delegate:self cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
	}else if(todoCategory.syncStatus==1){
		baseAlert = [[UIAlertView alloc]
									  initWithTitle:@"資料同步中無法刪除與修改"
									  message:@"請稍候再執行,謝謝"
									  delegate:self cancelButtonTitle:@"確定"
									  otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
	}else{
		BOOL flag;
		NSString *title=nil;
		
		if([todoCategory.folderId length]>0){//修改
			title=@"修改失敗";//失敗時才會用的訊息
		
			todoCategory.folderName=self.myTextField.text;
			todoCategory.colorRgb=self.colorRgb;
			todoCategory.displayFlag=[self.mySwitch isOn];
			if(todoCategory.syncFlag!=0){
				todoCategory.syncFlag=1;
				todoCategory.stateFlag=1;
			}
			todoCategory.modifiedDatetime=[DateTimeUtil getTodayString];
		
			flag=[mySqlite updTodoCategory:todoCategory];
			//[mySqlite release];
		}else{//新增
			title=@"新增失敗";////失敗時才會用的訊息
		
			//todoCategory.folderId=[mySqlite getMaxSequence:@"pim_cal_folder" trans:NO];
			todoCategory.folderName=self.myTextField.text;
			todoCategory.colorRgb=self.colorRgb;
			todoCategory.displayFlag=[self.mySwitch isOn];
			todoCategory.stateFlag=0;
			todoCategory.syncFlag=0;
			todoCategory.createdDatetime=[DateTimeUtil getTodayString];
			todoCategory.modifiedDatetime=[DateTimeUtil getTodayString];
			todoCategory.serverId=@"0";
			todoCategory.folderType=0;
		
			flag=[mySqlite insTodoCategory:todoCategory];
			//[mySqlite release];
		}
	
		if(flag==YES){
			[[self parentViewController] viewWillAppear:YES];
			[self.navigationController popViewControllerAnimated:YES];
		}else{
			UIAlertView *baseAlert = [[UIAlertView alloc]
								  initWithTitle:title
								  message:@"請再試一次,謝謝"
								  delegate:self cancelButtonTitle:@"確定"
								  otherButtonTitles:nil];
			[baseAlert show];		
			[baseAlert release];
		}
	}
	[mySqlite release];
}

-(IBAction) doDel:(id)sender{
	UIAlertView *baseAlert;
	
	//MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
	//if(myApp.syncStatus==YES){
	//	 baseAlert= [[UIAlertView alloc]
	//							  initWithTitle:@"資料同步中無法新增刪除與修改"
	//							  message:@"請稍候再執行,謝謝"
	//							  delegate:self cancelButtonTitle:@"確定"
	//							  otherButtonTitles:nil];
	//	[baseAlert show];
	//	[baseAlert release];
	
	MySqlite *mySqlite=[[MySqlite alloc]init];
	if([todoCategory.folderId length]>0)
		self.todoCategory=[[[TodoCategory alloc]initWithCategoryId:todoCategory.folderId database:mySqlite.database]autorelease];
	[mySqlite release];
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:RESTORESYNCFLAG]==YES){
		baseAlert = [[UIAlertView alloc]
					 initWithTitle:@"資料同步還原中無法新增刪除與修改"
					 message:@"請稍候再執行,謝謝"
					 delegate:self cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
	}else if(todoCategory.syncStatus==1){
		baseAlert = [[UIAlertView alloc]
								  initWithTitle:@"資料同步中無法刪除與修改"
								  message:@"請稍候再執行,謝謝"
								  delegate:self cancelButtonTitle:@"確定"
								  otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
	}else{
		if([self.todoCategory.folderId length]!=0){
			DoLog(DEBUG,@"delete");
		
			baseAlert = [[UIAlertView alloc]
					 initWithTitle:@"是否刪除"
					 message:@"刪除會連帶刪除所有所屬事件"
					 delegate:self cancelButtonTitle:@"否"
					 otherButtonTitles:@"是",nil];
			[baseAlert show];		
			[baseAlert release];
		}else{
			DoLog(DEBUG,@"cancel");
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex==1){
		MySqlite *mySqlite=[[MySqlite alloc]init];
		//****need delete the event which is belong the category
		if(self.todoCategory.syncFlag==0)
			[mySqlite delTodoCategory:self.todoCategory];
		else{
			self.todoCategory.stateFlag=2;
			self.todoCategory.syncFlag=1;
			[mySqlite updTodoCategory:self.todoCategory];
		}
		[mySqlite release];
		[[self parentViewController] viewWillAppear:YES];
		[self.navigationController popViewControllerAnimated:YES];
	}
}

/*
-(void) hiddenKeyboard{
	DoLog(DEBUG,@"hiddenKeyboard");
}
*/

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableDatas count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
	
    //static NSString *CellIdentifier = @"Cell";
	NSString *CellIdentifier = [NSString stringWithFormat:@"row_%d_Cell",row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	//LabelCell *cell=(LabelCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell==nil){
		//cell=[[[NSBundle mainBundle] loadNibNamed:@"LabelCell" owner:self options:nil] lastObject];
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
    // Set up the cell...
	NSString *myString=[tableDatas objectAtIndex:row];
	
	/*
	NSRange myRange;
	myRange.location=0;
	myRange.length=3;
	
	NSInteger r = [[myString substringWithRange:myRange]intValue];
	myRange.location=3;
	NSInteger g = [[myString substringWithRange:myRange]intValue];
	myRange.location=6;
	NSInteger b = [[myString substringWithRange:myRange]intValue];
	
	cell.customLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
	*/	
	//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	//DoLog(INFO,@"%@ %d",[RuleArray getColorDictionary:[myString intValue]],[myString intValue]);
	
	NSString *colorImage=[NSString stringWithFormat:@"calenfolder_320_%@.png",[RuleArray getColorDictionary:[myString intValue]]];
	cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:colorImage]];
	
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
    NSString *myString = [tableDatas objectAtIndex:row];
	
	//DoLog(DEBUG,@"%@",myString);
	
	NSRange myRange;
	myRange.location=0;
	myRange.length=3;
	
	NSInteger r = [[myString substringWithRange:myRange]intValue];
	myRange.location=3;
	NSInteger g = [[myString substringWithRange:myRange]intValue];
	myRange.location=6;
	NSInteger b = [[myString substringWithRange:myRange]intValue];
	
	NSString *colorImage=[NSString stringWithFormat:@"calenfolder_small_%@.png",[RuleArray getColorDictionary:r*1000000+g*1000+b]];
	
	if(colorImage!=nil){
		colorRgb=r*1000000+g*1000+b;
		//self.myLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
		[self.myLabel setImage:[UIImage imageNamed:colorImage]];
		//self.myLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:colorImage]];
	}
	
	[self.myTableView deselectRowAtIndexPath:[self.myTableView indexPathForSelectedRow] animated:NO];
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{ 
	return 30.0; 
} 
*/
@end
