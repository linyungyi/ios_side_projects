//
//  EventDetailViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventDetailViewController.h"
#import "TodoEvent.h"
#import "TodoCategory.h"
#import "MySqlite.h"
#import "EventRecurrence.h"
#import "LabelCell.h"
#import "NewEventViewController.h"
#import "RuleArray.h"
#import "DateTimeUtil.h"
#import "MyCalendarAppDelegate.h"

@implementation EventDetailViewController

@synthesize todoEvent,tableArray;
@synthesize myTableView;
@synthesize redoArray;
@synthesize todoCategory,eventRecurrence;
//@synthesize listTodoEvent;
@synthesize eId,sId,flag;

-(id)init{
	if(self=[super init]){
		self.title=@"事件內容";
	}
	return self;
}

/*
-(id)initWithEvent:(TodoEvent *)myEvent nib:(NSString *)nibNameOrNil{
	if(self = [ super initWithNibName:nibNameOrNil bundle:nil ]){
		self.todoEvent=myEvent;
		self.title=@"事件內容";
		
		MySqlite *mySqlite=[[MySqlite alloc]init];
		
		TodoCategory *myCategory = [[TodoCategory alloc]initWithCategoryId:todoEvent.folderId database:mySqlite.database ];
		self.todoCategory=myCategory;
		[myCategory release];
		
		EventRecurrence *myRecurrence = [[EventRecurrence alloc]initWithId:todoEvent.calRecurrenceId database:mySqlite.database ];
		self.eventRecurrence=myRecurrence;
		[myRecurrence release];
		
		[mySqlite release];
	}
	return self;
}

-(id)initWithListTodoEvent:(ListTodoEvent *)myListTodoEvent nib:(NSString *)nibNameOrNil{
	if(self = [ super initWithNibName:nibNameOrNil bundle:nil ]){
		self.listTodoEvent=myListTodoEvent;
		self.title=@"事件內容";
		
		MySqlite *mySqlite=[[MySqlite alloc]init];
		
		TodoEvent *myEvent = [[TodoEvent alloc] initWithEventId:listTodoEvent.calendarId serverId:listTodoEvent.serverId database:mySqlite.database];
		self.todoEvent = myEvent;
		[myEvent release];
		
		TodoCategory *myCategory = [[TodoCategory alloc]initWithCategoryId:todoEvent.folderId database:mySqlite.database ];
		self.todoCategory=myCategory;
		[myCategory release];
		
		
		EventRecurrence *myRecurrence = [[EventRecurrence alloc]initWithId:listTodoEvent.calRecurrenceId database:mySqlite.database ];
		self.eventRecurrence=myRecurrence;
		[myRecurrence release];
		
		[mySqlite release];
	}
	return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	
	MySqlite *mySqlite=[[MySqlite alloc]init];
	todoEvent = [[TodoEvent alloc]initWithEventId:self.eId database:mySqlite.database];
	todoCategory = [[TodoCategory alloc]initWithCategoryId:todoEvent.folderId database:mySqlite.database ];
	eventRecurrence = [[EventRecurrence alloc]initWithId:todoEvent.calRecurrenceId database:mySqlite.database ];
	[mySqlite release];
	
	RuleArray *ruleArray=[[RuleArray alloc]init];
	self.redoArray=[ruleArray redoRule1];
	
	tableArray = [[NSMutableArray alloc]init];
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
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%@#%d/%02d/%02d %02d:%02d",todoEvent.startTime,[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]]];
	cmp=[DateTimeUtil getDateComponentsFromString:todoEvent.endTime];

	[tmpArray addObject:[NSMutableString stringWithFormat:@"%@#%d/%02d/%02d %02d:%02d",todoEvent.endTime,[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]]];
	//[tmpArray addObject:[NSMutableString stringWithFormat:@"%@#           %02d:%02d",todoEvent.endTime,[cmp hour],[cmp minute]]];
	[tableArray addObject:tmpArray];
	[tmpArray release];
	
	
	tmpArray = [[NSMutableArray alloc]init];
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%d#%@",eventRecurrence.type,[[ruleArray redoRule1] objectAtIndex:[ruleArray getRedoRowNo:eventRecurrence.type]]]];
	if(eventRecurrence.type!=-1){
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
		[tmpArray addObject:[NSMutableString stringWithFormat:@""]];
	
	[tableArray addObject:tmpArray];
	[tmpArray release];

	tmpArray = [[NSMutableArray alloc]init];
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%d#%@#%d",todoCategory.folderId,todoCategory.folderName,todoCategory.colorRgb]];
	 
	[tableArray addObject:tmpArray];
	[tmpArray release];
	
	tmpArray = [[NSMutableArray alloc]init];
	[tmpArray addObject:[NSMutableString stringWithFormat:@"%@",todoEvent.eventIcon]];
	[tableArray addObject:tmpArray];
	[tmpArray release];
	
	tmpArray = [[NSMutableArray alloc]init];
	NSMutableString *tmpString=[NSMutableString stringWithFormat:@"%@",todoEvent.memo];
	int i=MAXMEMOROW-[[todoEvent.memo componentsSeparatedByString:@"\n"]count];
	while(i>=0){
		[tmpString appendString:@"\n"];
		i--;
	}
	[tmpArray addObject:tmpString];
	[tableArray addObject:tmpArray];
	[tmpArray release];
	
	self.myTableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUNDIMG]];
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"編輯" style:UIBarButtonItemStyleBordered target:self action:@selector(doJob:)] autorelease];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	MySqlite *mySqlite=[[MySqlite alloc]init];
	self.todoEvent = [[TodoEvent alloc]initWithEventId:self.eId serverId:self.sId database:mySqlite.database];
	self.todoCategory = [[TodoCategory alloc]initWithCategoryId:todoEvent.folderId serverId:@"0" database:mySqlite.database ];
	self.eventRecurrence = [[EventRecurrence alloc]initWithId:todoEvent.calRecurrenceId database:mySqlite.database ];
	[mySqlite release];
	
	RuleArray *ruleArray=[[RuleArray alloc]init];
	
	[[[tableArray objectAtIndex:0] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%@",todoEvent.subject]];
	[[[tableArray objectAtIndex:1] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%@",todoEvent.location]];
	
	NSDateComponents *cmp=[DateTimeUtil getDateComponentsFromString:todoEvent.startTime];
	[[[tableArray objectAtIndex:2] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%@#%d/%02d/%02d %02d:%02d",todoEvent.startTime,[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]]];
	cmp=[DateTimeUtil getDateComponentsFromString:todoEvent.endTime];
	[[[tableArray objectAtIndex:2] objectAtIndex:1] setString:[NSMutableString stringWithFormat:@"%@#%d/%02d/%02d %02d:%02d",todoEvent.endTime,[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]]];
	
		
	[[[tableArray objectAtIndex:3] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%d#%@",eventRecurrence.type,[[ruleArray redoRule1] objectAtIndex:[ruleArray getRedoRowNo:eventRecurrence.type]]]];
	if(eventRecurrence.type!=-1){
		cmp=[DateTimeUtil getDateComponentsFromString:eventRecurrence.until];
		if([[tableArray objectAtIndex:3] count]==1)
			[[tableArray objectAtIndex:3] addObject:[NSMutableString stringWithFormat:@"%@#%d/%02d/%02d %02d:%02d",todoEvent.endTime,[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]] ];
		else
			[ [[tableArray objectAtIndex:3] objectAtIndex:1] setString:[NSMutableString stringWithFormat:@"%@#%d/%02d/%02d %02d:%02d",todoEvent.endTime,[cmp year],[cmp month],[cmp day],[cmp hour],[cmp minute]] ];
	}else{
		if([[tableArray objectAtIndex:3] count]==2)
			[[tableArray objectAtIndex:3] removeObject:[[tableArray objectAtIndex:3]objectAtIndex:1] ];

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
		[[[tableArray objectAtIndex:4] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@""]];
	
	[[[tableArray objectAtIndex:5] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%d#%@",todoCategory.folderId,todoCategory.folderName]];
	[[[tableArray objectAtIndex:6] objectAtIndex:0] setString:[NSMutableString stringWithFormat:@"%@",todoEvent.memo]];
		
	[self.myTableView reloadData];
	 
}
*/

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[self parentViewController] viewWillAppear:YES];
}


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[self parentViewController] viewWillAppear:YES];
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


