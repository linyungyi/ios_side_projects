//
//  ServiceUtil.m
//  MyCalendar
//
//  Created by Admin on 2010/4/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ServiceUtil.h"
#import "MyCalendarAppDelegate.h"
#import "MySqlite.h"
#import "ProfileUtil.h"
#import "InterfaceUtil.h"

@implementation ServiceUtil
@synthesize stateFlag,jobFlag,resultFlag;
//@synthesize myDelegate;
//@synthesize syncView,myProgressView;
@synthesize syncOperation;

-(BOOL) chkResultCode:(NSInteger) resultCode{
	BOOL flag=YES;
	UIAlertView *alert;
	
	if(resultCode==3 || resultCode>=6)
		[ProfileUtil setBool:NO forKey:AUTOSYNCFLAG];
	
	if(resultCode==6){
		stateFlag=6;
		alert = [[UIAlertView alloc]
				 initWithTitle:@"未申裝服務"
				 message:@"是否前往申裝服務網頁"
				 delegate:self
				 cancelButtonTitle:@"否"
				 otherButtonTitles:@"是",nil];
		[alert show];
		[alert release];
	}else if(resultCode==7){
		MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
		[[[myApp.window subviews] objectAtIndex:0] removeFromSuperview];
		[myApp.window addSubview:[myApp.loginController view]];
	}else if(resultCode==8 || resultCode==10){
		stateFlag=resultCode;
		alert = [[UIAlertView alloc]
				 initWithTitle:@"非現行同步手機"
				 message:@"是否改以此手譏為主"
				 delegate:self
				 cancelButtonTitle:@"否"
				 otherButtonTitles:@"是",nil];
		[alert show];
		[alert release];
	}else if(resultCode==9){
		MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
		NSDictionary *versionInfo=myApp.versionInfo;
		NSString *descUrl;
		if(versionInfo!=nil){
			if([versionInfo objectForKey:@"descUrl1"]!=nil)
				descUrl=[versionInfo objectForKey:@"descUrl1"];
			else if([versionInfo objectForKey:@"descUrl2"]!=nil)
				descUrl=[versionInfo objectForKey:@"descUrl2"];			
			else if([versionInfo objectForKey:@"descUrl3"]!=nil)
				descUrl=[versionInfo objectForKey:@"descUrl3"];
		
			NSURL *myURL = [NSURL URLWithString:descUrl];
			[[UIApplication sharedApplication] openURL:myURL];
		}else{
			alert = [[UIAlertView alloc]
					 initWithTitle:@"需更新版本"
					 message:@"此版本已不支援"
					 delegate:nil
					 cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}else if(resultCode==100){
		MySqlite *mySqlite=[[MySqlite alloc]init];
		[mySqlite delEverything];
		[mySqlite release];
		DoLog(INFO,@"delete everything");
	}	
	
	return flag;
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(stateFlag==6){
		if (buttonIndex == 1){
			NSURL *myURL = [NSURL URLWithString:APPLYURL];
			[[UIApplication sharedApplication] openURL:myURL];
		}else{//取消
			DoLog(DEBUG,@"cancel");
		}
	}else if(stateFlag==8 || stateFlag==10){
		if (buttonIndex == 1){
			DoLog(DEBUG,@"doProvision");
			[NSThread detachNewThreadSelector:@selector(doProvision:) toTarget:self withObject:@"true"];
		}else{//取消
			DoLog(DEBUG,@"cancel");
		}
	}else
		DoLog(ERROR,@"state=%d",stateFlag);
}


-(void) doProvision:(NSString *)p{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	NSDictionary *result=nil;
	result=[InterfaceUtil doProvision:p];

	DoLog(DEBUG,@"result= %@",result);
	
	if([result objectForKey:@"resultCode"]!=nil && [[result objectForKey:@"resultCode"]intValue]==0){
		
		if([p compare:@"true"]==YES){
			BOOL flag=NO;
			[[NSUserDefaults standardUserDefaults] setObject:[ProfileUtil stringForKey:SESSIONID] forKey:SESSIONID];
			[[NSUserDefaults standardUserDefaults] setObject:[ProfileUtil stringForKey:AUTHID] forKey:AUTHID];
			
			MySqlite *mySqlite=[[MySqlite alloc]init];
			
			if(stateFlag==8)
				flag=[mySqlite delEverything];
			else 
				flag=[mySqlite resetEverything];

			[mySqlite release];
			
			if(flag==YES){
				[ProfileUtil setString:[[NSUserDefaults standardUserDefaults] stringForKey:SESSIONID] forKey:SESSIONID];
				[ProfileUtil setString:[[NSUserDefaults standardUserDefaults] stringForKey:AUTHID] forKey:AUTHID];
			}else{
				[[NSUserDefaults standardUserDefaults] setObject:nil forKey:SESSIONID];
				[[NSUserDefaults standardUserDefaults] setObject:nil forKey:AUTHID];
			}
		}
		
		[ProfileUtil setString:[result objectForKey:@"serviceId"] forKey:SERVICEID];
		[ProfileUtil setInteger:[[result objectForKey:@"maxSyncAmount"] intValue] forKey:MAXSYNCAMOUNT];
		[ProfileUtil setBool:YES forKey:AUTOSYNCFLAG];
		
		//self.syncView=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
		//self.myProgressView=[[UIProgressView alloc]init];
		//self.myProgressView.progress=0.0;
		
		MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
		myApp.syncStatus=YES;
		
		/*
		[[[myApp.window subviews] objectAtIndex:1] addSubview:syncView];
		
		for(UIView *myView in [myApp.window subviews])
			DoLog(INFO,@"%@",myView);
		*/
		
		self.syncOperation=[[SyncOperation alloc]init];
		syncOperation.delegate = self;
		[myApp.operationQueue addOperation:syncOperation];		
		
	}else{
		UIAlertView *alert = [[UIAlertView alloc]
				 initWithTitle:@"失敗"
				 message:nil
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	[pool release];
}

- (void)dealloc {
	//[myDelegate release];
	[syncOperation release];
	//[myProgressView release];
	//[syncView release];
    [super dealloc];
}


- (void) doneSyncing:(NSString *)isStop{
	MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
	myApp.syncStatus=NO;
	
	//[self.syncView removeFromSuperview];
	//[self.myProgressView release];
	//[self.syncView release];
	
	NSArray *tmpArray=[myApp.rootController viewControllers];
	for(UIViewController *viewController in tmpArray){
		//DoLog(DEBUG,@"%@",[viewController description]);
		[viewController viewWillAppear:YES]; 
	}
	
	if([isStop intValue]!=0){
		DoLog(DEBUG,@"fail");
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"同步失敗"
							  message:nil
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else{
		DoLog(DEBUG,@"success");
		
	}
	
	[self.syncOperation release];
	self.syncOperation=nil;
}

-(void) setProgress:(NSString *)p{
	//[NSThread detachNewThreadSelector:@selector(updProcess:) toTarget:self withObject:p];
}
/*
-(void) updProcess:(NSString *)p{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	self.myProgressView.progress=([p floatValue]/10);
	[pool release];
}
*/

@end
