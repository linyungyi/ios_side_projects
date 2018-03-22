//
//  LoginViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/4/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "MyCalendarAppDelegate.h"
#import "MySqlite.h"
#import "ProfileUtil.h"
#import "InterfaceUtil.h"
#import "DateTimeUtil.h"
#import "HTTPSHelper.h"
#import "TreeNode.h"
#import "XMLParser.h"
#import "SettingViewController.h"


@implementation LoginViewController
@synthesize idTextField,passTextField,saveSwitch;
@synthesize loginButton,cancelButton,loginActivityIndicator;
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
	
	[NSThread detachNewThreadSelector:@selector(getVersion) toTarget:self withObject:nil];
	
	self.serviceUtil=[[ServiceUtil alloc]init];
	loginActivityIndicator.hidden=YES;
	
	NSString *passWd=[ProfileUtil stringForKey:PASSWD];
	if(passWd==nil || [passWd length]<=0)
		[saveSwitch setOn:NO];
	else 
		passTextField.text=passWd;
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUNDIMG]];
	//self.view.backgroundColor = [UIColor clearColor];
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
	[loginButton release];
	[cancelButton release];
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
	//[self.view resignFirstResponder];
	
	[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:REDIRECTFLAG];
	
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
		
		loginButton.enabled=NO;
		//loginButton.hidden=YES;
		//cancelButton.hidden=YES;
		loginActivityIndicator.hidden=NO;
		[loginActivityIndicator startAnimating];
		//[NSThread detachNewThreadSelector:@selector(sendLoginInfo:) toTarget:self withObject:nil];
		
		NSMutableString *requestXML=[[NSMutableString alloc]init];
		[requestXML setString:@"xml=<auth_login_req>"];
		[requestXML appendString:[NSString stringWithFormat:@"<service_type>%@</service_type>",SERVICETYPE]];
		[requestXML appendString:[NSString stringWithFormat:@"<account>%@</account>",self.idTextField.text]];
		[requestXML appendString:[NSString stringWithFormat:@"<password>%@</password>",self.passTextField.text]];
		[requestXML appendString:@"</auth_login_req>"];
		DoLog(INFO,@"requestXML=%@",requestXML);
		
		[HTTPSHelper sharedInstance].delegate = self;
		[HTTPSHelper sharedInstance].requestXML=requestXML;
		[HTTPSHelper go:[NSString stringWithFormat:@"%@?%@",LOGINURL,[DateTimeUtil getUrlDateString]]];
		//[HTTPSHelper go:LOGINURL];
		 
		[requestXML release];
		
	}
}

-(IBAction) doCancel:(id)sender{
	DoLog(DEBUG,@"cancel");
	[HTTPSHelper cancel];
	MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
	[self.view removeFromSuperview];
	[myApp.window addSubview:myApp.rootController.view];
}