-(void) doJob:(id)sender{
	if(self.todoEvent!=nil){
		DoLog(DEBUG,@"edit");
		self.flag=1;
		UIAlertView *baseAlert;
		
		MySqlite *mySqlite=[[MySqlite alloc]init];
		self.todoEvent=[[TodoEvent alloc]initWithEventId:todoEvent.calendarId database:mySqlite.database];
		
		if([[NSUserDefaults standardUserDefaults] boolForKey:RESTORESYNCFLAG]==YES){
			baseAlert = [[UIAlertView alloc]
						 initWithTitle:@"資料同步還原中無法新增刪除與修改"
						 message:@"請稍候再執行,謝謝"
						 delegate:self cancelButtonTitle:@"確定"
						 otherButtonTitles:nil];
			[baseAlert show];
			[baseAlert release];
		}else if(todoEvent.syncStatus==1){
			baseAlert = [[UIAlertView alloc]
									  initWithTitle:@"資料同步中無法刪除與修改"
									  message:@"請稍候再執行,謝謝"
									  delegate:self cancelButtonTitle:@"確定"
									  otherButtonTitles:nil];
			[baseAlert show];
			[baseAlert release];
		}else{
			if(todoEvent.calType==0 && [todoEvent.calRecurrenceId isEqualToString:@"0"]==YES){//一般事件編輯
				NewEventViewController *eventViewController = [[[NewEventViewController alloc] initWithEventId:todoEvent.calendarId nib:@"NewEventView"] autorelease];
				[self.navigationController pushViewController:eventViewController animated:YES];
			}else{//重覆事件編輯
				UIActionSheet *actionSheet = [[UIActionSheet alloc]
										  initWithTitle:@"重複事件,欲修改此系列全部事件或僅此事件"
										  delegate:self
										  cancelButtonTitle:@"否"
										  destructiveButtonTitle:@"僅此事件"
										  otherButtonTitles:@"此系列全部事件",
										  nil];
				[actionSheet showInView:self.view];
				[actionSheet release];
			}
		}
		[mySqlite release];
	}	
}

