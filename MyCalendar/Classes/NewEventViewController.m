//
//  NewEventViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewEventViewController.h"
#import "TodoEvent.h"
#import "TodoCategory.h"
#import "EventRecurrence.h"
#import "MySqlite.h"
#import "CategoryTableViewController.h"
#import "RedoDetailViewController.h"
#import "RedoDateViewController.h"
#import "EventDateViewController.h"
#import "EventTimeViewController.h"
#import "NotifyTimeViewController.h"
#import "TextFieldCell.h"
#import "MemoTextViewController.h"
#import "RuleArray.h"
#import "DateTimeUtil.h"
#import "MyCalendarAppDelegate.h"
#import "CalendarRootViewController.h"
#import "ProfileUtil.h"
#import "LabelCell.h"
#import "EventIconViewController.h"

@implementation NewEventViewController

@synthesize todoEvent,todoCategory,eventRecurrence,tableArray;
//@synthesize eventSubject,eventDesc,eventMemo,redoArray;
@synthesize myTableView,fromFlag;

-(void) initNewTodoEvent:(NSString *)now{
	// Custom initialization
	TodoEvent *myEvent = [[TodoEvent alloc]init];
	self.todoEvent=myEvent;
	[myEvent release];
	
	MySqlite *mySqlite=[[MySqlite alloc]init];
	
	if([mySqlite getTodoCategoryCount]<=0)
		[mySqlite insDefaultCategory];
	
	TodoCategory *myCategory = [mySqlite getDefaultCategory];
	if(myCategory==nil){
		myCategory=[[TodoCategory alloc]init];
	}
	self.todoCategory=myCategory;
	[myCategory release];
	[mySqlite release];
	
	EventRecurrence *myRecurrence = [[EventRecurrence alloc]init];
	self.eventRecurrence=myRecurrence;
	[myRecurrence release];
	
	self.title=@"新增事件";
	todoEvent.subject=@"";
	todoEvent.location=@"";
	todoEvent.memo=@"";
	todoEvent.reminder=-1;
	todoEvent.calType=0;
	todoEvent.calRecurrenceId=@"-1";
	todoEvent.eventIcon=@"";
	
	eventRecurrence.calendarId=@"";
	eventRecurrence.type=-1;
	
	//if(now==nil){
		NSDate *rightnow=[NSDate date];
		rightnow=[DateTimeUtil getDiffDate:rightnow mins:60];
	
		NSDateFormatter *form=[[NSDateFormatter alloc]init];
		//[form setDateFormat:@"yyyyMMddHHmmss"];
		[form setDateFormat:@"yyyyMMddHH0000"];
		todoEvent.startTime=[form stringFromDate:rightnow];
	
		rightnow=[DateTimeUtil getDiffDate:rightnow mins:60];	
		todoEvent.endTime=[form stringFromDate:rightnow];
		[form release];
		
		NSRange range;
		range.location=8;
		range.length=2;
		if([[todoEvent.endTime substringWithRange:range]intValue]==0)
			todoEvent.endTime=[NSString stringWithFormat:@"%@235900",[todoEvent.endTime substringToIndex:8]];
	
	//}else{
	//	todoEvent.startTime=now;
	//	todoEvent.endTime=now;
	//}
	
	
	
}

