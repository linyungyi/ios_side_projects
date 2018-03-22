//
//  SyncViewController.m
//  MyCalendar
//
//  Created by yves ho on 2010/2/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyncViewController.h"
#import "MyCalendarAppDelegate.h"
#import "MySqlite.h"
#import "SyncOperation.h"
#import "XMLParser.h"
#import "DateTimeUtil.h"
#import "BackupRestoreUtil.h"
#import "ProfileUtil.h"

@implementation SyncViewController

@synthesize defaultView,contentView,myActivityIndicatorView,contentLabel;
@synthesize syncFlag;
@synthesize syncOperation;
@synthesize backupStatus;
@synthesize restoreStatus;
//@synthesize enableBackup;
//@synthesize enableRestore;
@synthesize chkSyncTimer;
@synthesize backupLogs;
@synthesize myProgressView;

//@synthesize defaultBar,contentBar;
@synthesize serviceUtil;

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
	self.serviceUtil=[[ServiceUtil alloc]init];
	
	self.backupStatus=[NSMutableString stringWithString:@"0"];
	self.restoreStatus=[NSMutableString stringWithString:@"0"];
	/*
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	if(serviceId==nil || [serviceId length]<=0 || [serviceId longLongValue]==0){
		UIAlertView *alert = [[UIAlertView alloc]
				 initWithTitle:@"完整版才能使用備份還原與同步"
				 message:@"請申裝服務,謝謝"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	*/
	self.myProgressView.hidden=YES;
	
	self.view.backgroundColor = [UIColor clearColor];
	self.contentView.backgroundColor=[UIColor clearColor];
	//self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUNDIMG]];
	//self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUNDIMG]];
	
	/*
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calen_head.png"]]; 
	[self.defaultBar insertSubview:backgroundView atIndex:0]; 
	[backgroundView release];
	
	backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calen_head.png"]];
	[self.contentBar insertSubview:backgroundView atIndex:0]; 
	[backgroundView release];
	*/
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
	/*
	if(self.syncFlag==YES)
		self.syncFlag=NO;
	*/
}


- (void)dealloc {
	[serviceUtil release];
	//[defaultBar release];
	//[contentBar release];
	[myProgressView release];
	[backupLogs release];
	[contentLabel release];
	[chkSyncTimer release];
	[backupStatus release];
	[restoreStatus release];
	[syncOperation release];
	[defaultView release];
	[contentView release];
	[myActivityIndicatorView release];
    [super dealloc];
}

