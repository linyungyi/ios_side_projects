//
//  UserInfoViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/4/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserInfoViewController.h"
#import "MyCalendarAppDelegate.h"
#import "MySqlite.h"
#import "ProfileUtil.h"
#import "InterfaceUtil.h"
#import "DateTimeUtil.h"
#import "HTTPSHelper.h"
#import "TreeNode.h"
#import "XMLParser.h"

@implementation UserInfoViewController

@synthesize idTextField,passTextField,saveSwitch;
@synthesize loginButton,loginActivityIndicator,myProgressView;
@synthesize changeButton,delButton,serviceLabel,defaultView,webView,applyButton,applyLabel;
@synthesize syncOperation,serviceUtil;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	 // Custom initialization
	 //self.view=self.defaultView;
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
	self.serviceUtil=[[ServiceUtil alloc]init];
	
	loginActivityIndicator.hidden=YES;
	myProgressView.hidden=YES;
	
	changeButton.hidden=YES;
	serviceLabel.hidden=YES;
	delButton.hidden=YES;
	
	NSString *passWd=[ProfileUtil stringForKey:PASSWD];
	if(passWd==nil || [passWd length]<=0)
		[saveSwitch setOn:NO];
	else 
		passTextField.text=passWd;
	
	//self.serviceLabel.font=[UIFont systemFontOfSize:11];
	self.serviceLabel.text=@"刪除帳號後手機上我的行事曆資料與設定將被刪除。但是，已同步或備份於伺服器上的行事曆資料將被保留。";
	//self.serviceLabel.numberOfLines = 5;
	//self.serviceLabel.lineBreakMode = UILineBreakModeWordWrap;
	
	self.applyLabel.text=@"我的行事曆提供您手機與伺服器的行事曆資料同步、備份與還原。\n\n您尚未申租本服務，請按「前往申租」立即申租本服務。\n\n\n\n\n\n";
	
	self.defaultView=self.view;
	
	//self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"calendar_bg.png"]];
	self.view.backgroundColor = [UIColor clearColor];
	self.webView.backgroundColor = [UIColor clearColor];
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
	[serviceUtil release];
	[myProgressView release];
	[syncOperation release];
	[applyLabel release];
	[applyButton release];
	[webView release];
	[defaultView release];
	[serviceLabel release];
	[delButton release];
	[changeButton release];
	[loginButton release];
	[loginActivityIndicator release];
	[idTextField release];
	[passTextField release];
	[saveSwitch release];
    [super dealloc];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}


