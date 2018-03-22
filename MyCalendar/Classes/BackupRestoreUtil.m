//
//  BackupRestoreUtil.m
//  MyCalendar
//
//  Created by yves ho on 2010/4/1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BackupRestoreUtil.h"
#import "MySqlite.h"
#import "DateTimeUtil.h"
#import "XMLParser.h"
#import "TreeNode.h"
#import "ProfileUtil.h"
#import "InterfaceUtil.h"

@implementation BackupRestoreUtil
/*
static NSInteger	RS_SUCC=0;			// 成功
static NSInteger	RS_FMT_ERR=1;		// 資料格式錯誤
static NSInteger	RS_ARG_ERR=2;		// 資料參數錯誤
static NSInteger	RS_AUTH_ERR=3;		// 認證資料錯誤
static NSInteger	RS_BRLOCK_ERR=4;    // 備份還原上鎖錯誤
static NSInteger	RS_INTERNAL_ERR=5;	// 系統內部錯誤
*/

+(NSInteger) startBackup{
	BOOL flag;
    
	//NSString *serviceId=[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEID];
	//NSString *authId=[[NSUserDefaults standardUserDefaults] objectForKey:AUTHID];
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	if(serviceId==nil || [serviceId length]<=0)
		return 3;
	if(authId==nil || [authId length]<=0)
		return 3;
	
	NSMutableString *requestXML=[[NSMutableString alloc]init];
	[requestXML setString:[NSString stringWithFormat:@"%@?%@",BACKUPURL,[DateTimeUtil getUrlDateString]]];
	NSURL *backupUrl = [NSURL URLWithString:requestXML];
	NSMutableURLRequest *postRequest;
	NSData *data;
	
	NSHTTPURLResponse *returnResponse;
	NSError *returnError;
	int statusCode,resultCode;
	
	//select from db
	MySqlite *mySqlite=[[MySqlite alloc]init];
	NSMutableDictionary *backupLog;
	
	TreeNode *root;		
	
	/*執行備份要求*/
	//adding header information:
	postRequest = [NSMutableURLRequest requestWithURL:backupUrl];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	
	[InterfaceUtil setHeader:postRequest];
	
	[requestXML setString:@"xml=<calendar_backup_req>"];
	[requestXML appendString:[NSString stringWithFormat:@"<auth_id>%@</auth_id>",authId]];
	[requestXML appendString:[NSString stringWithFormat:@"<service_id>%@</service_id>",serviceId]];
	[requestXML appendString:@"</calendar_backup_req>"];
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
		
		DoLog(DEBUG,@"result=%@",[root leafForKey:@"result"]);
		if([[root leafForKey:@"result"]intValue]==0){
			backupLog=[[NSMutableDictionary alloc]init];
			[backupLog setObject:[root leafForKey:@"backup_id"] forKey:@"backupId"];
			[backupLog setObject:[root leafForKey:@"backup_bgn_time"] forKey:@"backupBgnTime"];
			[backupLog setObject:[DateTimeUtil getTodayString] forKey:@"backupEndTime"];
			[backupLog setObject:[NSMutableString stringWithFormat:@"%d",-1] forKey:@"backupResult"];
			//insert db
			DoLog(DEBUG,@"insert backup log");
			flag=[mySqlite insBackupLog:backupLog];
			[backupLog release];
			
			if(flag==YES)
				resultCode=0;
			else
				resultCode=4;//資料庫問題
		}else if([[root leafForKey:@"result"]intValue]>=6){
			flag=NO;
			resultCode=[[root leafForKey:@"result"]intValue];//需特別處理
		}else if([[root leafForKey:@"result"]intValue]==3){
			flag=NO;
			resultCode=3;//認證失敗
		}else{
			flag=NO;
			resultCode=2;//後端程式問題
		}
		[root release];
	}else{
		flag=NO;
		resultCode=1;//網路或後端問題
	}
	
	[requestXML release];
	[mySqlite release];
	
	return resultCode;
}