- (void) handleTimer:(BOOL)flag{
	
	MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
	DoLog(DEBUG,@"operations=%d",[[myApp.operationQueue operations] count]);
	DoLog(DEBUG,@"cancel=%d conurrent=%d exec=%d finish=%d ready=%d",syncOperation.isCancelled,syncOperation.isConcurrent,syncOperation.isExecuting,syncOperation.isFinished,syncOperation.isReady);
	if(myApp.syncStatus==NO){
		[self.chkSyncTimer invalidate];
		if([self.backupStatus intValue]==1){
			self.contentLabel.text=@"開始執行備份";
			[NSThread detachNewThreadSelector:@selector(startBackup:) toTarget:self withObject:backupStatus]; 
		}
	}
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
	DoLog(DEBUG,@"actionSheet=%d %d",buttonIndex,[actionSheet cancelButtonIndex]);
	if (buttonIndex != [actionSheet cancelButtonIndex])
	{
		
		if(self.syncFlag==1){//備份
			[self.backupStatus setString:[NSMutableString stringWithString:@"1"] ];
			[self.myActivityIndicatorView startAnimating];
			self.contentLabel.text=@"備份指令執行中";
			self.view=self.contentView;
			
			if(buttonIndex==0){
				[self doSync:nil];
				self.chkSyncTimer=[NSTimer scheduledTimerWithTimeInterval: 1.0f
							target: self
							selector: @selector(handleTimer:)
							userInfo: nil
							repeats: YES];
			}else{
				[NSThread detachNewThreadSelector:@selector(startBackup:) toTarget:self withObject:backupStatus];
			}
			
		}else if(self.syncFlag==2){//
			if(buttonIndex<[self.backupLogs count]){
				[self.restoreStatus setString:[NSMutableString stringWithString:@"1"] ];
				[self.myActivityIndicatorView startAnimating];
				self.contentLabel.text=@"還原指令執行中";
				self.view=self.contentView;
				[NSThread detachNewThreadSelector:@selector(startRestore:) toTarget:self withObject:[self.backupLogs objectAtIndex:buttonIndex]];
			}else{
				DoLog(ERROR,@"data error");
				self.syncFlag=0;
				[self.restoreStatus setString:[NSMutableString stringWithString:@"0"] ];
			}
		}
	}else{
		if(self.syncFlag==1)
			self.syncFlag=0;
		else if(self.syncFlag==2){
			self.syncFlag=0;
			[self.restoreStatus setString:[NSMutableString stringWithString:@"0"] ];
		}
	}
		
	 
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(self.syncFlag==1){//備份
		if (buttonIndex == 1){//繼續備份
			[backupStatus setString:[NSMutableString stringWithString:@"1"]];
			self.contentLabel.text=@"備份中";
			[NSThread detachNewThreadSelector:@selector(startBackup:) toTarget:self withObject:backupStatus];
		}else{//取消備份
			[backupStatus setString:[NSMutableString stringWithString:@"0"]];
			[self doneSync];
		}
	}else if(self.syncFlag==2){//還原
		if(buttonIndex == 1){
			[self.restoreStatus setString:[NSMutableString stringWithString:@"1"] ];
			
			self.contentLabel.text=@"查詢備份列表中";
			[self.myActivityIndicatorView startAnimating];
			self.view=self.contentView;
			[NSThread detachNewThreadSelector:@selector(queryBackupLog) toTarget:self withObject:nil];
		}else
			self.syncFlag=0;
	}else if(self.syncFlag==3){//同步
		MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
		if(buttonIndex == 1){
			[self.myActivityIndicatorView stopAnimating];
			self.myActivityIndicatorView.hidden=YES;
			self.myProgressView.progress=0;
			self.myProgressView.hidden=NO;
			
			self.contentLabel.text=@"同步進行中";
			self.view=self.contentView;
			
			
			self.syncOperation=[[SyncOperation alloc]init];
			syncOperation.delegate = self;
			[myApp.operationQueue addOperation:syncOperation];
		}else{
			myApp.syncStatus=NO;
			self.syncFlag=0;
		}
	}
}