-(IBAction) doDel:(id)sender{
	if([todoEvent.calendarId length]>0){
		DoLog(DEBUG,@"delete");
		self.flag=2;
		UIAlertView *baseAlert;
		
		//MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
		//if(myApp.syncStatus==YES){
		//	baseAlert = [[UIAlertView alloc]
		//				 initWithTitle:@"資料同步中無法新增刪除與修改"
		//				 message:@"請稍候再執行,謝謝"
		//				 delegate:self cancelButtonTitle:@"確定"
		//				 otherButtonTitles:nil];
		//	[baseAlert show];
		//	[baseAlert release];
		
		MySqlite *mySqlite=[[MySqlite alloc]init];
		self.todoEvent=[[TodoEvent alloc]initWithEventId:todoEvent.calendarId database:mySqlite.database];
		
		if([[NSUserDefaults standardUserDefaults] boolForKey:RESTORESYNCFLAG]==YES){
				baseAlert = [[UIAlertView alloc]
						 initWithTitle:@"資料同步還原中無法新增刪除與修改"
						 message:@"請稍候再執行,謝謝"
						 delegate:self cancelButtonTitle:@"確定"
						 otherButtonTitles:nil];
				[baseAlert show];
				[baseAlert release];
		}else if(todoEvent.syncStatus==1){
				baseAlert = [[UIAlertView alloc]
							 initWithTitle:@"資料同步中無法刪除與修改"
							 message:@"請稍候再執行,謝謝"
							 delegate:self cancelButtonTitle:@"確定"
							 otherButtonTitles:nil];
				[baseAlert show];
				[baseAlert release];
		}else{
			if(todoEvent.calType==0 && [todoEvent.calRecurrenceId isEqualToString:@"0"]==YES){//一般事件刪除
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"確定刪除事件" message:nil
												delegate:self 
												cancelButtonTitle:@"取消" otherButtonTitles:@"確定", nil];
				[alert show];
				[alert release];
			}else{//重覆事件刪除
				UIActionSheet *actionSheet = [[UIActionSheet alloc]
										  initWithTitle:@"重複事件,欲刪除此系列全部事件或僅此事件"
										  delegate:self
										  cancelButtonTitle:@"取消"
										  destructiveButtonTitle:@"僅此事件"
										  otherButtonTitles:@"此系列全部事件",
										  nil];
				[actionSheet showInView:self.view];
				[actionSheet release];
			}
		}
		[mySqlite release];
	}	
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	BOOL dbFlag;
	if (buttonIndex == 1){
		DoLog(DEBUG,@"ok");
		if(self.flag==2){//一般事件刪除
			MySqlite *mySqlite = [ [MySqlite alloc] init];
			if(todoEvent.isSynced==0)//未同步直接刪除
				dbFlag=[mySqlite delTodoEvent:todoEvent trans:NO];
			else//已同步更新刪除狀態
				dbFlag=[mySqlite delUpdTodoEvent:todoEvent trans:NO];
			[mySqlite release];
			if(dbFlag==YES){
				[[self parentViewController] viewWillAppear:YES];
				[self.navigationController popViewControllerAnimated:YES];
			}else{
				DoLog(ERROR,@"delete error");
			}
		}
	}else{
		DoLog(DEBUG,@"cancel");
	}
	self.flag=0;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	DoLog(DEBUG,@"%d %d",buttonIndex,[actionSheet cancelButtonIndex]);
	if (buttonIndex != [actionSheet cancelButtonIndex])
	{
		MySqlite *mySqlite=[[MySqlite alloc]init];
		if(self.flag==1){//修改重覆事件
			NewEventViewController *eventViewController;
			
			if(buttonIndex==0){//修改例外事件
				eventViewController = [[[NewEventViewController alloc] initWithEventId:todoEvent.calendarId nib:@"NewEventView"] autorelease];
			}else{//修改一系列事件
				/*
				if(todoEvent.isSynced==0)
					eventViewController = [[[NewEventViewController alloc] initWithEvent:[[[TodoEvent alloc] initWithEventId:todoEvent.calRecurrenceId database:mySqlite.database] autorelease] nib:@"NewEventView"] autorelease];
				else
					eventViewController = [[[NewEventViewController alloc] initWithEvent:[[[TodoEvent alloc] initWithServerId:todoEvent.serverId database:mySqlite.database] autorelease] nib:@"NewEventView"] autorelease];
				*/
				//eventViewController = [[[NewEventViewController alloc] initWithEvent:[[[TodoEvent alloc] initWithEventId:todoEvent.calRecurrenceId database:mySqlite.database] autorelease] nib:@"NewEventView"] autorelease];
				eventViewController = [[[NewEventViewController alloc] initWithEventId:todoEvent.calRecurrenceId nib:@"NewEventView"] autorelease];
			}
			[mySqlite release];
			
			[self.navigationController pushViewController:eventViewController animated:YES];
		}else if(self.flag==2){//刪除重覆事件
			if(buttonIndex==0){//刪除例外事件
				if(todoEvent.isSynced==0)//未同步直接刪
					[mySqlite delTodoEvent:todoEvent trans:NO];
				else
					[mySqlite delUpdTodoEvent:todoEvent trans:NO];
			}else{//刪除一系列事件
				if(todoEvent.isSynced==0)//未同步直接刪
					[mySqlite delTodoEvent:[[[TodoEvent alloc] initWithEventId:todoEvent.calRecurrenceId database:mySqlite.database] autorelease] trans:NO];
				else{
					//[mySqlite delUpdTodoEvent:[[[TodoEvent alloc] initWithServerId:todoEvent.calRecurrenceId database:mySqlite.database] autorelease] trans:NO];
					[mySqlite delUpdTodoEvent:[[[TodoEvent alloc] initWithEventId:todoEvent.calRecurrenceId database:mySqlite.database] autorelease] trans:NO];
				}
			}
			[mySqlite release];
			
			[[self parentViewController] viewWillAppear:YES];
			[self.navigationController popViewControllerAnimated:YES];
		}
	}
	self.flag=0;
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
		if(section==0 || section==1 || section==7)
			cell = [[[NSBundle mainBundle] loadNibNamed:@"LabelCell" owner:self options:nil] lastObject];
		else
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSString *tmpString=[[tableArray objectAtIndex:section] objectAtIndex:row];
	
		
	NSArray *tmpArray;
	switch (section) {
		case 0:
			((LabelCell*)cell).customLabel.text=tmpString;
			break;
		case 1:
			((LabelCell*)cell).customLabel.text=tmpString;
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
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case 4:
			cell.textLabel.text=@"通知";
			
			if([tmpString length]>0){
				tmpArray=[tmpString componentsSeparatedByString:@"#"];
				cell.detailTextLabel.text=[tmpArray objectAtIndex:1];
			}else	
				cell.detailTextLabel.text=@"不通知";
			
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case 5:
			tmpArray=[tmpString componentsSeparatedByString:@"#"];
			cell.textLabel.text=@"日曆分類";
			cell.detailTextLabel.text=[tmpArray objectAtIndex:1];
			
			NSString *colorImage=[RuleArray getColorDictionary:[[tmpArray objectAtIndex:2]intValue]];
			if(colorImage!=nil){
				cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"calenfolder_320_%@.png",colorImage]]];
				cell.textLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
				cell.detailTextLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
				cell.textLabel.backgroundColor = [UIColor clearColor]; 
				cell.detailTextLabel.backgroundColor = [UIColor clearColor];
			}
			//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
					
					UIImageView *myView=[[UIImageView alloc]initWithFrame:CGRectMake(260.f, 5.0f, 30.0f, 30.0f)];
					[myView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"eventicon_%@.png",iconImage]]];
					[cell.contentView addSubview:myView];
					[myView release];
				}
				
				
			}else {
				cell.detailTextLabel.text=@"無";
			}
			break;
		case 7:
			((LabelCell*)cell).customLabel.frame=CGRectMake(5.0, 0.0, cell.contentView.frame.size.width-5, 100);
			((LabelCell*)cell).customLabel.numberOfLines=4;
			((LabelCell*)cell).customLabel.text=tmpString;
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
	[redoArray release];
	[myTableView release];
	[tableArray release];
	[todoEvent release];
	[todoCategory release];
	[eventRecurrence release];
	//[listTodoEvent release];
	[eId release];
	[sId release];
    [super dealloc];
}

@end