-(IBAction) doSwitch:(id)sender{
	DoLog(DEBUG,@"%d",[sender isOn]);
	
	if([sender isOn]==NO){
		NSString *passWd=[ProfileUtil stringForKey:PASSWD];
		if(passWd!=nil)
			[ProfileUtil setString:@"" forKey:PASSWD];
	}
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
	//loginButton.hidden=NO;
	loginButton.enabled=YES;
	//cancelButton.hidden=NO;
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
		
		//resultCode=6;
		
		if(resultCode==0 || (resultCode==3 && ([ProfileUtil stringForKey:SESSIONID]!=nil && [[ProfileUtil stringForKey:SESSIONID] length]>0)) ){
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
			DoLog(INFO,@"serviceId=%@",serviceId);
			if(serviceId==nil || [serviceId length]<=0 || [serviceId longLongValue]==0){
				[NSThread detachNewThreadSelector:@selector(doProvision) toTarget:self withObject:nil];
				
			}
			
			MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
			[self.view removeFromSuperview];
			[myApp.window addSubview:myApp.rootController.view];
		}else if(resultCode>=6){
			if(resultCode!=6)
				[serviceUtil chkResultCode:resultCode];
			
			MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
			[self.view removeFromSuperview];
			[myApp.window addSubview:myApp.rootController.view];
			
			if(resultCode==6){
				[[NSUserDefaults standardUserDefaults] setObject:@"SERVICEDESCRIPTION" forKey:REDIRECTFLAG];
				myApp.rootController.selectedIndex=2;
				
				NSArray *tmpArray=[myApp.rootController viewControllers];
				for(UIViewController *viewController in tmpArray){
					if([viewController isKindOfClass:[SettingViewController class]]==YES)
						[viewController viewWillAppear:YES];
				}
			}
		}else{
			
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
	//loginButton.hidden=NO;
	loginButton.enabled=YES;
	//cancelButton.hidden=NO;
}

-(void) doProvision{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	
	DoLog(INFO,@"provision");
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
	loginButton.hidden=NO;
	cancelButton.hidden=NO;
	
	if(resultCode==0){
		
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
		
		MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
		[self.view removeFromSuperview];
		[myApp.window addSubview:myApp.rootController.view];
	}else if(resultCode>=6){
		[serviceUtil chkResultCode:resultCode];
		
		MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
		[self.view removeFromSuperview];
		[myApp.window addSubview:myApp.rootController.view];
		
	}else{
		
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
/*
 - (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
 {	
 DoLog(DEBUG,@"actionSheet=%d %d",buttonIndex,[actionSheet cancelButtonIndex]);
 if (buttonIndex != [actionSheet cancelButtonIndex])
 {
 if(buttonIndex==0){
 NSString *descUrl;
 
 if([versionInfo objectForKey:@"descUrl1"]!=nil)
 descUrl=[versionInfo objectForKey:@"descUrl1"];
 else if([versionInfo objectForKey:@"descUrl2"]!=nil)
 descUrl=[versionInfo objectForKey:@"descUrl2"];			
 else if([versionInfo objectForKey:@"descUrl3"]!=nil)
 descUrl=[versionInfo objectForKey:@"descUrl3"];
 
 NSURL *myURL = [NSURL URLWithString:descUrl];
 [[UIApplication sharedApplication] openURL:myURL];
 }
 }
 
 }
 */

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	DoLog(DEBUG,@"click index number is =%d",buttonIndex);
	if (buttonIndex == 1){
		MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
		
		if(myApp.versionInfo!=nil){
			NSString *descUrl;
			if([myApp.versionInfo objectForKey:@"descUrl1"]!=nil)
				descUrl=[myApp.versionInfo objectForKey:@"descUrl1"];
			else if([myApp.versionInfo objectForKey:@"descUrl2"]!=nil)
				descUrl=[myApp.versionInfo objectForKey:@"descUrl2"];			
			else if([myApp.versionInfo objectForKey:@"descUrl3"]!=nil)
				descUrl=[myApp.versionInfo objectForKey:@"descUrl3"];
		
			NSURL *myURL = [NSURL URLWithString:descUrl];
			[[UIApplication sharedApplication] openURL:myURL];
		}
	}
	
}

-(void) getVersion{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableDictionary *versionInfo=[InterfaceUtil getVersion];
	
	if(versionInfo!=nil){
		NSString *versionNumber=[versionInfo objectForKey:@"newVersion"];
		NSString *msg;
		
		if(versionNumber!=nil && [versionNumber floatValue]>[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue]){
			NSString *enforceUpdate=[versionInfo objectForKey:@"enforceUpdate"];
			NSString *descUrl=nil;
			UIAlertView *alert;
			
			if([versionInfo objectForKey:@"descUrl1"]!=nil)
				descUrl=[versionInfo objectForKey:@"descUrl1"];
			else if([versionInfo objectForKey:@"descUrl2"]!=nil)
				descUrl=[versionInfo objectForKey:@"descUrl2"];			
			else if([versionInfo objectForKey:@"descUrl3"]!=nil)
				descUrl=[versionInfo objectForKey:@"descUrl3"];
			
			if(enforceUpdate!=nil && [enforceUpdate compare:@"Y"]==YES){
				
				NSDate *expireDate=[DateTimeUtil getDateFromString:[versionInfo objectForKey:@"currentExpireTime"]];
				NSDate *now=[NSDate date];
				
				if([now compare:expireDate]!=NSOrderedAscending){
					
					NSURL *myURL = [NSURL URLWithString:descUrl];
					[[UIApplication sharedApplication] openURL:myURL];
				}else{
					
					msg=[NSString stringWithFormat:@"%@後不支援此版本,請盡速更新,謝謝",[DateTimeUtil getStringFromDate:expireDate forKind:1]];
					alert = [[UIAlertView alloc]
							 initWithTitle:@"版本更新"
							 message:msg
							 delegate:self
							 cancelButtonTitle:@"取消"
							 otherButtonTitles:@"前往更新網址"];
					[alert show];
					[alert release];
				}
			}else{
				
				msg=[NSString stringWithFormat:@"目前版本:%@ 新版本:%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],versionNumber];
				alert = [[UIAlertView alloc]
						 initWithTitle:@"版本更新"
						 message:msg
						 delegate:self
						 cancelButtonTitle:@"取消"
						 otherButtonTitles:@"前往更新網址"];
				[alert show];
				[alert release];
			}
		}
		MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication]delegate];
		myApp.versionInfo=versionInfo;
		//[versionInfo release];
	}else{
		DoLog(ERROR,@"can't get version info");
	}
	
	
	[pool release];
}

@end