-(IBAction) doLogin:(id)sender{
	DoLog(DEBUG,@"login %@ %@ %d",idTextField.text,passTextField.text,saveSwitch.isOn);
	
	if([idTextField.text length]<=0 || [passTextField.text length]<=0){
		NSString *msg=nil;
		if([idTextField.text length]>0 && [passTextField.text length]<=0)
			msg=@"密碼未填";
		else if([idTextField.text length]<=0 && [passTextField.text length]>0)
			msg=@"帳號未填";
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"請輸入帳號與密碼"
							  message:msg
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else{
		if([saveSwitch isOn]==YES)
			[ProfileUtil setString:self.passTextField.text forKey:PASSWD];
		
		loginButton.hidden=YES;
		loginActivityIndicator.hidden=NO;
		[loginActivityIndicator startAnimating];
		//[NSThread detachNewThreadSelector:@selector(sendLoginInfo:) toTarget:self withObject:nil];
		
		NSMutableString *requestXML=[[NSMutableString alloc]init];
		[requestXML setString:@"xml=<auth_login_req>"];
		[requestXML appendString:[NSString stringWithFormat:@"<service_type>%@</service_type>",SERVICETYPE]];
		[requestXML appendString:[NSString stringWithFormat:@"<account>%@</account>",self.idTextField.text]];
		[requestXML appendString:[NSString stringWithFormat:@"<password>%@</password>",self.passTextField.text]];
		[requestXML appendString:@"</auth_login_req>"];
		DoLog(DEBUG,@"requestXML=%@",requestXML);
		
		[HTTPSHelper cancel];
		[HTTPSHelper sharedInstance].delegate = self;
		[HTTPSHelper sharedInstance].requestXML=requestXML;
		[HTTPSHelper go:[NSString stringWithFormat:@"%@?%@",LOGINURL,[DateTimeUtil getUrlDateString]]];
		[requestXML release];		
	}
}

-(IBAction) doChange:(id)sender{
	DoLog(INFO,@"change");
	
	if([idTextField.text length]<=0 || [passTextField.text length]<=0){
		NSString *msg=nil;
		if([idTextField.text length]>0 && [passTextField.text length]<=0)
			msg=@"密碼未填";
		else if([idTextField.text length]<=0 && [passTextField.text length]>0)
			msg=@"帳號未填";
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"請輸入帳號與密碼"
							  message:msg
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else{
		changeButton.hidden=YES;
		delButton.hidden=YES;
		loginActivityIndicator.hidden=NO;
		[loginActivityIndicator startAnimating];
		[NSThread detachNewThreadSelector:@selector(sendChangeCommand:) toTarget:self withObject:nil];
	}
}

-(IBAction) doDel:(id)sender{
	DoLog(DEBUG,@"del");
	
	UIAlertView *alert;
	
	
	
	if([idTextField.text length]<=0 || [passTextField.text length]<=0){
		NSString *msg=nil;
		if([idTextField.text length]>0 && [passTextField.text length]<=0)
			msg=@"密碼未填";
		else if([idTextField.text length]<=0 && [passTextField.text length]>0)
			msg=@"帳號未填";
		
		alert = [[UIAlertView alloc]
							  initWithTitle:@"請輸入帳號與密碼"
							  message:msg
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else{
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:@"請選擇是否要先進行同步作業"
									  delegate:self
									  cancelButtonTitle:@"取消"
									  destructiveButtonTitle:@"直接進行刪除動作"
									  otherButtonTitles:@"先執行同步",
									  nil];
		[actionSheet showInView:self.view];
		[actionSheet release];
	}
}

-(IBAction) doSwitch:(id)sender{
	DoLog(DEBUG,@"%d",[sender isOn]);
	
	if([sender isOn]==NO){
		NSString *passWd=[ProfileUtil stringForKey:PASSWD];
		if(passWd!=nil)
			[ProfileUtil setString:@"" forKey:PASSWD];
	}else{
		if(passTextField.text!=nil && [passTextField.text length]>0)
			[ProfileUtil setString:passTextField.text forKey:PASSWD];
	}
}

-(IBAction) doApply:(id)sender{
	NSURL *myURL = [NSURL URLWithString:APPLYURL];
	[[UIApplication sharedApplication] openURL:myURL];
}

- (void) dataReceiveAtPercent: (NSNumber *) aPercent
{
	DoLog(INFO,@"%@",aPercent);
}

- (void) dataReceiveFailed: (NSError *) reason
{
	if (reason) DoLog(ERROR,@"Download failed: %@", reason);
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"登入失敗,請稍候再試,謝謝"
						  message:nil
						  delegate:nil
						  cancelButtonTitle:@"確定"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
	[loginActivityIndicator stopAnimating];
	loginActivityIndicator.hidden=YES;
	loginButton.hidden=NO;
}

- (void) didReceiveData: (NSMutableDictionary *) theData
{
	NSInteger statusCode = -1;
	
	if(theData!=nil && [theData objectForKey:@"returnCode"]!=nil)
		statusCode=[[theData objectForKey:@"returnCode"]intValue];
	
	DoLog(INFO,@"statusCode=%d",statusCode);
	
	UIAlertView *alert;
	if(statusCode==200 && [theData objectForKey:@"returnData"]!=nil){
		TreeNode *root=nil;
		
		
		DoLog(INFO,@"responseXML=%@",[[[NSString alloc] initWithData:[theData objectForKey:@"returnData"] encoding:NSUTF8StringEncoding]autorelease]);
		root = [[XMLParser sharedInstance] parseXMLFromData:[theData objectForKey:@"returnData"]];	
		
		NSInteger resultCode=-1;
		
		if(root!=nil && [root leafForKey:@"result"]!=nil)
			resultCode=[[root leafForKey:@"result"]intValue];
		
		if(resultCode==0 || (resultCode==3 && ([ProfileUtil stringForKey:SESSIONID]!=nil && [[ProfileUtil stringForKey:SESSIONID] length]>0)) ){
			changeButton.hidden=NO;
			delButton.hidden=NO;
			serviceLabel.hidden=NO;
			
			NSString *sessionId=[theData objectForKey:@"Authorizationid"];
			
			DoLog(INFO,@"sessionId=%@",sessionId);
			if(sessionId!=nil && [sessionId length]>0){
				[ProfileUtil setString:sessionId forKey:SESSIONID];
				[ProfileUtil setString:idTextField.text forKey:AUTHID];
				
				if([ProfileUtil integerForKey:AUTORULE]>0)
					[ProfileUtil setBool:YES forKey:AUTOSYNCFLAG];
				else 
					[ProfileUtil setBool:NO forKey:AUTOSYNCFLAG];
				
			}
			
			NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
			
			if(serviceId==nil || [serviceId length]<=0 || [serviceId longLongValue]==0){
				[NSThread detachNewThreadSelector:@selector(doProvision) toTarget:self withObject:nil];
				
				/*
				NSDictionary *result=[InterfaceUtil doProvision:@"false"];
				if([result objectForKey:@"resultCode"]!=nil && [[result objectForKey:@"resultCode"]intValue]==0){
					[ProfileUtil setString:[result objectForKey:@"serviceId"] forKey:SERVICEID];
					[ProfileUtil setInteger:[[result objectForKey:@"maxSyncAmount"] intValue] forKey:MAXSYNCAMOUNT];
				}else{
					NSString *msg=nil;
					
					if([result objectForKey:@"resultCode"]!=nil){
						if([[result objectForKey:@"resultCode"] intValue]>=6)
							[serviceUtil chkResultCode:[[result objectForKey:@"resultCode"] intValue]];
						else
							msg=@"伺服器錯誤";
					}else
						msg=@"網路或伺服器錯誤";
					
					if(msg!=nil){
						UIAlertView *alert = [[UIAlertView alloc]
											  initWithTitle:@"失敗"
											  message:msg
											  delegate:nil
											  cancelButtonTitle:@"確定"
											  otherButtonTitles:nil];
						[alert show];
						[alert release];
					}
				}
				*/
			}
		}else if(resultCode==6){
			self.view=self.webView;
			loginButton.hidden=NO;
		}else if(resultCode>=7){
			[serviceUtil chkResultCode:resultCode];
			loginButton.hidden=NO;
		}else{
			loginButton.hidden=NO;
			
			NSString *msg=nil;
			switch (resultCode) {
				case 3:
					msg=@"帳號密碼錯誤";
					break;
				default:
					msg=@"";
					break;
			}
			
			alert = [[UIAlertView alloc]
					 initWithTitle:@"登入失敗,請稍候再試,謝謝"
					 message:msg
					 delegate:nil
					 cancelButtonTitle:@"確定"
					 otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}else{
		alert = [[UIAlertView alloc]
				 initWithTitle:@"登入失敗,請稍候再試,謝謝"
				 message:@"網路或伺服器問題"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	[theData release];
	
	[loginActivityIndicator stopAnimating];
	loginActivityIndicator.hidden=YES;
}

-(void) doProvision{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	
	NSDictionary *result=[InterfaceUtil doProvision:@"false"];
	if([result objectForKey:@"resultCode"]!=nil && [[result objectForKey:@"resultCode"]intValue]==0){
		[ProfileUtil setString:[result objectForKey:@"serviceId"] forKey:SERVICEID];
		[ProfileUtil setInteger:[[result objectForKey:@"maxSyncAmount"] intValue] forKey:MAXSYNCAMOUNT];
	}else{
		NSString *msg=nil;
		
		if([result objectForKey:@"resultCode"]!=nil){
			if([[result objectForKey:@"resultCode"] intValue]>=6)
				[serviceUtil chkResultCode:[[result objectForKey:@"resultCode"] intValue]];
			else
				msg=@"伺服器錯誤";
		}else
			msg=@"網路或伺服器錯誤";
		
		if(msg!=nil){
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"失敗"
								  message:msg
								  delegate:nil
								  cancelButtonTitle:@"確定"
								  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}	
	
	[pool release];
}

/*
-(void) sendLoginInfo:(NSDictionary *)userInfo{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSInteger resultCode=0;
	resultCode=[InterfaceUtil doLogin:idTextField.text passWd:passTextField.text];
	
	
	[loginActivityIndicator stopAnimating];
	loginActivityIndicator.hidden=YES;
	
	
	if(resultCode==0){
		changeButton.hidden=NO;
		delButton.hidden=NO;
		serviceLabel.hidden=NO;
		
		NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
		
		if(serviceId==nil || [serviceId length]<=0 || [serviceId longLongValue]==0){
			NSDictionary *result=[InterfaceUtil doProvision:@"false"];
			if([result objectForKey:@"resultCode"]!=nil && [[result objectForKey:@"resultCode"]intValue]==0){
				[ProfileUtil setString:[result objectForKey:@"serviceId"] forKey:SERVICEID];
				[ProfileUtil setInteger:[[result objectForKey:@"maxSyncAmount"] intValue] forKey:MAXSYNCAMOUNT];
			}else{
				NSString *msg=nil;
		 
				if([result objectForKey:@"resultCode"]!=nil){
					if([[result objectForKey:@"resultCode"] intValue]>=6)
						[serviceUtil chkResultCode:[[result objectForKey:@"resultCode"] intValue]];
					else
						msg=@"伺服器錯誤";
				}else
					msg=@"網路或伺服器錯誤";
		 
				if(msg!=nil){
				UIAlertView *alert = [[UIAlertView alloc]
					initWithTitle:@"失敗"
					message:msg
					delegate:nil
					cancelButtonTitle:@"確定"
					otherButtonTitles:nil];
					[alert show];
					[alert release];
				}
			}
		}
		
	}else if(resultCode==6){
		self.view=self.webView;
		loginButton.hidden=NO;
	}else if(resultCode>=7){
		[serviceUtil chkResultCode:resultCode];
		loginButton.hidden=NO;
	}else{
		loginButton.hidden=NO;
		NSString *msg=nil;
		switch (resultCode) {
			case -1:
				msg=@"網路或伺服器問題";
				break;
			case 3:
				msg=@"帳號密碼錯誤";
				break;
			default:
				msg=@"";
				break;
		}
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"登入失敗,請稍候再試,謝謝"
							  message:msg
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		
	}
	
	[pool release];
}
*/
-(void) sendChangeCommand:(NSDictionary *)userInfo{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSInteger resultCode=0;
	//resultCode=[InterfaceUtil doLogin:idTextField.text passWd:passTextField.text];
	
	/*
	for(int i=0;i<3;i++){
		//DoLog(DEBUG,@"%d",i);
		[NSThread sleepForTimeInterval:1.0f];
	}
	 */
	
	[loginActivityIndicator stopAnimating];
	loginActivityIndicator.hidden=YES;
	changeButton.hidden=NO;
	delButton.hidden=NO;
	
	if(resultCode==0){
		if([saveSwitch isOn]==YES)
			[ProfileUtil setString:self.passTextField.text forKey:PASSWD];
	}else{
		NSString *msg=nil;
		switch (resultCode) {
			case 1:
				msg=@"1";
				break;
			default:
				break;
		}
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"修改失敗,請稍候再試,謝謝"
							  message:msg
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[pool release];
}


-(void) sendDelCommand:(NSDictionary *)userInfo{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSInteger resultCode=0;
	//resultCode=[InterfaceUtil doLogin:idTextField.text passWd:passTextField.text];
	
	/*
	for(int i=0;i<3;i++){
		DoLog(DEBUG,@"dddd hh %d",i);
		[NSThread sleepForTimeInterval:1.0f];
	}
	*/
	
	[loginActivityIndicator stopAnimating];
	loginActivityIndicator.hidden=YES;
	delButton.hidden=NO;
	changeButton.hidden=NO;
	
	//DoLog(DEBUG,@"%d %d",resultCode,(resultCode==0));
	if(resultCode==0){
		
		
		BOOL flag=NO;
		[[NSUserDefaults standardUserDefaults] setObject:[ProfileUtil stringForKey:SESSIONID] forKey:SESSIONID];
		[[NSUserDefaults standardUserDefaults] setObject:[ProfileUtil stringForKey:AUTHID] forKey:AUTHID];
		
		MySqlite *mySqlite=[[MySqlite alloc]init];
		flag=[mySqlite delEverything];
		if(flag==YES)
			[mySqlite insDefaultCategory];
		[mySqlite release];
		
		if(flag==YES){
			[ProfileUtil setString:[[NSUserDefaults standardUserDefaults] stringForKey:SESSIONID] forKey:SESSIONID];
			[ProfileUtil setString:[[NSUserDefaults standardUserDefaults] stringForKey:AUTHID] forKey:AUTHID];
		}else{
			[[NSUserDefaults standardUserDefaults] setObject:nil forKey:SESSIONID];
			[[NSUserDefaults standardUserDefaults] setObject:nil forKey:AUTHID];
		}
		
		self.idTextField.text=@"";
		self.passTextField.text=@"";
		
		//[ProfileUtil setString:@"" forKey:PASSWD];
		//self.view=self.webView;
	}else{
		DoLog(INFO,@"error");
		
		NSString *msg=nil;
		switch (resultCode) {
			case 1:
				msg=@"1";
				break;
			default:
				break;
		}
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"刪除失敗,請稍候再試,謝謝"
							  message:msg
							  delegate:nil
							  cancelButtonTitle:@"確定"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[pool release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
	DoLog(DEBUG,@"actionSheet=%d %d",buttonIndex,[actionSheet cancelButtonIndex]);
	if (buttonIndex != [actionSheet cancelButtonIndex])
	{
		
		if(buttonIndex==0){//直接刪除
			changeButton.hidden=YES;
			delButton.hidden=YES;
			loginActivityIndicator.hidden=NO;
			[loginActivityIndicator startAnimating];
			[NSThread detachNewThreadSelector:@selector(sendDelCommand:) toTarget:self withObject:nil];
		}else if(buttonIndex==1){//先同步再刪除
			UIAlertView *alert;
			MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
			
			BOOL tmpFlag1=[ProfileUtil boolForKey:BACKUPRUNNING];
			BOOL tmpFlag2=[ProfileUtil boolForKey:RESTORERUNNING];
			
			if(tmpFlag1!=YES && tmpFlag2!=YES && myApp.syncStatus==NO){
				myApp.syncStatus=YES;
				
				changeButton.hidden=YES;
				delButton.hidden=YES;
				loginActivityIndicator.hidden=NO;
				[loginActivityIndicator startAnimating];
				
				self.syncOperation=[[SyncOperation alloc]init];
				syncOperation.delegate = self;
				[myApp.operationQueue addOperation:syncOperation];
				myProgressView.hidden=NO;
					
			}else if(tmpFlag1==YES || tmpFlag2==YES){
				NSString *msg=nil;
				if(tmpFlag1==YES)
					msg=@"備份中";
				else
					msg=@"還原中";
				

				alert = [[UIAlertView alloc]
									  initWithTitle:@"備份/還原中,無法進行同步,請稍候再試,謝謝"
									  message:msg
									  delegate:nil
									  cancelButtonTitle:@"確定"
									  otherButtonTitles:nil];
				[alert show];
				[alert release];
			}else{
				alert = [[UIAlertView alloc]
									  initWithTitle:@"自動同步中,無法進行同步,請稍候再試,謝謝"
									  message:nil
									  delegate:nil
									  cancelButtonTitle:@"確定"
									  otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
		}
	}else{
		[loginActivityIndicator stopAnimating];
		loginActivityIndicator.hidden=YES;
		delButton.hidden=NO;
		changeButton.hidden=NO;
	}
	
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
		if (buttonIndex == 1){
		
		}else{//取消
			
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
	
	myProgressView.hidden=YES;
	if([isStop intValue]!=0){
		DoLog(DEBUG,@"fail");
		UIActionSheet *actionSheet = [[UIActionSheet alloc]
									  initWithTitle:@"同步失敗,是否繼續刪除動作"
									  delegate:self
									  cancelButtonTitle:@"取消"
									  destructiveButtonTitle:@"是"
									  otherButtonTitles:nil,
									  nil];
		[actionSheet showInView:self.view];
		[actionSheet release];
	}else{
		DoLog(DEBUG,@"success");
		
		UIAlertView *alert = [[UIAlertView alloc]
				 initWithTitle:@"同步成功"
				 message:@"執行刪除帳號中,請稍候,謝謝"
				 delegate:nil
				 cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		//changeButton.hidden=YES;
		//delButton.hidden=YES;
		//loginActivityIndicator.hidden=NO;
		//[loginActivityIndicator startAnimating];
		[NSThread detachNewThreadSelector:@selector(sendDelCommand:) toTarget:self withObject:nil];
	}
	
	[self.syncOperation release];
	self.syncOperation=nil;
}

-(void) setProgress:(NSString *)p{
	[NSThread detachNewThreadSelector:@selector(updProcess:) toTarget:self withObject:p];
}

-(void) updProcess:(NSString *)p{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	self.myProgressView.progress=([p floatValue]/10);
	[pool release];
}

@end