-(void) editTodoEvent:(NSString *)cId{
	MySqlite *mySqlite=[[MySqlite alloc]init];
	
	self.todoEvent=[[[TodoEvent alloc] initWithEventId:cId database:mySqlite.database]autorelease];
	
	TodoCategory *myCategory = [[TodoCategory alloc]initWithCategoryId:todoEvent.folderId database:mySqlite.database ];
	self.todoCategory=myCategory;
	[myCategory release];
	
	EventRecurrence *myRecurrence;
	
	if(todoEvent.calType==1)
		myRecurrence = [[EventRecurrence alloc]initWithId:todoEvent.calendarId database:mySqlite.database ];
	else
		myRecurrence = [[EventRecurrence alloc]initWithId:todoEvent.calRecurrenceId database:mySqlite.database ];
	self.eventRecurrence=myRecurrence;
	[myRecurrence release];
	
	[mySqlite release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil dateString:(NSString *)now {
    if (self = [super initWithNibName:nibNameOrNil bundle:nil]) {
        [self initNewTodoEvent:now];
	}
    return self;
}

-(id)initWithEventId:(NSString *)cId nib:(NSString *)nibNameOrNil{
	if(self = [ super initWithNibName:nibNameOrNil bundle:nil ]){
		self.title=@"編輯事件";
		
		[self editTodoEvent:cId];
	}
	return self;
}

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*新增事件*/
/*0 主題*/
/*1 地點*/
/*2 0起始 YYYYMMDDhhmmss#YYYY/MM/DD hh:mm:ss*/
/*2 1終止 YYYYMMDDhhmmss#YYYY/MM/DD hh:mm:ss/
 /*3 0重覆 value#description*/
/*3 1重覆結束時間 YYYYMMDDhhmmss#YYYY/MM/DD hh:mm:ss*/
/*4 通知 分#x天x時x分*/
/*5 分類 folderId#folderName#colorRgb*/
/*6 事件圖示*/
/*7 備註*/
- (void)viewDidLoad {
    [super viewDidLoad];
	
	RuleArray *ruleArray=[[RuleArray alloc]init];
	//self.redoArray=[ruleArray redoRule1];
	
	self.tableArray = [[NSMutableArray alloc]init];
	NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%@",todoEvent.subject]];
	[tableArray addObject:tmpArray];
	[tmpArray release];
	
	tmpArray = [[NSMutableArray alloc]init];
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%@",todoEvent.location]];
	[tableArray addObject:tmpArray];
	[tmpArray release];
	
	tmpArray = [[NSMutableArray alloc]init];
	NSDateComponents *cmp=[DateTimeUtil getDateComponentsFromString:todoEvent.startTime];
	//[tmpArray addObject:[NSMutableString stringWithFormat:@"%d%02d%02d%02d%02d00#%d/%02d/%02d %02d:%02d",[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]-([cmp minute]%5),[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]-([cmp minute]%5)]];
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%@#%d/%02d/%02d %02d:%02d",todoEvent.startTime,[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]]];
	cmp=[DateTimeUtil getDateComponentsFromString:todoEvent.endTime];
	//[tmpArray addObject:[NSMutableString stringWithFormat:@"%d%02d%02d%02d%02d00#%d/%02d/%02d %02d:%02d",[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]-([cmp minute]%5),[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]-([cmp minute]%5)]];
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%@#           %02d:%02d",todoEvent.endTime,[cmp hour],[cmp minute]]];
	[tableArray addObject:tmpArray];
	[tmpArray release];
	
	tmpArray = [[NSMutableArray alloc]init];
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%d#%@",eventRecurrence.type,[[ruleArray redoRule1] objectAtIndex:[ruleArray getRedoRowNo:eventRecurrence.type]]]];
	if(eventRecurrence.type!=-1){
		if(eventRecurrence.until==nil){
			DoLog(ERROR,@"error recurrence until is null");
			eventRecurrence.until=todoEvent.endTime;
		}
		cmp=[DateTimeUtil getDateComponentsFromString:eventRecurrence.until];
		[tmpArray addObject:[NSMutableString stringWithFormat:@"%@#%d/%02d/%02d %02d:%02d",eventRecurrence.until,[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]]];
	}
	[tableArray addObject:tmpArray];
	[tmpArray release];
	[ruleArray release];
	
	tmpArray = [[NSMutableArray alloc]init];
	if(todoEvent.reminder>=0){
		NSMutableString *tmpString = [[NSMutableString alloc]init];
		int days=(todoEvent.reminder/60)/24;
		int hours=(todoEvent.reminder-days*24*60)/60;
		int mins=(todoEvent.reminder-days*24*60-hours*60);
		
		if(days>0)
			[tmpString appendFormat:@"%d天",days];
		if(hours>0)
			[tmpString appendFormat:@"%d小時",hours];
		[tmpString appendFormat:@"%d分鐘前",mins];
		
		[tmpArray addObject:[NSMutableString stringWithFormat:@"%d#%@",todoEvent.reminder,tmpString]];
		[tmpString release];
	}else
		[tmpArray addObject:[NSMutableString stringWithFormat:@"-1"]];
	
	[tableArray addObject:tmpArray];
	[tmpArray release];
	
	tmpArray = [[NSMutableArray alloc]init];
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%@#%@#%d",todoCategory.folderId,todoCategory.folderName,todoCategory.colorRgb]];
	 
	[tableArray addObject:tmpArray];
	[tmpArray release];
	
	tmpArray = [[NSMutableArray alloc]init];
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%@",todoEvent.eventIcon]];
	[tableArray addObject:tmpArray];
	[tmpArray release];
	
	
	
	tmpArray = [[NSMutableArray alloc]init];
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%@",todoEvent.memo]];
	[tableArray addObject:tmpArray];
	[tmpArray release];
	
	
	
	self.myTableView.backgroundColor = [UIColor clearColor];
	//self.view.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUNDIMG]];
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"儲存" style:UIBarButtonItemStyleBordered target:self action:@selector(doJob:)] autorelease];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) resetTableDatas{
	[[[tableArray objectAtIndex:0] objectAtIndex:0] setString:todoEvent.subject];
	[[[tableArray objectAtIndex:1] objectAtIndex:0] setString:todoEvent.location];
	
	NSDateComponents *cmp=[DateTimeUtil getDateComponentsFromString:todoEvent.startTime];
	[[[tableArray objectAtIndex:2] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%@#%d/%02d/%02d %02d:%02d",todoEvent.startTime,[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]]];
	cmp=[DateTimeUtil getDateComponentsFromString:todoEvent.endTime];
	[[[tableArray objectAtIndex:2] objectAtIndex:1] setString:[NSMutableString stringWithFormat:@"%@#           %02d:%02d",todoEvent.endTime,[cmp hour],[cmp minute]]];
	
	
	if([[tableArray objectAtIndex:3] count]==2)
		[[tableArray objectAtIndex:3] removeObject:[[tableArray objectAtIndex:3]objectAtIndex:1] ];
	
	RuleArray *ruleArray=[[RuleArray alloc]init];
	[[[tableArray objectAtIndex:3] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%d#%@",eventRecurrence.type,[[ruleArray redoRule1] objectAtIndex:[ruleArray getRedoRowNo:eventRecurrence.type]]]];
	if(eventRecurrence.type!=-1){
		if(eventRecurrence.until==nil){
			DoLog(ERROR,@"error recurrence until is null");
			eventRecurrence.until=todoEvent.endTime;
		}
		cmp=[DateTimeUtil getDateComponentsFromString:eventRecurrence.until];
		[[tableArray objectAtIndex:3] addObject:[NSMutableString stringWithFormat:@"%@#%d/%02d/%02d %02d:%02d",eventRecurrence.until,[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]]];
	}
	[ruleArray release];	
	
	if(todoEvent.reminder>=0){
		NSMutableString *tmpString = [[NSMutableString alloc]init];
		int days=(todoEvent.reminder/60)/24;
		int hours=(todoEvent.reminder-days*24*60)/60;
		int mins=(todoEvent.reminder-days*24*60-hours*60);
		
		if(days>0)
			[tmpString appendFormat:@"%d天",days];
		if(hours>0)
			[tmpString appendFormat:@"%d小時",hours];
		[tmpString appendFormat:@"%d分鐘前",mins];
		
		[[[tableArray objectAtIndex:4] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%d#%@",todoEvent.reminder,tmpString]];
		[tmpString release];
	}else
		[[[tableArray objectAtIndex:4] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"-1"]];
	
	[[[tableArray objectAtIndex:5] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%@#%@#%d",todoCategory.folderId,todoCategory.folderName,todoCategory.colorRgb]];
	
	[[[tableArray objectAtIndex:6] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%@",todoEvent.eventIcon]];
	
	[[[tableArray objectAtIndex:7] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%@",todoEvent.memo]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	 //DoLog(INFO,@"NewEventViewController=%@",[[tableArray objectAtIndex:2] objectAtIndex:0]);
	
	[self.myTableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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


-(IBAction) doJob:(id)sender{
	MySqlite *mySqlite=[[MySqlite alloc]init];
	NSString *title;
	BOOL flag;
	UIAlertView *baseAlert;
	
	NSString *subject=[[self.tableArray objectAtIndex:0] objectAtIndex:0];
	NSString *location=[[self.tableArray objectAtIndex:1] objectAtIndex:0];
	NSString *memo=[[self.tableArray objectAtIndex:7] objectAtIndex:0];
	
	NSArray *tmpArray=[[[self.tableArray objectAtIndex:3] objectAtIndex:0] componentsSeparatedByString:@"#"];
	NSInteger redoRule=[[tmpArray objectAtIndex:0] intValue];
	NSInteger redoRule1;
	NSInteger redoCount;
	NSString *redoTime;
	NSString *folderId;
	
	tmpArray=[[[self.tableArray objectAtIndex:5] objectAtIndex:0] componentsSeparatedByString:@"#"];
	folderId=[tmpArray objectAtIndex:0];
	
	if([folderId length]>0)
		self.todoCategory=[[[TodoCategory alloc]initWithCategoryId:folderId database:mySqlite.database]autorelease];
	
	if([self.todoCategory.folderId length]<=0){
		flag=NO;
		baseAlert = [[UIAlertView alloc]
					 initWithTitle:@"分類錯誤"
					 message:@"請重新選擇分類,謝謝"
					 delegate:self cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
	}else if([subject length]>MAXSUBJECT || [location length]>MAXLOCATION || [memo length]>MAXMEMO){
		flag=NO;
		NSMutableString *msg=[[NSMutableString alloc]init];
		if([subject length]>MAXSUBJECT){
			if([msg length]>0)
				[msg appendString:@"\n"];
			[msg appendFormat:@"主題最多%d字,超過%d字",MAXSUBJECT,([subject length]-MAXSUBJECT)];
		}
		if([location length]>MAXLOCATION){
			if([msg length]>0)
				[msg appendString:@"\n"];
			[msg appendFormat:@"地點最多%d字,超過%d字",MAXLOCATION,([location length]-MAXLOCATION)];
		}
		if([memo length]>MAXMEMO){
			if([msg length]>0)
				[msg appendString:@"\n"];
			[msg appendFormat:@"備註最多%d字,超過%d字",MAXMEMO,([memo length]-MAXMEMO)];
		}
		
		baseAlert = [[UIAlertView alloc]
					 initWithTitle:@"字數過長"
					 message:msg
					 delegate:self cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
		[msg release];
		
	}else if([self.todoEvent.calendarId length]>0 && self.todoEvent.calType==1 && redoRule==-1){
		flag=NO;
		baseAlert = [[UIAlertView alloc]
								  initWithTitle:@"重覆事件不能修改成一般事件"
								  message:@"請選擇重覆規則,謝謝"
								  delegate:self cancelButtonTitle:@"確定"
								  otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
	}else if(redoRule!=-1){
	
		RuleArray *ruleArray=[[RuleArray alloc]init];
		redoRule1=[[[ruleArray redoRule3] objectAtIndex:[ruleArray getRedoRowNo:redoRule]]intValue];
		[ruleArray release];
	
		tmpArray=[[[self.tableArray objectAtIndex:2] objectAtIndex:0] componentsSeparatedByString:@"#"];
		NSString *startTime=[tmpArray objectAtIndex:0];
		tmpArray=[[[self.tableArray objectAtIndex:2] objectAtIndex:1] componentsSeparatedByString:@"#"];
		NSString *endTime=[tmpArray objectAtIndex:0];
	
		if([[self.tableArray objectAtIndex:3] count]==2){
			tmpArray=[[[self.tableArray objectAtIndex:3] objectAtIndex:1] componentsSeparatedByString:@"#"];
			redoTime=[tmpArray objectAtIndex:0];
		}else
			redoTime=endTime;
	
		if(redoRule!=-1){
			//redoCount=([DateTimeUtil getCountFromDate:[DateTimeUtil getDateFromString:startTime] endDate:[DateTimeUtil getDateFromString:redoTime] days:redoRule1 ]+1);
			redoCount=[DateTimeUtil getCountFromDate:[DateTimeUtil getDateFromString:startTime] endDate:[DateTimeUtil getDateFromString:redoTime] days:REDOMAXDAYS ];
			DoLog(DEBUG,@"redoCount=%d",redoCount);
		}else
			redoCount=0;
		
		if(redoCount>=1){
			flag=NO;
			//title=[NSString stringWithFormat:@"重覆次數最多%d次",REDOMAXCOUNT];
			title=@"重覆區間最多一年";
			baseAlert = [[UIAlertView alloc]
						 initWithTitle:title
						 message:@"請選擇重覆結束時間,謝謝"
						 delegate:self cancelButtonTitle:@"確定"
						 otherButtonTitles:nil];
			[baseAlert show];
			[baseAlert release];
		}else
			flag=YES;
	}else
		flag=YES;
	/*
	MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
	if(myApp.syncStatus==YES){
		baseAlert = [[UIAlertView alloc]
					 initWithTitle:@"資料同步中無法新增刪除與修改"
					 message:@"請稍候再執行,謝謝"
					 delegate:self cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
		flag=NO;
		[mySqlite release];
	}
	*/
	
	if([todoEvent.calendarId length]>0)
		self.todoEvent=[[[TodoEvent alloc]initWithEventId:todoEvent.calendarId database:mySqlite.database]autorelease];
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:RESTORESYNCFLAG]==YES){
		baseAlert = [[UIAlertView alloc]
					 initWithTitle:@"資料同步還原中無法新增刪除與修改"
					 message:@"請稍候再執行,謝謝"
					 delegate:self cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
		flag=NO;
		[mySqlite release];
	}else if(todoEvent.syncStatus==1){
		baseAlert = [[UIAlertView alloc]
					 initWithTitle:@"資料同步中無法刪除與修改"
					 message:@"請稍候再執行,謝謝"
					 delegate:self cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
		flag=NO;
		[mySqlite release];
	}
	
	
	
	if(flag==YES){
		
		if([self.todoEvent.calendarId length]>0){
			title=@"修改失敗";
			flag=[mySqlite updTodoEvent:todoEvent.calendarId server:todoEvent.serverId data:self.tableArray];
			[mySqlite release];
		
			//DoLog(DEBUG,@"%@",[self.navigationController viewControllers]);
			if(flag==YES){
				//[[self.navigationController topViewController] viewWillAppear:YES];
				[[self parentViewController] viewWillAppear:YES];
				[self.navigationController popToRootViewControllerAnimated:YES];
			}
		}else{
			title=@"新增失敗";
			flag=[mySqlite insTodoEvent:self.tableArray trans:NO];
			[mySqlite release];
			if(flag==YES){
				[[self parentViewController] viewWillAppear:YES];
				[self.navigationController popViewControllerAnimated:YES];
			}
		}
	
		if(flag==NO){
			baseAlert = [[UIAlertView alloc]
									  initWithTitle:title
									  message:@"請再試ㄧ次,謝謝"
									  delegate:self cancelButtonTitle:@"確定"
									  otherButtonTitles:nil];
			[baseAlert show];
			[baseAlert release];
		}else if(fromFlag==1){
			baseAlert = [[UIAlertView alloc]
						 initWithTitle:@"新增成功"
						 message:nil
						 delegate:nil cancelButtonTitle:@"確定"
						 otherButtonTitles:nil];
			[baseAlert show];
			[baseAlert release];
		}
		
	}
	//[mySqlite release];
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [tableArray count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[tableArray objectAtIndex:section]count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
	
    NSString *CellIdentifier;
	
	if(section==0 || section==1 || section==6 || section==7)
		CellIdentifier= [NSString stringWithFormat:@"%d_%d_Cell",section,row];
	else
		CellIdentifier= @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	/*
	CGRect myRect = cell.contentView.frame;
	myRect.origin.x=3;
	myRect.origin.y=3;
	myRect.size.width=myRect.size.width-130;
	myRect.size.height=myRect.size.height-6;
	*/
    if (cell == nil) {
		if(section==7)
			cell = [[[NSBundle mainBundle] loadNibNamed:@"LabelCell" owner:self options:nil] lastObject];
		else if(section==0 || section==1)
			cell = [[[NSBundle mainBundle] loadNibNamed:@"TextFieldCell" owner:self options:nil] lastObject];
		else
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
	}
    
    // Set up the cell...
	NSString *tmpString=[[tableArray objectAtIndex:section] objectAtIndex:row];
	
		
	NSArray *tmpArray;
	switch (section) {
		case 0:
			((TextFieldCell*)cell).viewController = self;
			((TextFieldCell*)cell).myTag=section;
			if([tmpString length]==0)
				((TextFieldCell*)cell).customTextField.placeholder=@"主題";
			else{
				((TextFieldCell*)cell).customTextField.text=tmpString;
			}
			((TextFieldCell*)cell).customTextField.clearsOnBeginEditing=NO;
			break;
		case 1:
			((TextFieldCell*)cell).viewController = self;
			((TextFieldCell*)cell).myTag=section;
			if([tmpString length]==0)
				((TextFieldCell*)cell).customTextField.placeholder=@"地點";
			else{
				((TextFieldCell*)cell).customTextField.text=tmpString;
			}
			((TextFieldCell*)cell).customTextField.clearsOnBeginEditing=NO;
			break;
		case 2:
			tmpArray=[tmpString componentsSeparatedByString:@"#"];
			if(row==0){
				cell.textLabel.text=@"起始";
				cell.detailTextLabel.text=[tmpArray objectAtIndex:1];
			}else{
				cell.textLabel.text=@"結束";
				cell.detailTextLabel.text=[tmpArray objectAtIndex:1];
			}
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case 3:
			tmpArray=[tmpString componentsSeparatedByString:@"#"];
			if(row==0){
				cell.textLabel.text=@"重複";
				cell.detailTextLabel.text=[tmpArray objectAtIndex:1];
			}else{
				cell.textLabel.text=@"重複結束";
				cell.detailTextLabel.text=[tmpArray objectAtIndex:1];
			}
			/*
			if( (todoEvent.isSynced==0 && [todoEvent.calRecurrenceId isEqualToString:todoEvent.calendarId]==YES)
					|| (todoEvent.isSynced!=0 && [todoEvent.calRecurrenceId isEqualToString:todoEvent.serverId]==YES) 
					|| [todoEvent.calRecurrenceId isEqualToString:RECURRENCEID]==YES )
			 */
			if([todoEvent.calendarId length]<=0 || todoEvent.calType==1)/*新增或一系列才能改重覆規則*/
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case 4:
			cell.textLabel.text=@"通知";
			tmpArray=[tmpString componentsSeparatedByString:@"#"];
			if([tmpArray count]==2)
				cell.detailTextLabel.text=[tmpArray objectAtIndex:1];
			else
				cell.detailTextLabel.text=@"不通知";
			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case 5:
			tmpArray=[tmpString componentsSeparatedByString:@"#"];
			cell.textLabel.text=@"日曆分類";
			cell.detailTextLabel.text=[tmpArray objectAtIndex:1];
			
			if([todoEvent.calendarId length]<=0)
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			else{
				NSString *colorImage=[RuleArray getColorDictionary:[[tmpArray objectAtIndex:2]intValue]];
				if(colorImage!=nil){
					cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"calenfolder_320_%@.png",colorImage]]];
					cell.textLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
					cell.detailTextLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
					cell.textLabel.backgroundColor = [UIColor clearColor]; 
					cell.detailTextLabel.backgroundColor = [UIColor clearColor];
				}
			}
			break;
		case 7:
			/*
			((TextFieldCell*)cell).viewController = self;
			((TextFieldCell*)cell).myTag=section;
			if([tmpString length]==0)
				((TextFieldCell*)cell).customTextField.placeholder=@"備註";
			else
				((TextFieldCell*)cell).customTextField.text=tmpString;
			((TextFieldCell*)cell).customTextField.enabled=NO;
			*/
			
			((LabelCell*)cell).customLabel.frame=CGRectMake(5.0, 0.0, cell.contentView.frame.size.width-5, 100);
			((LabelCell*)cell).customLabel.numberOfLines=4;
			if([tmpString length]==0)
				((LabelCell*)cell).customLabel.text=@"備註";
			else
				((LabelCell*)cell).customLabel.text=tmpString;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case 6:
			cell.textLabel.text=@"事件圖示";
			cell.detailTextLabel.text=@"";
			
			for(UIView *tmpView in [cell.contentView subviews])
				[tmpView removeFromSuperview];
			
			if([tmpString length]>0){			
				/*
				 cell.detailTextLabel.numberOfLines=2;
				 cell.detailTextLabel.text=@"      ";
				 */
				NSString *iconImage=[RuleArray getEventIcon:[tmpString intValue]];
				if(iconImage!=nil){
					//cell.detailTextLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"eventicon_%@.png",iconImage]]];
					//CGRect myRect = cell.contentView.frame;
					UIImageView *myView=[[UIImageView alloc]initWithFrame:CGRectMake(245, 5.0f, 30.0f, 30.0f)];
					[myView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"eventicon_%@.png",iconImage]]];
					[cell.contentView addSubview:myView];
					[myView release];
				}
			}else {
				cell.detailTextLabel.text=@"無";
			}
			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
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
	
	NSInteger section = [indexPath section];
	NSInteger row = [indexPath row];
	
	EventDateViewController *eventDateController;
	RedoDateViewController *redoDateController;
	RedoDetailViewController *redoDetailController;
	//EventTimeViewController *eventTimeController;
	NotifyTimeViewController *eventTimeController;
	CategoryTableViewController *categoryTableController;
	MemoTextViewController *memoTextViewController;
	EventIconViewController *iconViewController;
	NSString *serviceId=nil;
	
	switch (section) {
		case 2:
			eventDateController = [[[EventDateViewController alloc] initWithNibName:@"EventDateView" bundle:nil ] autorelease];
			eventDateController.title=@"時間設定";
			eventDateController.flag=0;
			eventDateController.todoEvent=self.tableArray;

			[self.navigationController pushViewController:eventDateController animated:YES];
			
			break;
		case 3:
			serviceId=[ProfileUtil stringForKey:SERVICEID];
			/*
			if( (todoEvent.isSynced==0 && [todoEvent.calRecurrenceId isEqualToString:todoEvent.calendarId]==YES)
			   || (todoEvent.isSynced!=0 && [todoEvent.calRecurrenceId isEqualToString:todoEvent.serverId]==YES) 
			   || [todoEvent.calRecurrenceId isEqualToString:RECURRENCEID]==YES ){
			*/
			if(serviceId==nil || [serviceId length]<=0 || [serviceId longLongValue]==0){
				UIAlertView *baseAlert = [[UIAlertView alloc]
							 initWithTitle:@"完整版才能設定為重覆事件"
							 message:@"請申裝服務,謝謝"
							 delegate:self cancelButtonTitle:@"確定"
							 otherButtonTitles:nil];
				[baseAlert show];
				[baseAlert release];
			}else if([todoEvent.calendarId length]<=0 || todoEvent.calType==1){/*新增或一系列才能改重覆規則*/
			if(row==0){
				redoDetailController = [[[RedoDetailViewController alloc] initWithNibName:@"RedoDetailView" bundle:nil] autorelease];
				redoDetailController.title=@"事件重複";
				redoDetailController.todoEvent=self.tableArray;
			
				[self.navigationController pushViewController:redoDetailController animated:YES];
			}else if(row==1){
				redoDateController = [[[RedoDateViewController alloc] initWithNibName:@"RedoDateView" bundle:nil] autorelease];
				redoDateController.title=@"重複結束";
				redoDateController.todoEvent=self.tableArray;
				
				[self.navigationController pushViewController:redoDateController animated:YES];
			}
			}
			break;
		case 4:
			//eventTimeController = [[[EventTimeViewController alloc] initWithNibName:@"EventTimeView" bundle:nil ] autorelease];
			eventTimeController = [[[NotifyTimeViewController alloc] initWithNibName:@"NotifyTimeView" bundle:nil ] autorelease];
			eventTimeController.title=@"事件通知";
			eventTimeController.todoEvent=self.tableArray;
			
			[self.navigationController pushViewController:eventTimeController animated:YES];
			
			break;
		case 5:
			if([todoEvent.calendarId length]<=0){
			categoryTableController = [[[CategoryTableViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
			categoryTableController.title=@"日曆分類";
			categoryTableController.flag=1;
			categoryTableController.todoEvent=self.tableArray;
			[self.navigationController pushViewController:categoryTableController animated:YES];
			}
			break;
		case 0:
			break;
		case 1:
			break;
		case 7:
			memoTextViewController = [[[MemoTextViewController alloc] init]autorelease];
			memoTextViewController.todoEvent=self.tableArray;
			[self.navigationController pushViewController:memoTextViewController animated:YES];
			break;
		case 6:
			iconViewController = [[[EventIconViewController alloc] init]autorelease];
			iconViewController.todoEvent=self.tableArray;
			[self.navigationController pushViewController:iconViewController animated:YES];
			break;
		default:
			break;
	}
	
	
	[self.myTableView deselectRowAtIndexPath:[self.myTableView indexPathForSelectedRow] animated:NO];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  
{  
	NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
	
	if(section==7 && row==0)
		return 100.0;
	else
		return 45.0;  
}  


- (void)dealloc {
	//[redoArray release];
	[myTableView release];
	//[eventMemo release];
	//[eventDesc release];
	//[eventSubject release];
	[tableArray release];
	[todoEvent release];
	[todoCategory release];
	[eventRecurrence release];
    [super dealloc];
}

- (void) updateData:(UITextField *) aTextField forItem: (NSString *) anItem
{
	//DoLog(DEBUG,@"%@=%@",anItem,aTextField.text);
	[[[tableArray objectAtIndex:[anItem intValue]] objectAtIndex:0] setString:aTextField.text];
}

@end

