//
//  InterfaceUtil.m
//  MyCalendar
//
//  Created by Admin on 2010/4/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InterfaceUtil.h"
#import "MySqlite.h"
#import "DateTimeUtil.h"
#import "XMLParser.h"
#import "TreeNode.h"
#import "ProfileUtil.h"

@implementation InterfaceUtil
/*
 0成功
 1格式錯誤
 2資料庫錯誤
 3認證失敗
 4程式錯誤
 5其他錯誤
*/

+(NSInteger) doLogin:(NSString *)userId passWd:(NSString *) passWd{
	
	NSMutableString *requestXML=[[NSMutableString alloc]init];
	[requestXML setString:[NSString stringWithFormat:@"%@?%@",LOGINURL,[DateTimeUtil getUrlDateString]]];
	NSURL *loginUrl = [NSURL URLWithString:requestXML];
	NSMutableURLRequest *postRequest;
	NSData *data;
	
	NSHTTPURLResponse *returnResponse;
	NSError *returnError;
	int statusCode,resultCode;
	
	
	TreeNode *root;		
	
	/*執行要求*/
	//adding header information:
	postRequest = [NSMutableURLRequest requestWithURL:loginUrl];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	
	
	[requestXML setString:@"xml=<auth_login_req>"];
	[requestXML appendString:[NSString stringWithFormat:@"<service_type>%@</service_type>",SERVICETYPE]];
	[requestXML appendString:[NSString stringWithFormat:@"<account>%@</account>",userId]];
	[requestXML appendString:[NSString stringWithFormat:@"<password>%@</password>",passWd]];
	[requestXML appendString:@"</auth_login_req>"];
	DoLog(DEBUG,@"requestXML=%@",requestXML);
	
	data = [[NSData alloc] initWithData:[requestXML dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:data];
	[data release];
	
	
	returnResponse = nil;
	returnError = nil;
	data = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
	statusCode = returnResponse.statusCode;
	DoLog(DEBUG,@"statusCode=%d",statusCode);
	
	if(statusCode==200){
		
		DoLog(DEBUG,@"responseXML=%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease]);
		root = [[XMLParser sharedInstance] parseXMLFromData:data];	
		
		resultCode=[[root leafForKey:@"result"]intValue];
		if(resultCode==0){
			NSDictionary *header=[returnResponse allHeaderFields];
			NSString *sessionId=[header objectForKey:@"AuthorizationId"];
			if(sessionId!=nil && [sessionId length]>0){
				[ProfileUtil setString:sessionId forKey:SESSIONID];
				//[ProfileUtil setString:sessionId forKey:AUTHID];
				
				if([ProfileUtil integerForKey:AUTORULE]>0)
					[ProfileUtil setBool:YES forKey:AUTOSYNCFLAG];
				else 
					[ProfileUtil setBool:NO forKey:AUTOSYNCFLAG];
				

			}
		}
		
		//[root release];
	}else{
		
		resultCode=-1;//網路或後端問題
	}
	
	[requestXML release];
	
	
	return resultCode;
}

+(NSInteger) updGlobalNotification:(BOOL)enableFlag{
	BOOL flag;
    
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	if(serviceId==nil || [serviceId length]<=0)
		return 3;
	if(authId==nil || [authId length]<=0)
		return 3;
	
	NSMutableString *requestXML=[[NSMutableString alloc]init];
	[requestXML setString:[NSString stringWithFormat:@"%@?%@",GLOBALNOTIFYURL,[DateTimeUtil getUrlDateString]]];
	NSURL *backupUrl = [NSURL URLWithString:requestXML];
	NSMutableURLRequest *postRequest;
	NSData *data;
	
	NSHTTPURLResponse *returnResponse;
	NSError *returnError;
	int statusCode,resultCode;
	
	
	TreeNode *root;		
	
	/*執行要求*/
	//adding header information:
	postRequest = [NSMutableURLRequest requestWithURL:backupUrl];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	
	[InterfaceUtil setHeader:postRequest];
	
	[requestXML setString:@"xml=<iphone_notification_req>"];
	[requestXML appendString:[NSString stringWithFormat:@"<auth_id>%@</auth_id>",authId]];
	[requestXML appendString:[NSString stringWithFormat:@"<service_id>%@</service_id>",serviceId]];
	if(enableFlag==YES)
		[requestXML appendString:@"<global_enable>Y</global_enable>"];
	else
		[requestXML appendString:@"<global_enable>N</global_enable>"];
	[requestXML appendString:@"</iphone_notification_req>"];
	DoLog(DEBUG,@"requestXML=%@",requestXML);
	
	data = [[NSData alloc] initWithData:[requestXML dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:data];
	[data release];
	
	
	returnResponse = nil;
	returnError = nil;
	data = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
	statusCode = returnResponse.statusCode;
	DoLog(DEBUG,@"statusCode=%d",statusCode);
	
	if(statusCode==200){
		
		DoLog(DEBUG,@"responseXML=%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease]);
		root = [[XMLParser sharedInstance] parseXMLFromData:data];	
		
		resultCode=[[root leafForKey:@"result"]intValue];
		
		//[root release];
	}else{
		flag=NO;
		resultCode=-1;//網路或後端問題
	}
	
	[requestXML release];
	
	
	return resultCode;
}

+(NSInteger) updDeviceToken:(NSString *)dToken{
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	if(serviceId==nil || [serviceId length]<=0)
		return 3;
	if(authId==nil || [authId length]<=0)
		return 3;
	
	NSMutableString *requestXML=[[NSMutableString alloc]init];
	[requestXML setString:[NSString stringWithFormat:@"%@?%@",DEVICETOKENURL,[DateTimeUtil getUrlDateString]]];
	NSURL *backupUrl = [NSURL URLWithString:requestXML];
	NSMutableURLRequest *postRequest;
	NSData *data;
	
	NSHTTPURLResponse *returnResponse;
	NSError *returnError;
	int statusCode,resultCode;
	
	
	TreeNode *root;		
	
	/*執行要求*/
	//adding header information:
	postRequest = [NSMutableURLRequest requestWithURL:backupUrl];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	
	[InterfaceUtil setHeader:postRequest];
	
	[requestXML setString:@"xml=<iphone_device_token_req>"];
	[requestXML appendString:[NSString stringWithFormat:@"<auth_id>%@</auth_id>",authId]];
	[requestXML appendString:[NSString stringWithFormat:@"<service_id>%@</service_id>",serviceId]];
	[requestXML appendString:[NSString stringWithFormat:@"<device_token>%@</device_token>",dToken]];
	[requestXML appendString:@"</iphone_device_token_req>"];
	DoLog(DEBUG,@"requestXML=%@",requestXML);
	
	data = [[NSData alloc] initWithData:[requestXML dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:data];
	[data release];
	
	
	returnResponse = nil;
	returnError = nil;
	data = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
	statusCode = returnResponse.statusCode;
	DoLog(DEBUG,@"statusCode=%d",statusCode);
	
	if(statusCode==200){
		
		DoLog(DEBUG,@"responseXML=%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease]);
		root = [[XMLParser sharedInstance] parseXMLFromData:data];	
		
		resultCode=[[root leafForKey:@"result"]intValue];
		
		//[root release];
	}else{
		resultCode=-1;//網路或後端問題
	}
	
	[requestXML release];
	
	
	return resultCode;
}

+(NSInteger) feedbackNotification:(NSString *)cId{
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	if(serviceId==nil || [serviceId length]<=0)
		return 3;
	if(authId==nil || [authId length]<=0)
		return 3;
	
	NSMutableString *requestXML=[[NSMutableString alloc]init];
	[requestXML setString:[NSString stringWithFormat:@"%@?%@",FEEDBACKNOTIFYURL,[DateTimeUtil getUrlDateString]]];
	NSURL *backupUrl = [NSURL URLWithString:requestXML];
	NSMutableURLRequest *postRequest;
	NSData *data;
	
	NSHTTPURLResponse *returnResponse;
	NSError *returnError;
	int statusCode,resultCode;
	
	
	TreeNode *root;		
	
	/*執行要求*/
	//adding header information:
	postRequest = [NSMutableURLRequest requestWithURL:backupUrl];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	
	[InterfaceUtil setHeader:postRequest];
	
	[requestXML setString:@"xml=<iphone_feedback_req>"];
	[requestXML appendString:[NSString stringWithFormat:@"<auth_id>%@</auth_id>",authId]];
	[requestXML appendString:[NSString stringWithFormat:@"<service_id>%@</service_id>",serviceId]];
	[requestXML appendString:[NSString stringWithFormat:@"<calendar_id>%@</calendar_id>",cId]];
	[requestXML appendString:@"</iphone_feedback_req>"];
	DoLog(DEBUG,@"requestXML=%@",requestXML);
	
	data = [[NSData alloc] initWithData:[requestXML dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:data];
	[data release];
	
	
	returnResponse = nil;
	returnError = nil;
	data = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
	statusCode = returnResponse.statusCode;
	DoLog(DEBUG,@"statusCode=%d",statusCode);
	
	if(statusCode==200){
		
		DoLog(DEBUG,@"responseXML=%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease]);
		root = [[XMLParser sharedInstance] parseXMLFromData:data];	
		
		resultCode=[[root leafForKey:@"result"]intValue];
		
		//[root release];
	}else{
		resultCode=-1;//網路或後端問題
	}
	
	[requestXML release];
	
	
	return resultCode;
}

+(NSMutableDictionary *) doProvision:(NSString *) force{
	NSMutableDictionary *resultDictionary=[[NSMutableDictionary alloc]init];
	BOOL flag;
    
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	if(authId==nil || [authId length]<=0){
		[resultDictionary setObject:@"3" forKey:@"resultCode"];
		return resultDictionary;
	}
	
	NSMutableString *requestXML=[[NSMutableString alloc]init];
	[requestXML setString:[NSString stringWithFormat:@"%@?%@",PROVISIONURL,[DateTimeUtil getUrlDateString]]];
	NSURL *backupListUrl = [NSURL URLWithString:requestXML];
	NSMutableURLRequest *postRequest;
	NSData *data;
	
	NSHTTPURLResponse *returnResponse;
	NSError *returnError;
	int statusCode;
	
	TreeNode *root;	
	
	/*執行要求*/
	//adding header information:
	postRequest = [NSMutableURLRequest requestWithURL:backupListUrl];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	
	[InterfaceUtil setHeader:postRequest];
	
	[requestXML setString:@"xml=<device_provision_req>"];
	[requestXML appendString:[NSString stringWithFormat:@"<auth_id>%@</auth_id>",authId]];
	[requestXML appendString:[NSString stringWithFormat:@"<service_type>%@</service_type>",SERVICETYPE]];
	[requestXML appendString:[NSString stringWithFormat:@"<app_version>%@</app_version>",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	
	if(force!=nil && [force length]>0)
		[requestXML appendString:[NSString stringWithFormat:@"<force_init>%@</force_init>",force]];
	
	[requestXML appendString:[NSString stringWithFormat:@"<device_type>IPHONE</device_type>"]];
	//[requestXML appendString:[NSString stringWithFormat:@"<dev_info_model>%@</dev_info_model>",[[UIDevice currentDevice] model]]];
	[requestXML appendString:[NSString stringWithFormat:@"<imei>%@</imei>",[[UIDevice currentDevice] uniqueIdentifier]]];
	//[requestXML appendString:[NSString stringWithFormat:@"<dev_info_friendly_name>%@</dev_info_friendly_name>",[[UIDevice currentDevice] name]]];
	[requestXML appendString:[NSString stringWithFormat:@"<dev_os>%@ %@</dev_os>",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]]];
	[requestXML appendString:[NSString stringWithFormat:@"<os_language>%@</os_language>",[[NSLocale preferredLanguages] objectAtIndex:0]]];		
	//[requestXML appendString:[NSString stringWithFormat:@"<device_info_phone_number>%@</device_info_phone_number>",[[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"]]];
	[requestXML appendString:[NSString stringWithFormat:@"<user_agent>%@</user_agent>",[[UIDevice currentDevice] localizedModel]]];
	[requestXML appendString:@"</device_provision_req>"];
	DoLog(INFO,@"requestXML=%@",requestXML);
	
	data = [[NSData alloc] initWithData:[requestXML dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:data];
	[data release];
	
	
	returnResponse = nil;
	returnError = nil;
	data = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
	statusCode = returnResponse.statusCode;
	DoLog(INFO,@"statusCode=%d",statusCode);
	
	
	if(statusCode==200){
		
		DoLog(INFO,@"responseXML=%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease]);
		root = [[XMLParser sharedInstance] parseXMLFromData:data];	
		
		DoLog(DEBUG,@"result=%@",[root leafForKey:@"result"]);
		[resultDictionary setObject:[root leafForKey:@"result"] forKey:@"resultCode"];
		
		if([[root leafForKey:@"result"]intValue]==0){
			if([root leafForKey:@"service_id"]!=nil)
				[resultDictionary setObject:[root leafForKey:@"service_id"] forKey:@"serviceId"];
			//[resultDictionary setObject:[root leafForKey:@"status"] forKey:@"status"];
			if([root leafForKey:@"max_sync_amount"]!=nil)
				[resultDictionary setObject:[root leafForKey:@"max_sync_amount"] forKey:@"maxSyncAmount"];
			//[resultDictionary setObject:[root leafForKey:@"new_app_version"] forKey:@"newAppVersion"];
			if([root leafForKey:@"service_data_amount"]!=nil)
				[resultDictionary setObject:[root leafForKey:@"server_data_amount"] forKey:@"serverDataAmount"];
			
			flag=YES;
		}else{
			flag=NO;
		}
		//[root release];
	}else
		flag=NO;
	
	[requestXML release];
	
	return resultDictionary;
}

+(NSMutableDictionary *) getVersion{
	NSMutableDictionary *resultDictionary=[[NSMutableDictionary alloc]init];
	BOOL flag;
    
	
	NSMutableString *requestXML=[[NSMutableString alloc]init];
	[requestXML setString:[NSString stringWithFormat:@"%@?%@",VERSIONURL,[DateTimeUtil getUrlDateString]]];
	NSURL *backupListUrl = [NSURL URLWithString:requestXML];
	NSMutableURLRequest *postRequest;
	NSData *data;
	
	NSHTTPURLResponse *returnResponse;
	NSError *returnError;
	int statusCode;
	
	TreeNode *root;	
	
	/*執行要求*/
	//adding header information:
	postRequest = [NSMutableURLRequest requestWithURL:backupListUrl];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	
	[requestXML setString:@"xml=<version_info_req>"];
	[requestXML appendString:[NSString stringWithFormat:@"<service_type>%@</service_type>",SERVICETYPE]];
	[requestXML appendString:[NSString stringWithFormat:@"<version_number>%@</version_number>",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
	[requestXML appendString:@"</version_info_req>"];
	DoLog(DEBUG,@"requestXML=%@",requestXML);
	
	data = [[NSData alloc] initWithData:[requestXML dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:data];
	[data release];
	
	
	returnResponse = nil;
	returnError = nil;
	data = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
	statusCode = returnResponse.statusCode;
	DoLog(DEBUG,@"statusCode=%d",statusCode);
	
	
	if(statusCode==200){
		
		DoLog(INFO,@"responseXML=%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease]);
		root = [[XMLParser sharedInstance] parseXMLFromData:data];	
		
		if([root leafForKey:@"new_version"]!=nil)
			[resultDictionary setObject:[root leafForKey:@"new_version"] forKey:@"newVersion"];
		if([root leafForKey:@"enforce_update"]!=nil)
			[resultDictionary setObject:[root leafForKey:@"enforce_update"] forKey:@"enforceUpdate"];
		if([root leafForKey:@"current_expire_time"]!=nil)
			[resultDictionary setObject:[root leafForKey:@"current_expire_time"] forKey:@"currentExpireTime"];
		if([root leafForKey:@"desc_url_1"]!=nil)
			[resultDictionary setObject:[root leafForKey:@"desc_url_1"] forKey:@"descUrl1"];
		if([root leafForKey:@"download_url_1"]!=nil)
			[resultDictionary setObject:[root leafForKey:@"download_url_1"] forKey:@"downloadUrl1"];
		if([root leafForKey:@"desc_url_2"]!=nil)
			[resultDictionary setObject:[root leafForKey:@"desc_url_2"] forKey:@"descUrl2"];
		if([root leafForKey:@"download_url_2"]!=nil)
			[resultDictionary setObject:[root leafForKey:@"download_url_2"] forKey:@"downloadUrl2"];
		if([root leafForKey:@"desc_url_3"]!=nil)
			[resultDictionary setObject:[root leafForKey:@"desc_url_3"] forKey:@"descUrl3"];
		if([root leafForKey:@"download_url_3"]!=nil)
			[resultDictionary setObject:[root leafForKey:@"download_url_3"] forKey:@"downloadUrl3"];		
		flag=YES;
		
		//[root release];
	}else
		flag=NO;
	
	[requestXML release];
	
	if(flag==NO){
		[resultDictionary release];
		resultDictionary=nil;
	}
	
	return resultDictionary;
}

+(BOOL) setHeader:(NSMutableURLRequest *)request{
	BOOL result=YES;
	
	[request addValue:INTERFACEVERSION forHTTPHeaderField: @"InterfaceVersion"];
	[request addValue:[ProfileUtil stringForKey:SESSIONID] forHTTPHeaderField:@"AuthorizationId"];
	
	DoLog(INFO,@"InterfaceVersion=%@",INTERFACEVERSION);
	DoLog(INFO,@"AuthorizationId=%@",[ProfileUtil stringForKey:SESSIONID]);
	
	return result;
}

@end
