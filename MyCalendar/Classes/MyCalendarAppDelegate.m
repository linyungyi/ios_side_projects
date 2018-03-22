//
//  MyCalendarAppDelegate.m
//  MyCalendar
//
//  Created by yves ho on 2010/2/28.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MyCalendarAppDelegate.h"
#import "MySqlite.h"
#import "RuleArray.h"
#import "DateTimeUtil.h"
#import "BackupRestoreUtil.h"
#import "ProfileUtil.h"
#import "InterfaceUtil.h"

@implementation MyCalendarAppDelegate

@synthesize window;
@synthesize rootController;
@synthesize database;
@synthesize syncOperation;
@synthesize operationQueue;
@synthesize syncTimer;
//@synthesize chkTimer;
@synthesize syncStatus;
@synthesize syncDate;
@synthesize loginController;
@synthesize versionInfo;
//@synthesize statusFlag;

/*
static BOOL syncStatus;

+ (BOOL) getSyncStatus{
	return syncStatus;
}
*/
/*
- (void)applicationDidFinishLaunching:(UIApplication *)application {  
	application.applicationIconBadgeNumber=0;
	
	[self initData:application];	
}
*/

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSString *token=[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"< >"]];
	DoLog(INFO,@"%@",token);
	[NSThread detachNewThreadSelector:@selector(sendDeviceToken:) toTarget:self withObject:token];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DoLog(ERROR,@"Error: %@", error);
	
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSString *calendarId=nil;
	
    DoLog(DEBUG,@"user info %@", userInfo);
	DoLog(DEBUG,@"aps=%@",[userInfo objectForKey:@"aps"]);
	DoLog(DEBUG,@"aps=%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
	DoLog(DEBUG,@"aps=%@",[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"]);
	
	[NSThread detachNewThreadSelector:@selector(doFeedback:) toTarget:self withObject:calendarId];
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"事件通知"
						  message:[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"]
						  delegate:nil
						  cancelButtonTitle:@"確定"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	UIAlertView *alert;
	
	
	
	NSString *calendarId=nil;
	
	DoLog(DEBUG,@"launchOptions %@",launchOptions);
	//NSString *tmpString=[NSString stringWithFormat:@"%@",launchOptions];
	
	if(launchOptions!=nil && [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"]!=nil){
		
		[NSThread detachNewThreadSelector:@selector(doFeedback:) toTarget:self withObject:calendarId];
		
		alert = [[UIAlertView alloc]
							  initWithTitle:@"事件通知"
							  message:[[[launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"aps"] objectForKey:@"alert"]
							  //message:tmpString
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else
		application.applicationIconBadgeNumber=0;
	
	[self initData:application];
	
	//self.rootController.selectedIndex=1;
	
	if(launchOptions!=nil)
		return YES;
	else
		return NO;
}


-(void) initData:(UIApplication *)application{
	
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calentoolbar_bg.png"]]; 
	[rootController.tabBar insertSubview:backgroundView atIndex:0]; 
	[backgroundView release];
	
	MySqlite *mySqlite=[[MySqlite alloc]init];
	[mySqlite releaseSyncStatus];
	if([mySqlite getTodoCategoryCount]<=0)
		[mySqlite insDefaultCategory];
	//[mySqlite alterDatabase];
	[mySqlite release];
	
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];	
	
	
    // Override point for customization after application launch
		
	self.operationQueue = [[NSOperationQueue alloc] init];
	self.syncTimer = [NSTimer scheduledTimerWithTimeInterval: AUTOSYNCSECS
													  target: self
													selector: @selector(handleTimer1:)
													userInfo: nil
													 repeats: YES];	
	/*
	self.chkTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f
													 target: self
												   selector: @selector(handleTimer2:)
												   userInfo: nil
													repeats: YES];
	*/
	[NSThread detachNewThreadSelector:@selector(chkBackupRestore) toTarget:self withObject:nil];	
	
	/*
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	DoLog(INFO,@"serviceId=%@ %@ %@",serviceId,SERVICETYPE,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]);
	if(serviceId==nil || [serviceId length]<=0){
		UIAlertView *alert = [[UIAlertView alloc]
				 initWithTitle:@"您尚未申租服務"
				 message:nil
				 delegate:self
				 cancelButtonTitle:@"試用"
				 otherButtonTitles:@"登入",nil];
		[alert show];
		[alert release];
	}else
		[window addSubview:[loginController view]];
	*/
	
	[window addSubview:[loginController view]];
	[window makeKeyAndVisible];	
	
}

- (void)dealloc {
	sqlite3_close(database);
	[versionInfo release];
	[loginController release];
	[syncDate release];
	[syncTimer release];
	[operationQueue release];
	[syncOperation release];
	[rootController release];
    [window release];
    [super dealloc];
}



- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	DoLog(DEBUG,@"click index number is =%d",buttonIndex);
	if (buttonIndex == 1){
			//[rootController.view removeFromSuperview];
			[window addSubview:[loginController view]];
			//[window makeKeyAndVisible];
	}else{
			[window addSubview:rootController.view];
			//[window makeKeyAndVisible];
	}
	
}


-(void) doFeedback:(NSString *)calendarId{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	MySqlite *mySqlite=[[MySqlite alloc]init];
	[mySqlite updAgendaEvent:nil server:calendarId];
	[mySqlite release];
	
	[InterfaceUtil feedbackNotification:calendarId];
	[pool release];
}

-(void) sendDeviceToken:(NSString *)deviceToken{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[InterfaceUtil updDeviceToken:deviceToken];
	[pool release];
}


-(BOOL) isNextTime{
	BOOL result=NO;
	
	if(self.syncDate==nil)
		self.syncDate=[NSDate date];
	
	DoLog(DEBUG,@"%@",[self.syncDate description]);
	
	NSDate *now=[NSDate date];
	NSTimeInterval timeInterval=[ProfileUtil integerForKey:AUTORULE]*60;
	NSDate *nextDate=[self.syncDate addTimeInterval:timeInterval];
	
	if([now compare:nextDate]!=NSOrderedAscending){
		self.syncDate =now;
		result= YES;
	}
	
	DoLog(DEBUG,@"%@",[self.syncDate description]);
	
	return result;
}

- (void) handleTimer1:(BOOL)flag{
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	if(serviceId==nil || [serviceId length]<=0 || [serviceId longLongValue]==0)
		return;
	
	
	//BOOL tmpFlag1=[[NSUserDefaults standardUserDefaults] boolForKey:AUTOSYNC];
	//BOOL tmpFlag2=[[NSUserDefaults standardUserDefaults] boolForKey:BACKUPRUNNING];
	//BOOL tmpFlag3=[[NSUserDefaults standardUserDefaults] boolForKey:RESTORERUNNING];
	BOOL tmpFlag1=[ProfileUtil boolForKey:AUTOSYNCFLAG];
	//BOOL tmpFlag1=NO;
	BOOL tmpFlag2=[ProfileUtil boolForKey:BACKUPRUNNING];
	BOOL tmpFlag3=[ProfileUtil boolForKey:RESTORERUNNING];
	
	NSInteger autoSyncMins=[ProfileUtil integerForKey:AUTORULE];
	
	if(tmpFlag1==YES && autoSyncMins>0){
		tmpFlag1=YES;	
	}else{
		tmpFlag1=NO;
	}
	
	DoLog(DEBUG,@"handleTimer1 auto=%d backup=%d restore=%d sync=%d",tmpFlag1,tmpFlag2,tmpFlag3,syncStatus);
	DoLog(DEBUG,@"queue=%d",[[self.operationQueue operations] count]);
	if(tmpFlag1==YES && tmpFlag2!=YES && tmpFlag2!=YES){
		
		if([self isNextTime]==YES && syncStatus==NO){
			//SyncOperation *syncOperation=[[SyncOperation alloc]init];
			self.syncOperation=[[SyncOperation alloc]init];
			syncOperation.delegate = self;
			[operationQueue addOperation:syncOperation];
			//[syncOperation release];
		
			syncStatus=YES;
		}else if(syncStatus==YES)
			DoLog(DEBUG,@"job is still running");
		else
			DoLog(DEBUG,@"it is not the time"); 
	}
}

//- (void) handleTimer2:(BOOL)flag{
-(void) chkBackupRestore{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	//BOOL tmpFlag1=[[NSUserDefaults standardUserDefaults] boolForKey:BACKUPRUNNING];
	//BOOL tmpFlag2=[[NSUserDefaults standardUserDefaults] boolForKey:RESTORERUNNING];
	BOOL tmpFlag1=[ProfileUtil boolForKey:BACKUPRUNNING];
	BOOL tmpFlag2=[ProfileUtil boolForKey:RESTORERUNNING];
	UIAlertView *alert;
	
	while(tmpFlag1==YES || tmpFlag2==YES){
		
		DoLog(INFO,@"handleTimer2 backup=%d restore=%d sync=%d",tmpFlag1,tmpFlag2,syncStatus);
	
		if(tmpFlag1==YES){
			MySqlite *mySqlite = [[MySqlite alloc]init];
			NSMutableDictionary *backupLog=[mySqlite getLastBackupLog:0];
			BOOL flag;
			
			if(backupLog!=nil && [backupLog objectForKey:@"backupId"]!=nil){
				NSMutableDictionary *resultDictionary=[BackupRestoreUtil getBackupResult:[backupLog objectForKey:@"backupId"]];
				NSMutableArray *bArrays=[resultDictionary objectForKey:@"resultArray"];
				NSMutableString *msg=[[NSMutableString alloc]init];
		
				if(bArrays!=nil){
					if([bArrays count]==1){
						backupLog=[bArrays objectAtIndex:0];
						if([[backupLog objectForKey:@"backupResult"]intValue]>0){
							flag=[mySqlite delBackupLog:[backupLog objectForKey:@"backupId"]];
							if(flag==YES){
								//[[NSUserDefaults standardUserDefaults] setBool:NO forKey: BACKUPRUNNING];
								[ProfileUtil setBool:NO forKey:BACKUPRUNNING];
					
								[msg setString:@"時間："];
								[msg appendString:[DateTimeUtil getStringFromDate:[DateTimeUtil getDateFromString:[backupLog objectForKey:@"backupBgnTime"]] forKind:1]];
					
								if([[backupLog objectForKey:@"backupResult"]intValue]!=1){
									alert = [[UIAlertView alloc]
										 initWithTitle:@"上次備份執行失敗"
										 message:msg
										 delegate:nil
										 cancelButtonTitle:@"確定"
										 otherButtonTitles:nil];
									[alert show];
									[alert release];
								}else{
									alert = [[UIAlertView alloc]
										 initWithTitle:@"上次備份執行成功"
										 message:msg
										 delegate:nil
										 cancelButtonTitle:@"確定"
										 otherButtonTitles:nil];
									[alert show];
									[alert release];
								}
							}else
								DoLog(ERROR,@"can't del backup log");
						}else
							DoLog(ERROR,@"can't get data");
					}
				}else{
					DoLog(DEBUG,@"can't connect server");
				}
				[msg release];
			}else if(backupLog!=nil)//無資料當作已完成
				[ProfileUtil setBool:NO forKey:BACKUPRUNNING];
			
			[mySqlite release];
		}
	
		if(tmpFlag2==YES){
			MySqlite *mySqlite = [[MySqlite alloc]init];
			NSMutableDictionary *restoreLog=[mySqlite getLastRestoreLog:0];
			BOOL flag;
						
			if(restoreLog!=nil && [restoreLog objectForKey:@"restoreId"]!=nil){
				NSMutableDictionary *resultDictionary=[BackupRestoreUtil getRestoreResult:[restoreLog objectForKey:@"restoreId"]];
				NSMutableArray *bArrays=[resultDictionary objectForKey:@"resultArray"];
				
				NSMutableString *msg=[[NSMutableString alloc]init];
				NSInteger result=-1;
				
				if(bArrays!=nil){
					if([bArrays count]==1){
						restoreLog=[bArrays objectAtIndex:0];
						result=[[restoreLog objectForKey:@"restoreResult"]intValue];
						
						if(result>0){
							if(result!=1)
								flag=[mySqlite delRestoreLog:[restoreLog objectForKey:@"restoreId"]];
							else
								flag=[mySqlite updRestoreLog:restoreLog];
							
							if(flag==YES){
								//[[NSUserDefaults standardUserDefaults] setBool:NO forKey: RESTORERUNNING];
								[ProfileUtil setBool:NO forKey:RESTORERUNNING];
				
								[msg setString:@"時間："];
								[msg appendString:[DateTimeUtil getStringFromDate:[DateTimeUtil getDateFromString:[restoreLog objectForKey:@"restoreBgnTime"]] forKind:1]];
					
								if(result!=1){
									alert = [[UIAlertView alloc]
										 initWithTitle:@"上次還原執行失敗"
										 message:msg
										 delegate:nil
										 cancelButtonTitle:@"確定"
										 otherButtonTitles:nil];
									[alert show];
									[alert release];
								}else{
									if(self.syncStatus==NO){
										self.syncOperation=[[SyncOperation alloc]init];
										syncOperation.delegate = self;
										[self.operationQueue addOperation:syncOperation];
										self.syncStatus=YES;
										[[NSUserDefaults standardUserDefaults] setBool:YES forKey: RESTORESYNCFLAG];
							
										[msg appendString:@"\n同步中,請稍候,謝謝"];
									}else
										[msg appendString:@"\n請執行同步作業,將遠端資料下載,謝謝"];
						
									alert = [[UIAlertView alloc]
										 initWithTitle:@"上次備份執行成功"
										 message:msg
										 delegate:nil
										 cancelButtonTitle:@"確定"
										 otherButtonTitles:nil];
									[alert show];
									[alert release];
								}
							}else
								DoLog(ERROR,@"can't use database");
						}else
							DoLog(ERROR,@"can't get data");
					}
				}else{
					DoLog(DEBUG,@"can't connect server");
				}
				[msg release];
			}else if(restoreLog!=nil)//無資料當作已完成
				[ProfileUtil setBool:NO forKey:RESTORERUNNING];
			
			[mySqlite release];
		}
	
		//tmpFlag1=[[NSUserDefaults standardUserDefaults] boolForKey:BACKUPRUNNING];
		//tmpFlag2=[[NSUserDefaults standardUserDefaults] boolForKey:RESTORERUNNING];
		tmpFlag1=[ProfileUtil boolForKey:BACKUPRUNNING];
		tmpFlag2=[ProfileUtil boolForKey:RESTORERUNNING];
		/*
		if(tmpFlag1==NO && tmpFlag2==NO)
			[self.chkTimer invalidate];
		*/
		[NSThread sleepForTimeInterval:2.0f];
	}
		
	[pool release];
}

- (void) doneSyncing:(NSString *)isStop{
	/*0:成功,1:失敗,2:部份失敗,3:認證失敗,4:網路失敗,5:使用者終止*/
	if([isStop intValue]!=0){
		DoLog(DEBUG,@"fail");
		if([isStop intValue]==3 || [isStop intValue]>=6)
			[ProfileUtil setBool:NO forKey:AUTOSYNCFLAG];
	}else
		DoLog(DEBUG,@"success");
	[self.syncOperation release];
	self.syncOperation=nil;
	
	syncStatus=NO;
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:RESTORESYNCFLAG];
	
	NSArray *tmpArray=[self.rootController viewControllers];
	for(UIViewController *viewController in tmpArray){
		//DoLog(DEBUG,@"%@",[viewController description]);
		[viewController viewWillAppear:YES]; 
	}	
}
/*
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    //[viewController viewWillAppear:YES];
}
*/
@end