+(NSInteger) startRestore:(NSString *)bLog{
	BOOL flag;
    
	//NSString *serviceId=[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEID];
	//NSString *authId=[[NSUserDefaults standardUserDefaults] objectForKey:AUTHID];
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	if(serviceId==nil || [serviceId length]<=0)
		return 3;
	if(authId==nil || [authId length]<=0)
		return 3;
	
	NSMutableString *requestXML=[[NSMutableString alloc]init];
	[requestXML setString:[NSString stringWithFormat:@"%@?%@",RESTOREURL,[DateTimeUtil getUrlDateString]]];
	NSURL *restoreUrl = [NSURL URLWithString:requestXML];
	NSMutableURLRequest *postRequest;
	NSData *data;
	
	
	NSHTTPURLResponse *returnResponse;
	NSError *returnError;
	int statusCode,resultCode;
	
	//select from db
	MySqlite *mySqlite=[[MySqlite alloc]init];
	NSMutableDictionary *backupLog=[mySqlite getLastBackupLog:0];
	NSMutableDictionary *restoreLog;
	
	TreeNode *root;
	
	if(backupLog!=nil || bLog!=nil){
		
		/*還原要求*/
		//adding header information:
		postRequest = [NSMutableURLRequest requestWithURL:restoreUrl];
		[postRequest setHTTPMethod:@"POST"];
		[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
		
		[InterfaceUtil setHeader:postRequest];
		
		[requestXML setString:@"xml=<calendar_restore_req>"];
		[requestXML appendString:[NSString stringWithFormat:@"<auth_id>%@</auth_id>",authId]];
		[requestXML appendString:[NSString stringWithFormat:@"<service_id>%@</service_id>",serviceId]];
		if(bLog!=nil)
			[requestXML appendString:[NSString stringWithFormat:@"<backup_id>%@</backup_id>",bLog]];
		else
			[requestXML appendString:[NSString stringWithFormat:@"<backup_id>%@</backup_id>",[backupLog objectForKey:@"backupId"]]];
		
		[requestXML appendString:@"</calendar_restore_req>"];
		
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
			
			DoLog(DEBUG,@"result=%@",[root leafForKey:@"result"]);
			if([[root leafForKey:@"result"]intValue]==0){
				restoreLog=[[NSMutableDictionary alloc]init];
				[restoreLog setObject:[root leafForKey:@"restore_id"] forKey:@"restoreId"];
				[restoreLog setObject:[root leafForKey:@"restore_bgn_time"] forKey:@"restoreBgnTime"];
				[restoreLog setObject:[DateTimeUtil getTodayString] forKey:@"restoreEndTime"];
				[restoreLog setObject:[NSString stringWithFormat:@"%d",-1] forKey:@"restoreResult"];
				//insert db
				flag=[mySqlite insRestoreLog:restoreLog];
				[restoreLog release];
				if(flag==YES)
					resultCode=0;
				else
					resultCode=5;//資料庫問題
			}else if([[root leafForKey:@"result"]intValue]>=6){
				flag=NO;
				resultCode=[[root leafForKey:@"result"]intValue];//需特別處理
			}else if([[root leafForKey:@"result"]intValue]==3){
				flag=NO;
				resultCode=3;//認證失敗
			}else{
				flag=NO;
				resultCode=2;//後端問題
			}
			[root release];
		}else{
			flag=NO;
			resultCode=1;//網路問題或伺服器問題
		}
	}else
		resultCode=4;//無備份資料
	
	[requestXML release];
	[mySqlite release];
	
	return resultCode;
}

+(NSMutableDictionary *) getBackupResult:(NSString *)bId{
	NSMutableDictionary *resultDictionary=[[NSMutableDictionary alloc]init];
	NSMutableArray *resultArray=[[NSMutableArray alloc]init];
	BOOL flag;
    
	//NSString *serviceId=[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEID];
	//NSString *authId=[[NSUserDefaults standardUserDefaults] objectForKey:AUTHID];
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	if(serviceId==nil || [serviceId length]<=0){
		[resultArray release];
		resultArray=nil;
		
		[resultDictionary setObject:@"3" forKey:@"resultCode"];
		return resultDictionary;
	}
	if(authId==nil || [authId length]<=0){
		[resultArray release];
		resultArray=nil;
		
		[resultDictionary setObject:@"3" forKey:@"resultCode"];
		return resultDictionary;
	}
	
	NSMutableString *requestXML=[[NSMutableString alloc]init];
	[requestXML setString:[NSString stringWithFormat:@"%@?%@",BACKUPLISTURL,[DateTimeUtil getUrlDateString]]];
	NSURL *backupListUrl = [NSURL URLWithString:requestXML];
	NSMutableURLRequest *postRequest;
	NSData *data;
	
	NSHTTPURLResponse *returnResponse;
	NSError *returnError;
	int statusCode;
	
	NSMutableDictionary *backupLog;
	
	NSArray *myArrays;
	TreeNode *root;	
	
	/*查詢備份紀錄*/
	//adding header information:
	postRequest = [NSMutableURLRequest requestWithURL:backupListUrl];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	
	[InterfaceUtil setHeader:postRequest];
	
	[requestXML setString:@"xml=<calendar_backup_list_req>"];
	[requestXML appendString:[NSString stringWithFormat:@"<auth_id>%@</auth_id>",authId]];
	[requestXML appendString:[NSString stringWithFormat:@"<service_id>%@</service_id>",serviceId]];
	
	if(bId!=nil)
		[requestXML appendString:[NSString stringWithFormat:@"<backup_id>%@</backup_id>",bId]];
	
	[requestXML appendString:@"</calendar_backup_list_req>"];
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
		
		DoLog(DEBUG,@"result=%@",[root leafForKey:@"result"]);
		[resultDictionary setObject:[root leafForKey:@"result"] forKey:@"resultCode"];
		
		if([[root leafForKey:@"result"]intValue]==0){
			if([[root leafForKey:@"backup_count"] intValue]>0){
				myArrays=[root objectsForKey:@"backup"];
				for(int i=0;i<[myArrays count];i++){
					
					backupLog=[[NSMutableDictionary alloc]init];
					[backupLog setObject:[[myArrays objectAtIndex:i] leafForKey:@"backup_id"] forKey:@"backupId"];
					[backupLog setObject:[[myArrays objectAtIndex:i] leafForKey:@"backup_bgn_time"] forKey:@"backupBgnTime"];
					[backupLog setObject:[[myArrays objectAtIndex:i] leafForKey:@"backup_end_time"] forKey:@"backupEndTime"];
					[backupLog setObject:[[myArrays objectAtIndex:i] leafForKey:@"backup_result"] forKey:@"backupResult"];
					[resultArray addObject:backupLog];
					[backupLog release];
					
				}
				//[myArrays release];
				flag=YES;
			}
			flag=YES;
		}else{
			flag=NO;
		}
		[root release];
	}else
		flag=NO;
	
	[requestXML release];
	
	if(flag==NO){
		[resultArray release];
		resultArray=nil;
	}else
		[resultDictionary setObject:resultArray forKey:@"resultArray"];
	
	return resultDictionary;
}