-(IBAction) doBackup:(id)sender{
	UIAlertView *alert;
	
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	if(serviceId==nil || [serviceId length]<=0 || [serviceId longLongValue]==0){
		alert = [[UIAlertView alloc]
							  initWithTitle:@"完整版才能使用備份還原與同步"
							  message:@"請申裝服務,謝謝"
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
	//myApp.rootController.selectedIndex=0;
	
	//BOOL tmpFlag1=[[NSUserDefaults standardUserDefaults] boolForKey:BACKUPRUNNING];
	//BOOL tmpFlag2=[[NSUserDefaults standardUserDefaults] boolForKey:RESTORERUNNING];
	BOOL tmpFlag1=[ProfileUtil boolForKey:BACKUPRUNNING];
	BOOL tmpFlag2=[ProfileUtil boolForKey:RESTORERUNNING];
	BOOL tmpFlag3=myApp.syncStatus;
	
	self.syncFlag=1;
	NSString *title;
	
	if(tmpFlag1==YES || tmpFlag2==YES || tmpFlag3==YES){
		if(tmpFlag1==YES)
			title=@"備份執行中";
		else if(tmpFlag2==YES)
			title=@"還原執行中";
		else
			title=@"同步執行中";
			
		alert = [[UIAlertView alloc]
				 initWithTitle:title
				 message:@"請稍候再試,謝謝"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else{
		
	//0:未起動 1:執行中 2:取消
	if([self.backupStatus intValue]!=1){
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:@"同步可以讓伺服器與手機上的資料一致"
									  delegate:self
									  cancelButtonTitle:@"取消備份"
									  destructiveButtonTitle:@"先執行同步"
									  otherButtonTitles:@"直接進行備份",
									  nil];
		[actionSheet showInView:self.view];
		[actionSheet release];
	}else{
		alert = [[UIAlertView alloc]
					  initWithTitle:@"已在執行"
					  message:@"請稍候再試,謝謝"
					  delegate:nil
					  cancelButtonTitle:@"確定"
					  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	}
	// Auto dismiss after 3 seconds
	//[self performSelector:@selector(startBackup) withObject:nil afterDelay:0.0f];
	 
}

-(void)startBackup:(NSMutableString *)bflag{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[bflag setString:[NSMutableString stringWithString:@"1"] ];

	NSInteger resultCode;
	
	/*
	for(int i=0;i<100000;i++){
		DoLog(DEBUG,@"backup=%d",i);
		[NSThread sleepForTimeInterval:1.0f];
		if([bflag intValue]==2)
			break;
	}
	*/
	
	resultCode=[BackupRestoreUtil startBackup];
	
	[self performSelectorOnMainThread:@selector(doneBackuping:) withObject:[NSString stringWithFormat:@"%d",resultCode ] waitUntilDone:NO];
	
	if(resultCode==0){
		//[[NSUserDefaults standardUserDefaults] setBool:YES forKey: BACKUPRUNNING];
		[ProfileUtil setBool:YES forKey:BACKUPRUNNING];
		
		NSMutableDictionary *backupLog=nil;
		NSString *bId=nil;
		MySqlite *mySqlite = [[MySqlite alloc]init];
		backupLog=[mySqlite getLastBackupLog:0];
		if(backupLog!=nil)
			bId=[backupLog objectForKey:@"backupId"];
		[mySqlite release];
		
		NSMutableDictionary *resultDictionary;
		NSMutableArray *bArrays;
		BOOL flag=YES;
		UIAlertView *alert;
		while(bId!=nil){
			resultDictionary=[BackupRestoreUtil getBackupResult:bId];
			bArrays=[resultDictionary objectForKey:@"resultArray"];
			if(bArrays!=nil){
				if([bArrays count]==1){
					backupLog=[bArrays objectAtIndex:0];
					if([[backupLog objectForKey:@"backupResult"]intValue]>0){
						MySqlite *mySqlite=[[MySqlite alloc]init];
						flag=[mySqlite delBackupLog:bId];
						[mySqlite release];
					
						if(flag==YES){
							//[[NSUserDefaults standardUserDefaults] setBool:NO forKey: BACKUPRUNNING];
							[ProfileUtil setBool:NO forKey:BACKUPRUNNING];
					
							if([[backupLog objectForKey:@"backupResult"]intValue]!=1){
								alert = [[UIAlertView alloc]
										 initWithTitle:@"備份執行失敗"
										 message:nil
										 delegate:nil
										 cancelButtonTitle:@"確定"
										 otherButtonTitles:nil];
								[alert show];
								[alert release];
							}else{
								alert = [[UIAlertView alloc]
										 initWithTitle:@"備份執行成功"
										 message:nil
										 delegate:nil
										 cancelButtonTitle:@"確定"
										 otherButtonTitles:nil];
								[alert show];
								[alert release];
							}
					
							break;
						}else
							DoLog(ERROR,@"can't del backup log");
					}else
						DoLog(ERROR,@"can't get data");
				}
				DoLog(DEBUG,@"%d %d",[bArrays count],flag);
			}else{
				DoLog(ERROR,@"can't connect server");
			}
			[NSThread sleepForTimeInterval:2.0f];
		}
		
	}
	
    [pool release];
}

- (void) doneBackuping:(NSString *)isStop{
	
	UIAlertView *alert;
	if([isStop intValue]==1){
		alert = [[UIAlertView alloc]
				 initWithTitle:@"備份要求失敗"
				 message:@"網路問題"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
		self.syncFlag+=5;
	}else if([isStop intValue]==2){
		alert = [[UIAlertView alloc]
				 initWithTitle:@"備份要求失敗"
				 message:@"伺服器問題"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
		self.syncFlag+=5;
	}else if([isStop intValue]==3){
		alert = [[UIAlertView alloc]
				 initWithTitle:@"備份要求失敗"
				 message:@"認證失敗"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
		self.syncFlag+=5;
	}else if([isStop intValue]>=6){
		DoLog(ERROR,@"need handle code=%@",isStop);
		self.syncFlag+=5;
	}else{
		DoLog(INFO,@"backup request send successful");
		
		alert = [[UIAlertView alloc]
				 initWithTitle:@"備份指令送出成功"
				 message:@"伺服器正在執行備份,成功與否會再通知"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	[backupStatus setString:[NSMutableString stringWithString:@"0"]];
	
	[self doneSync];
	
	if([isStop intValue]>=6)
		[serviceUtil chkResultCode:[isStop intValue]];
}

-(IBAction) doRestore:(id)sender{
	UIAlertView *alert;
	
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	if(serviceId==nil || [serviceId length]<=0 || [serviceId longLongValue]==0){
		alert = [[UIAlertView alloc]
							  initWithTitle:@"完整版才能使用備份還原與同步"
							  message:@"請申裝服務,謝謝"
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	//BOOL tmpFlag1=[[NSUserDefaults standardUserDefaults] boolForKey:BACKUPRUNNING];
	//BOOL tmpFlag2=[[NSUserDefaults standardUserDefaults] boolForKey:RESTORERUNNING];
	BOOL tmpFlag1=[ProfileUtil boolForKey:BACKUPRUNNING];
	BOOL tmpFlag2=[ProfileUtil boolForKey:RESTORERUNNING];
	
	MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
	BOOL tmpFlag3=myApp.syncStatus;
		
	self.syncFlag=2;
	NSString *title;
	
	if(tmpFlag1==YES || tmpFlag2==YES || tmpFlag3==YES){
		if(tmpFlag1==YES)
			title=@"備份執行中";
		else if(tmpFlag2==YES)
			title=@"還原執行中";
		else
			title=@"同步執行中";
		
		alert = [[UIAlertView alloc]
				 initWithTitle:title
				 message:@"請稍候再試,謝謝"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else{
	
	//0:未起動 1:執行中 2:取消
	if([self.restoreStatus intValue]!=1){
		alert = [[UIAlertView alloc]
					initWithTitle:@"確定還原目前伺服器上的行事曆?"
					message:@"還原會刪除現正所有行事曆資料"
					delegate:self
					cancelButtonTitle:@"取消"
					otherButtonTitles:@"確定",nil];
		[alert show];
		[alert release];		
	}else{
		alert = [[UIAlertView alloc]
							  initWithTitle:@"已在執行"
							  message:@"請稍候再試,謝謝"
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	}
	// Auto dismiss after 3 seconds
	//[self performSelector:@selector(startRecover) withObject:nil afterDelay:0.0f];
}

-(void) queryBackupLog{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	
	NSMutableDictionary *resultDictionary=[BackupRestoreUtil getBackupResult:nil];
	NSMutableArray *bArrays=[resultDictionary objectForKey:@"resultArray"];
	NSMutableArray *bLogs=[[NSMutableArray alloc]init];
	NSMutableDictionary *backupLog;
	UIAlertView *alert;
	
	[self.myActivityIndicatorView stopAnimating];
	self.view=self.defaultView;
	
	if(bArrays != nil){
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"請選擇要還原的備份日期" 
																 delegate:self 
														cancelButtonTitle:nil 
												   destructiveButtonTitle:nil 
														otherButtonTitles:nil]; 
		for (int i = 0; i < [bArrays count] && i<5 ; i++) { 
			backupLog=[bArrays objectAtIndex:i];
			if([[backupLog objectForKey:@"backupResult"]intValue]==1){
				[actionSheet addButtonWithTitle:[DateTimeUtil getStringFromDate:[DateTimeUtil getDateFromString:[backupLog objectForKey:@"backupBgnTime"]] forKind:1]]; 
				[bLogs addObject:[backupLog objectForKey:@"backupId"]];
			}
		}
		self.backupLogs=bLogs;
		
		if([self.backupLogs count]>0){
			[actionSheet addButtonWithTitle:@"取消"]; 
			actionSheet.cancelButtonIndex = [self.backupLogs count]; 
			[actionSheet showInView:self.view]; 
		}else{
			[self.restoreStatus setString:[NSMutableString stringWithString:@"0"] ];
			alert = [[UIAlertView alloc]
					 initWithTitle:@"無可用備份可還原"
					 message:@"請稍候再試或先備份,謝謝"
					 delegate:nil
					 cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		[actionSheet release];
		
	}else{
		[self.restoreStatus setString:[NSMutableString stringWithString:@"0"] ];
		
		NSInteger resultCode=-1;
		
		if([resultDictionary objectForKey:@"resultCode"]!=nil)
			resultCode=[[resultDictionary objectForKey:@"resultCode"]intValue];
		
		DoLog(ERROR,@"resultCode=%d",resultCode);
		if(resultCode<6){
			alert = [[UIAlertView alloc]
							  initWithTitle:@"無法取得備份資料"
							  message:@"請稍候再試,謝謝"
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}else {
			[serviceUtil chkResultCode:resultCode];
		}

	}
	[bLogs release];	
	
	[pool release];
}

-(void) startRestore:(NSString *)bId{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[self.restoreStatus setString:[NSMutableString stringWithString:@"1"]];
	
	NSInteger resultCode=[BackupRestoreUtil startRestore:bId];
	if(resultCode==0){
		//[[NSUserDefaults standardUserDefaults] setBool:YES forKey: RESTORERUNNING];
		[ProfileUtil setBool:YES forKey:RESTORERUNNING];
							
		NSMutableDictionary *restoreLog=nil;
		NSString *rId=nil;
		MySqlite *mySqlite = [[MySqlite alloc]init];
		restoreLog=[mySqlite getLastRestoreLog:0];
		if(restoreLog!=nil)
			rId=[restoreLog objectForKey:@"restoreId"];
		[mySqlite release];
			
		NSMutableDictionary *resultDictionary;
		NSMutableArray *bArrays;
		BOOL flag=YES;
		NSInteger result=-1;
		UIAlertView *alert;
		
		while(rId!=nil){
			resultDictionary=[BackupRestoreUtil getRestoreResult:rId];
			bArrays=[resultDictionary objectForKey:@"resultArray"];
			if(bArrays!=nil){
				if([bArrays count]==1){
					restoreLog=[bArrays objectAtIndex:0];
					result=[[restoreLog objectForKey:@"restoreResult"]intValue];
					if(result>0){
						MySqlite *mySqlite=[[MySqlite alloc]init];
						if(result==1)
							flag=[mySqlite updRestoreLog:restoreLog];
						else
							flag=[mySqlite delRestoreLog:rId];
						[mySqlite release];
						
						if(flag==YES){
							//[[NSUserDefaults standardUserDefaults] setBool:NO forKey: RESTORERUNNING];
							[ProfileUtil setBool:NO forKey:RESTORERUNNING];
					
							if(result!=1){
								resultCode=50;
								alert = [[UIAlertView alloc]
											  initWithTitle:@"還原執行失敗"
											  message:nil
											  delegate:nil
											  cancelButtonTitle:@"確定"
											  otherButtonTitles:nil];
								[alert show];
								[alert release];
							}else{
								resultCode=60;
								alert = [[UIAlertView alloc]
										 initWithTitle:@"還原執行成功"
										 //message:@"請執行同步作業,將遠端資料下載,謝謝"
										 message:@"將進行同步,請稍候,謝謝"
										 delegate:nil
										 cancelButtonTitle:@"確定"
										 otherButtonTitles:nil];
								[alert show];
								[alert release];
							}
							break;
						}else
							DoLog(ERROR,@"can't use database");
					}else
						DoLog(ERROR,@"can't get data");
				}
				DoLog(DEBUG,@"%d %d",[bArrays count],flag);
			}else{
				DoLog(ERROR,@"can't connect server");
			}
				
			[NSThread sleepForTimeInterval:2.0f];
		}						
	}
	[self performSelectorOnMainThread:@selector(doneRestoring:) withObject:[NSString stringWithFormat:@"%d",resultCode ] waitUntilDone:NO];	
	[pool release];
	
}

- (void) doneRestoring:(NSString *)isStop{
	
	UIAlertView *alert;
	if([isStop intValue]==1){
		alert = [[UIAlertView alloc]
				 initWithTitle:@"還原要求失敗"
				 message:@"網路問題"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
		self.syncFlag+=5;
	}else if([isStop intValue]==2){
		alert = [[UIAlertView alloc]
				 initWithTitle:@"還原要求失敗"
				 message:@"伺服器問題"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
		self.syncFlag+=5;
	}else if([isStop intValue]==3){
		alert = [[UIAlertView alloc]
				 initWithTitle:@"還原要求失敗"
				 message:@"認證失敗"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
		self.syncFlag+=5;
	}else if([isStop intValue]==4){
		alert = [[UIAlertView alloc]
				 initWithTitle:@"還原要求失敗"
				 message:@"無備份資料"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
		self.syncFlag+=5;
	}else if([isStop intValue]==50){
		DoLog(DEBUG,@"restore request done failure");
	}else if([isStop intValue]==60){
		DoLog(DEBUG,@"restore request done successful");
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:RESTORESYNCFLAG];
		
		[self doSync:nil];
	}else if([isStop intValue]>=6){
		DoLog(ERROR,@"need handle code=%@",isStop);
		self.syncFlag+=5;
	}else{
		DoLog(DEBUG,@"restore request send successful");
		
		alert = [[UIAlertView alloc]
				 initWithTitle:@"還原指令送出成功"
				 message:@"伺服器正在執行還原,成功與否會再通知"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
		 
	}
	
	[restoreStatus setString:[NSMutableString stringWithString:@"0"]];
	
	if([isStop intValue]!=60)
		[self doneSync];
	
	if([isStop intValue]!=50 && [isStop intValue]!=60 && [isStop intValue]>=6)
		[serviceUtil chkResultCode:[isStop intValue]];
}


-(IBAction) doSync:(id)sender{
	UIAlertView *alert;
	
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	if(serviceId==nil || [serviceId length]<=0 || [serviceId longLongValue]==0){
		alert = [[UIAlertView alloc]
							  initWithTitle:@"完整版才能使用備份還原與同步"
							  message:@"請申裝服務,謝謝"
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}

	//BOOL tmpFlag1=[[NSUserDefaults standardUserDefaults] boolForKey:BACKUPRUNNING];
	//BOOL tmpFlag2=[[NSUserDefaults standardUserDefaults] boolForKey:RESTORERUNNING];
	BOOL tmpFlag1=[ProfileUtil boolForKey:BACKUPRUNNING];
	BOOL tmpFlag2=[ProfileUtil boolForKey:RESTORERUNNING];
	NSString *title;
	
	if(sender!=nil && (tmpFlag1==YES || tmpFlag2==YES)){
		if(tmpFlag1==YES)
			title=@"備份執行中";
		else
			title=@"還原執行中";
		
		alert = [[UIAlertView alloc]
				 initWithTitle:title
				 message:@"請稍候再試,謝謝"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else{
		
	MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
	if(myApp.syncStatus==NO){
		myApp.syncStatus=YES;
		
		if(sender!=nil){//手動啓動同步,非備份或還原啓動
			
			if([self.backupStatus intValue]!=1 && [self.restoreStatus intValue]!=1){
				self.syncFlag=3;
				
				alert = [[UIAlertView alloc]
						 initWithTitle:@"確定進行同步？"
						 message:nil
						 delegate:self
						 cancelButtonTitle:@"取消"
						 otherButtonTitles:@"確定",nil];
				[alert show];
				[alert release];
			}else{
				alert = [[UIAlertView alloc]
						 initWithTitle:@"備份還原執行中"
						 message:@"請稍候再試,謝謝"
						 delegate:nil
						 cancelButtonTitle:@"確定"
						 otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
		}else{//備份或還原啓動同步
			
			[self.myActivityIndicatorView stopAnimating];
			self.myActivityIndicatorView.hidden=YES;
			self.myProgressView.progress=0;
			self.myProgressView.hidden=NO;			
			
			self.contentLabel.text=@"同步進行中";
			self.syncOperation=[[SyncOperation alloc]init];
			syncOperation.delegate = self;
			[myApp.operationQueue addOperation:syncOperation];
		}
			
	}else if(sender!=nil){//手動啓動同步,非備份啓動
		alert = [[UIAlertView alloc]
							  initWithTitle:@"自動同步執行中"
							  message:@"請稍候再試,謝謝"
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
		
	}
}

-(IBAction) stopSync:(id)sender{
	DoLog(DEBUG,@"stopSync=%d",self.syncFlag);
	
	//UIAlertView *alert;
	if(syncFlag==1){
		if([backupStatus intValue]==1){
			[backupStatus setString:[NSMutableString stringWithString:@"2"]];
			
			MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
			if(myApp.syncStatus==YES){
				DoLog(DEBUG,@"cancel backup %d",[[myApp.operationQueue operations] count]);
				//[myApp.operationQueue cancelAllOperations];
				[myApp.syncOperation cancel];
				[self.syncOperation cancel];
				myApp.syncStatus=NO;
			}
			DoLog(DEBUG,@"cancel backup");
			[self doneSync];
		}
	}else if(syncFlag==2){
		if([restoreStatus intValue]==1){
			[restoreStatus setString:[NSMutableString stringWithString:@"2"]];
			DoLog(DEBUG,@"cancel restore");
			[self doneSync];
		}
	}else if(syncFlag==3){
		[self.syncOperation cancel];
		DoLog(DEBUG,@"cancel sync");
		/*
		alert = [[UIAlertView alloc]
				 initWithTitle:@"同步取消中,請稍候"
				 message:nil
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
		 */
		//MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
		//myApp.syncStatus=NO;
	}
}

- (void) doneSyncing:(NSString *)isStop{
	/*0:成功,1:失敗,2:部份失敗,3:認證失敗,4:網路失敗,5:使用者終止*/
	
	
	UIAlertView *alert;
	if([isStop intValue]!=0){
		//DoLog(DEBUG,@"fail");
		NSString *msg;
		
		switch([isStop intValue]){
			case 1:
				msg=@"程式錯誤";
				break;
			case 2:
				msg=@"一般錯誤";
				break;
			case 3:
				msg=@"認證失敗";
				break;
			case 4:
				msg=@"網路或伺服器問題";
				break;
			case 5:
				msg=@"使用者中斷";
				break;
			default:
				msg=nil;
				break;
		}
		
		if(self.syncFlag!=1){//單獨或還原同步
			alert = [[UIAlertView alloc]
					 initWithTitle:@"同步失敗"
					 message:msg
					 delegate:nil
					 cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
			[alert show];
			[alert release];
			self.syncFlag+=5;
		}else{//備份前同步
			[backupStatus setString:[NSMutableString stringWithString:@"3"]];
			if([isStop intValue]<6){
				alert = [[UIAlertView alloc]
					 initWithTitle:@"同步失敗"
					 message:@"是否繼續備份"
					 delegate:self
					 cancelButtonTitle:@"否"
					 otherButtonTitles:@"是",nil];
				[alert show];
				[alert release];
			}else {
				[backupStatus setString:[NSMutableString stringWithString:@"0"]];
				[self doneSync];
			}
		}
	}else{
		//DoLog(DEBUG,@"success");
		if(self.syncFlag!=1){//單獨或還原同步
			alert = [[UIAlertView alloc]
				 initWithTitle:@"同步成功"
				 message:nil
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	
	MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
	myApp.syncStatus=NO;
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:RESTORESYNCFLAG];
	
	[self.syncOperation release];
	self.syncOperation=nil;	
	
	self.myActivityIndicatorView.hidden=NO;
	self.myProgressView.hidden=YES;
	
	if(self.syncFlag!=1 && self.syncFlag!=6)
		[self doneSync];
	
	if([isStop intValue]>=6)
		[serviceUtil chkResultCode:[isStop intValue]];
}

-(void) setProgress:(NSString *)p{
	DoLog(DEBUG,@"%@ %f %f",p,self.myProgressView.progress,([p intValue]/10.0f));
	[NSThread detachNewThreadSelector:@selector(updProcess:) toTarget:self withObject:p];
}

-(void) updProcess:(NSString *)p{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	self.myProgressView.progress=([p floatValue]/10);
	[pool release];
}

-(void)doneSync{
	
	MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
	NSArray *tmpArray=[myApp.rootController viewControllers];
	for(UIViewController *viewController in tmpArray){
		//DoLog(DEBUG,@"%@",[viewController description]);
		[viewController viewWillAppear:YES]; 
	}
	
	[self.myActivityIndicatorView stopAnimating];
	self.syncFlag=0;
	self.view=self.defaultView;
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES]; 
	
	DoLog(DEBUG,@"SyncViewController viewWillAppear");
}


@end