+(NSMutableDictionary *) getRestoreResult:(NSString *)rId{
	NSMutableDictionary *resultDictionary=[[NSMutableDictionary alloc]init];
	NSMutableArray *resultArray=[[NSMutableArray alloc]init];
	BOOL flag;
    
	//NSString *serviceId=[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEID];
	//NSString *authId=[[NSUserDefaults standardUserDefaults] objectForKey:AUTHID];
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	if(serviceId==nil || [serviceId length]<=0){
		[resultArray release];
		resultArray=nil;
		
		[resultDictionary setObject:@"3" forKey:@"resultCode"];
		return resultDictionary;
	}
	if(authId==nil || [authId length]<=0){
		[resultArray release];
		resultArray=nil;
		
		[resultDictionary setObject:@"3" forKey:@"resultCode"];
		return resultDictionary;
	}
		
	NSMutableString *requestXML=[[NSMutableString alloc]init];
	[requestXML setString:[NSString stringWithFormat:@"%@?%@",RESTORELISTURL,[DateTimeUtil getUrlDateString]]];
	NSURL *restoreListUrl = [NSURL URLWithString:requestXML];
	NSMutableURLRequest *postRequest;
	NSData *data;
	
	
	NSHTTPURLResponse *returnResponse;
	NSError *returnError;
	int statusCode;
	
	
	NSMutableDictionary *restoreLog;
	
	NSArray *myArrays;
	TreeNode *root;
	
	/*查詢還原紀錄*/
	//adding header information:
	postRequest = [NSMutableURLRequest requestWithURL:restoreListUrl];
	[postRequest setHTTPMethod:@"POST"];
	[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	
	[InterfaceUtil setHeader:postRequest];
	
	[requestXML setString:@"xml=<calendar_restore_list_req>"];
	[requestXML appendString:[NSString stringWithFormat:@"<auth_id>%@</auth_id>",authId]];
	[requestXML appendString:[NSString stringWithFormat:@"<service_id>%@</service_id>",serviceId]];
	
	if(rId!=nil)
		[requestXML appendString:[NSString stringWithFormat:@"<restore_id>%@</restore_id>",rId]];
	
	
	[requestXML appendString:@"</calendar_restore_list_req>"];
	
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
		
		DoLog(DEBUG,@"result=%@",[root leafForKey:@"result"]);
		[resultDictionary setObject:[root leafForKey:@"result"] forKey:@"resultCode"];
		
		if([[root leafForKey:@"result"]intValue]==0){
			if([[root leafForKey:@"restore_count"] intValue]>0){
				myArrays=[root objectsForKey:@"restore"];
				for(int i=0;i<[myArrays count];i++){
					restoreLog=[[NSMutableDictionary alloc]init];
					[restoreLog setObject:[[myArrays objectAtIndex:i] leafForKey:@"restore_id"] forKey:@"restoreId"];
					[restoreLog setObject:[[myArrays objectAtIndex:i] leafForKey:@"restore_bgn_time"] forKey:@"restoreBgnTime"];
					[restoreLog setObject:[[myArrays objectAtIndex:i] leafForKey:@"restore_end_time"] forKey:@"restoreEndTime"];
					[restoreLog setObject:[[myArrays objectAtIndex:i] leafForKey:@"restore_result"] forKey:@"restoreResult"];
					[resultArray addObject:restoreLog];
					[restoreLog release];
				}
				//[myArrays release];
			}
			flag=YES;
		}else{
			flag=NO;
		}
		[root release];
	}else
		flag=NO;
		
	[requestXML release];

	if(flag==NO){
		[resultArray release];
		resultArray=nil;
	}else
		[resultDictionary setObject:resultArray forKey:@"resultArray"];
	
	return resultDictionary;
}

@end
