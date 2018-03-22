#import "SyncOperation.h"
#import "MySqlite.h"
#import "XMLParser.h"
#import "DateTimeUtil.h"
//#import "Connectivity.h"
#import "EventRecurrence.h"
#import "ProfileUtil.h"
#import "InterfaceUtil.h"

@implementation SyncOperation
@synthesize delegate;
@synthesize stopFlag;
@synthesize errorFlag;

- (void) start{
	[super start];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//Network testing
	DoLog(DEBUG,@"wiFiConnected: %@",([UIDevice wiFiConnected] ? @"YES" : @"NO"));
	DoLog(DEBUG,@"networkConnected: %@",([UIDevice networkConnected]? @"YES" : @"NO"));
	DoLog(DEBUG,@"cellularConnected: %@",([UIDevice cellularConnected]? @"YES" : @"NO"));
	

	MySqlite *mySqlite=[[MySqlite alloc]init];
	self.errorFlag = [[[SyncErrorCode alloc] init]autorelease]; 

	NSInteger resultFlag = [self doInitSync:mySqlite];//do it as the first time(there is no record in sync_log table)
	DoLog(INFO,@"doRestore=%@",[self.errorFlag getErrorStringFromCode:resultFlag]);
	resultFlag = [self doRestore:mySqlite];//do it when get the restore_result = 1
	DoLog(INFO,@"doRestore=%@",[self.errorFlag getErrorStringFromCode:resultFlag]);
	
	NSDictionary *tmpDictionary=[self getSyncSeq:mySqlite.database];
	NSInteger flag=0;
	
	if(tmpDictionary!=nil){
		NSInteger syncSeq=[[tmpDictionary objectForKey:@"sync_seq"] intValue];
		//NSInteger sessionSeq=[[tmpDictionary objectForKey:@"session_seq"] intValue];
		
		flag=[self doFolderSync:mySqlite seq:syncSeq];
		DoLog(INFO,@"doFolderSync=%d",flag);
		if (self.delegate && [self.delegate respondsToSelector:@selector(setProgress:)]){
			[self.delegate performSelector:@selector(setProgress:) withObject:[NSString stringWithFormat:@"%d",1]];
			
		}
		
		if(flag == 0)
			resultFlag = [self doRecurrenceSync:mySqlite seq:syncSeq];
		DoLog(INFO,@"doRecurrenceSync=%@",[self.errorFlag getErrorStringFromCode:resultFlag]);
		if (self.delegate && [self.delegate respondsToSelector:@selector(setProgress:)]){
			[self.delegate performSelector:@selector(setProgress:) withObject:[NSString stringWithFormat:@"%d",4]];
			
		}
		
		if(flag==0 && resultFlag == 0)
			resultFlag=[self doContentSync:mySqlite seq:syncSeq];
		DoLog(INFO,@"doContentSync=%@",[self.errorFlag getErrorStringFromCode:resultFlag]);
		if (self.delegate && [self.delegate respondsToSelector:@selector(setProgress:)]){
			[self.delegate performSelector:@selector(setProgress:) withObject:[NSString stringWithFormat:@"%d",10]];
			
		}
		
		if(flag==0 && resultFlag!=0)
			flag=1;
		/*
		for(int i=1;i<=10;i++){
			[NSThread sleepForTimeInterval:1.0f];
			
			if (self.delegate && [self.delegate respondsToSelector:@selector(setProgress:)]){
				[self.delegate performSelector:@selector(setProgress:) withObject:[NSString stringWithFormat:@"%d",i]];
				
			}
		}
		*/
	}
	
	
	[mySqlite release];
	
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(doneSyncing:)]){
		[self.delegate performSelector:@selector(doneSyncing:) withObject:[NSString stringWithFormat:@"%d",flag]];
		
	}
	stopFlag=NO;
	[pool release];
}

-(NSInteger) doFolderSync:(MySqlite *)mySqlite seq:(NSInteger)sId{
	/*0:成功,1:失敗,2:部份失敗,3:認證失敗,4:網路失敗,5:使用者終止*/
	
	NSInteger result=0;
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//UIAlertView *alert;
	
	static sqlite3_stmt *sync_category = nil;
	static sqlite3_stmt *sync_category1 = nil;
	static sqlite3_stmt *sync_category2 = nil;
	if(sync_category == nil){
		const char *sync_category_sql = "SELECT folder_id FROM pim_cal_folder where sync_status=1 order by modified_datetime";
		if (sqlite3_prepare_v2(mySqlite.database, sync_category_sql, -1, &sync_category, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare statement error='%s'.", sqlite3_errmsg(mySqlite.database));
			return 1;
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	if(sync_category1 == nil){
		const char *sync_category1_sql = "UPDATE pim_cal_folder set sync_status=1 where sync_flag!=2";
		if (sqlite3_prepare_v2(mySqlite.database, sync_category1_sql, -1, &sync_category1, NULL) != SQLITE_OK) {
			DoLog(DEBUG,@"prepare statement error='%s'.", sqlite3_errmsg(mySqlite.database));
			return 1;
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	if(sync_category2 == nil){
		const char *sync_category2_sql = "UPDATE pim_cal_folder set sync_status=0 where sync_status=1";
		if (sqlite3_prepare_v2(mySqlite.database, sync_category2_sql, -1, &sync_category2, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare statement error='%s'.", sqlite3_errmsg(mySqlite.database));
			return 1;
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	
	
	
	//NSString *serviceId=[[NSUserDefaults standardUserDefaults] objectForKey:SERVICEID];
	//NSString *authId=[[NSUserDefaults standardUserDefaults] objectForKey:AUTHID];
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	if(serviceId==nil || [serviceId length]<=0)
		return 3;
	if(authId==nil || [authId length]<=0)
		return 3;
	//NSString *syncPolicy=[[NSUserDefaults standardUserDefaults] objectForKey:SYNCRULE];
	NSString *syncPolicy=[ProfileUtil stringForKey:SYNCRULE];
	if(syncPolicy==nil || [syncPolicy length]<=0)
		syncPolicy=@"C";
	
	/*鎖住資料*/
	if(SQLITE_DONE != sqlite3_step(sync_category1)){
		DoLog(ERROR,@"Error update data for lock. '%s'", sqlite3_errmsg(mySqlite.database)); 
		sqlite3_reset(sync_category1);
		return 1;
	}
	sqlite3_reset(sync_category1);
	
	/*取得需同步資料的key*/
	NSMutableArray *folderIds = [[NSMutableArray alloc] init];
	NSString *tmpString;
	while(sqlite3_step(sync_category) == SQLITE_ROW) {
		if((char *)sqlite3_column_text(sync_category,0)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(sync_category,0)];
			[folderIds addObject:tmpString];
		}
	} 
	sqlite3_reset(sync_category);
	
	
	int session=0,i=0,j=0,k=0,max=100;
	
	max=[ProfileUtil integerForKey:MAXSYNCAMOUNT];
	if(max<=0)
		max=DEFAULTMAXSYNC;
	
	
	/*執行次數*/
	session=([folderIds count]%max > 0)? (([folderIds count]/max)+1):([folderIds count]/max);
	
	/*取得sync_seq*/
	NSDictionary *tmpDictionary=[self getSyncSeq:mySqlite.database];
	if(tmpDictionary!=nil){
		NSInteger syncSeq=[[tmpDictionary objectForKey:@"sync_seq"] intValue];
		NSInteger sessionSeq=[[tmpDictionary objectForKey:@"session_seq"] intValue];
		
		
		int addCount=0,addCount1=0;
		int updCount=0,updCount1=0;
		int delCount=0,delCount1=0;
		TodoCategory *todoCategory;
		NSMutableDictionary *replyDictionary;
		
		i=0;
		NSMutableString *requestXML=[[NSMutableString alloc]init];
		NSMutableArray *replyData=[[NSMutableArray alloc]init];
		BOOL flag=NO;
		
		NSURL *folderSyncUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",FOLDERSYNCURL,[DateTimeUtil getUrlDateString]]];
		NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:folderSyncUrl];
		NSData *data;
		
		//adding header information:
		[postRequest setHTTPMethod:@"POST"];
		[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
		
		[InterfaceUtil setHeader:postRequest];
		
		NSHTTPURLResponse *returnResponse;
		NSError *returnError;
		int statusCode,resultCode;
		BOOL dbFlag;
		TreeNode *root;
		TreeNode *myNode;
		NSMutableArray *myArrays;
		NSMutableDictionary *myDatas;
		
		do{
			[requestXML setString:@"xml=<folder_sync_req>"];

			[requestXML appendString:[NSString stringWithFormat:@"<auth_id>%@</auth_id>",authId]];
			[requestXML appendString:[NSString stringWithFormat:@"<service_id>%@</service_id>",serviceId]];
			[requestXML appendString:[NSString stringWithFormat:@"<sync_seq>%d</sync_seq>",syncSeq]];
			[requestXML appendString:[NSString stringWithFormat:@"<session_seq>%d</session_seq>",sessionSeq++]];
			
			if(i>=session)/*無資料需要同步*/
				[requestXML appendString:@"<fld_c_req_count>0</fld_c_req_count>"];
			else{/*產生ＸＭＬ*/

				[requestXML appendString:@"<fld_c_req_count>1</fld_c_req_count>"];
				[requestXML appendString:@"<fld_c_req>"];				
				addCount=0;updCount=0;delCount=0;/*取session資料*/
				for(j=i*max;j<[folderIds count] && j<(i+1)*max;j++){ 
					todoCategory=[[TodoCategory alloc]initWithCategoryId:[folderIds objectAtIndex:j] database:mySqlite.database];
					if([todoCategory.folderId length]<=0){/*資料有誤*/
						[todoCategory release];
						continue;
					}else if(todoCategory.stateFlag==0){/*新增*/
						[requestXML appendString:@"<fld_c_add>"];
						[requestXML appendString:[NSString stringWithFormat:@"<client_id>%@</client_id>",todoCategory.folderId]];
						[requestXML appendString:@"<folder_data>"];
						[requestXML appendString:@"<parent_id>0</parent_id>"];
						[requestXML appendString:[NSString stringWithFormat:@"<display_name>%@</display_name>",todoCategory.folderName]];
						[requestXML appendString:[NSString stringWithFormat:@"<folder_type>%d</folder_type>",todoCategory.folderType]];
						[requestXML appendString:[NSString stringWithFormat:@"<color_rgb>%d</color_rgb>",todoCategory.colorRgb]];
						if(todoCategory.photoPath!=nil)
							[requestXML appendString:[NSString stringWithFormat:@"<photo_path>%@</photo_path>",todoCategory.photoPath]];
						if(todoCategory.memo!=nil)
							[requestXML appendString:[NSString stringWithFormat:@"<memo>%@</memo>",todoCategory.memo]];
						[requestXML appendString:[NSString stringWithFormat:@"<created_datetime>%@</created_datetime>",todoCategory.createdDatetime]];
						[requestXML appendString:[NSString stringWithFormat:@"<modified_datetime>%@</modified_datetime>",todoCategory.modifiedDatetime]];						[requestXML appendString:@"</folder_data>"];
						[requestXML appendString:@"</fld_c_add>"];
						addCount++;
					}else if(todoCategory.stateFlag==1){/*修改*/
						[requestXML appendString:@"<fld_c_upd>"];
						[requestXML appendString:[NSString stringWithFormat:@"<folder_id>%@</folder_id>",todoCategory.serverId]];            
						[requestXML appendString:@"<folder_data>"];
						[requestXML appendString:@"<parent_id>0</parent_id>"];
						[requestXML appendString:[NSString stringWithFormat:@"<display_name>%@</display_name>",todoCategory.folderName]];
						[requestXML appendString:[NSString stringWithFormat:@"<folder_type>%d</folder_type>",todoCategory.folderType]];
						[requestXML appendString:[NSString stringWithFormat:@"<color_rgb>%d</color_rgb>",todoCategory.colorRgb]];
						if(todoCategory.photoPath!=nil)
							[requestXML appendString:[NSString stringWithFormat:@"<photo_path>%@</photo_path>",todoCategory.photoPath]];
						if(todoCategory.memo!=nil)
							[requestXML appendString:[NSString stringWithFormat:@"<memo>%@</memo>",todoCategory.memo]]; 
						[requestXML appendString:[NSString stringWithFormat:@"<created_datetime>%@</created_datetime>",todoCategory.createdDatetime]];
						[requestXML appendString:[NSString stringWithFormat:@"<modified_datetime>%@</modified_datetime>",todoCategory.modifiedDatetime]];						[requestXML appendString:@"</folder_data>"];
						[requestXML appendString:@"</folder_data>"];
						[requestXML appendString:@"</fld_c_upd>"];
						updCount++;
					}else if(todoCategory.stateFlag==2){/*刪除*/
						[requestXML appendString:@"<fld_c_del>"];
						[requestXML appendString:[NSString stringWithFormat:@"<folder_id>%@</folder_id>",todoCategory.serverId]];
						[requestXML appendString:@"</fld_c_del>"];
						delCount++;
					}
					[todoCategory release];
				}
				[requestXML appendString:[NSString stringWithFormat:@"<fld_c_add_count>%d</fld_c_add_count>",addCount]];
				[requestXML appendString:[NSString stringWithFormat:@"<fld_c_del_count>%d</fld_c_del_count>",delCount]];
				[requestXML appendString:[NSString stringWithFormat:@"<fld_c_upd_count>%d</fld_c_upd_count>",updCount]];
				[requestXML appendString:@"</fld_c_req>"];
				i++;
			}
						
			if([replyData count]<=0)/*無回覆資料*/
				[requestXML appendString:@"<fld_c_rpl_count>0</fld_c_rpl_count>"];
			else{/*產生回覆XML*/
				[requestXML appendString:@"<fld_c_rpl_count>1</fld_c_rpl_count>"];
				[requestXML appendString:@"<fld_c_rpl>"];
				
				addCount1=0;updCount1=0;delCount1=0;
				for(k=0;k<[replyData count];k++){
					replyDictionary=[replyData objectAtIndex:k];
					if([[replyDictionary objectForKey:@"stateFlag"] intValue]==0){/*新增*/
						[requestXML appendString:@"<fld_c_rpl_add>"];
						[requestXML appendString:[NSString stringWithFormat:@"<folder_id>%@</folder_id>",[replyDictionary objectForKey:@"serverId"]]];
						[requestXML appendString:[NSString stringWithFormat:@"<result>%@</result>",[replyDictionary objectForKey:@"result"]]];
						[requestXML appendString:@"</fld_c_rpl_add>"];
						addCount1++;
					}else if([[replyDictionary objectForKey:@"stateFlag"] intValue]==1){/*修改*/
						[requestXML appendString:@"<fld_c_rpl_upd>"];
						[requestXML appendString:[NSString stringWithFormat:@"<folder_id>%@</folder_id>",[replyDictionary objectForKey:@"serverId"]]];
						[requestXML appendString:[NSString stringWithFormat:@"<result>%@</result>",[replyDictionary objectForKey:@"result"]]];
						[requestXML appendString:@"</fld_c_rpl_upd>"];
						updCount1++;
					}else if([[replyDictionary objectForKey:@"stateFlag"] intValue]==2){/*刪除*/
						[requestXML appendString:@"<fld_c_rpl_del>"];
						[requestXML appendString:[NSString stringWithFormat:@"<folder_id>%@</folder_id>",[replyDictionary objectForKey:@"serverId"]]];
						[requestXML appendString:[NSString stringWithFormat:@"<result>%@</result>",[replyDictionary objectForKey:@"result"]]];
						[requestXML appendString:@"</fld_c_rpl_del>"];
						delCount1++;
					}
				}

				[requestXML appendString:[NSString stringWithFormat:@"<fld_c_rpl_add_count>%d</fld_c_rpl_add_count>",addCount1]];
				[requestXML appendString:[NSString stringWithFormat:@"<fld_c_rpl_del_count>%d</fld_c_rpl_del_count>",delCount1]];
				[requestXML appendString:[NSString stringWithFormat:@"<fld_c_rpl_upd_count>%d</fld_c_rpl_upd_count>",updCount1]];
					
				[requestXML appendString:@"</fld_c_rpl>"];
			}
			
			if(i<session)/*尚有資料需要同步*/
				[requestXML appendString:@"<has_more>Y</has_more>"];        
			[requestXML appendString:@"</folder_sync_req>"];
			
			DoLog(INFO,@"%@",requestXML);
			
			
			/*產生http request data*/
			data = [[NSData alloc] initWithData:[requestXML dataUsingEncoding:NSUTF8StringEncoding]];
			[postRequest setHTTPBody:data];
			[data release];
			
			/*送出request與接收資料*/
			returnResponse = nil;
			returnError = nil;
			data = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
			statusCode = returnResponse.statusCode;
			DoLog(INFO,@"statusCode=%d",statusCode);
			
			if(statusCode!=200){
				DoLog(ERROR,@"error=%@",[returnError description]);
				result=4;
				break;
			}
			
			DoLog(DEBUG,@"responseXML=%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease]);
			//data=[[NSData alloc]initWithData:[@"<folder_sync_res><result>0</result><sync_seq>1</sync_seq><session_seq>2</session_seq><ack></ack><has_more>N</has_more><fld_s_rpl_count>1</fld_s_rpl_count><fld_s_rpl><fld_s_rpl_add_count>1</fld_s_rpl_add_count><fld_s_rpl_add><client_id>1</client_id><folder_id>1</folder_id><result>0</result></fld_s_rpl_add><fld_s_rpl_del_count>1</fld_s_rpl_del_count><fld_s_rpl_del><folder_id>2</folder_id><result>0</result></fld_s_rpl_del><fld_s_rpl_upd_count>1</fld_s_rpl_upd_count><fld_s_rpl_upd><folder_id>1</folder_id><result>0</result></fld_s_rpl_upd></fld_s_rpl><fld_s_req_count>1</fld_s_req_count><fld_s_req><fld_s_add_count>1</fld_s_add_count><fld_s_add><folder_id>1</folder_id><folder_data><parent_id>0</parent_id><display_name>´ú¸Õ</display_name><folder_type>0</folder_type><color_rgb>255000255</color_rgb><photo_path></photo_path><memo></memo></folder_data></fld_s_add><fld_s_del_count>1</fld_s_del_count><fld_s_del><folder_id>3</folder_id></fld_s_del><fld_s_upd_count>1</fld_s_upd_count><fld_s_upd><folder_id>5</folder_id><folder_data><parent_id>0</parent_id><display_name>µL</display_name><folder_type>0</folder_type><color_rgb>255</color_rgb><photo_path></photo_path><memo>xxx</memo></folder_data></fld_s_upd></fld_s_req></folder_sync_res>" dataUsingEncoding:NSUTF8StringEncoding]];
			//DoLog(DEBUG,@"test=%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease]);
			
			/*處理回覆資料*/
			[replyData removeAllObjects]; 
			root = [[XMLParser sharedInstance] parseXMLFromData:data];
			
			resultCode=[[root leafForKey:@"result"] intValue];
			DoLog(INFO,@"result=%d",resultCode);
			if(resultCode!=0){
				[root release];
				//[data release];
				if(resultCode!=3){//非認證失敗
					
					if(resultCode>=6)//需處理錯誤,如未申裝服務或需清除資料
						result=resultCode;
					else
						result=1;
				}else
					result=3;
				
				break;
			}
			
			//DoLog(DEBUG,@"fld_s_rpl_count=%@",[root leafForKey:@"fld_s_rpl_count"]);
			if([[root leafForKey:@"fld_s_rpl_count"] intValue]>0){
				myNode=[root objectForKey:@"fld_s_rpl"];
				if([[myNode leafForKey:@"fld_s_rpl_add_count"] intValue]>0){/*處理回覆新增*/
					myArrays=[myNode objectsForKey:@"fld_s_rpl_add"];
					for(int i=0;i<[myArrays count];i++){
						resultCode=[[[myArrays objectAtIndex:i] leafForKey:@"result"]intValue];
						//DoLog(DEBUG,@"fld_s_rpl_add r=%d c=%@ s=%@",resultCode,[[myArrays objectAtIndex:i] leafForKey:@"client_id"],[[myArrays objectAtIndex:i] leafForKey:@"folder_id"]);
						if(resultCode==RP_SUCC){
							todoCategory=[[TodoCategory alloc]initWithCategoryId:[[myArrays objectAtIndex:i] leafForKey:@"client_id"] database:mySqlite.database];
							if([todoCategory.folderId isEqualToString:[[myArrays objectAtIndex:i] leafForKey:@"client_id"]]==YES){
								todoCategory.serverId=[[myArrays objectAtIndex:i] leafForKey:@"folder_id"];
								todoCategory.syncFlag=2;
								todoCategory.lastimeSync=[DateTimeUtil getTodayString];
								dbFlag=[mySqlite updTodoCategory:todoCategory];
							}
							[todoCategory release];
						}else{
							DoLog(ERROR,@"folder server reply for add has error.%d",resultCode);
							result=2;
						}
					}
					//[myArrays release];
				}
				if([[myNode leafForKey:@"fld_s_rpl_upd_count"] intValue]>0){/*處理回覆更新*/
					myArrays=[myNode objectsForKey:@"fld_s_rpl_upd"];
					for(int i=0;i<[myArrays count];i++){
						resultCode=[[[myArrays objectAtIndex:i] leafForKey:@"result"]intValue];
						//DoLog(DEBUG,@"fld_s_rpl_upd r=%d f=%@",resultCode,[[myArrays objectAtIndex:i] leafForKey:@"folder_id"]);
						if(resultCode==RP_SUCC || resultCode==RP_PERM_ERR){
							todoCategory=[self getCategoryByServerId:[[myArrays objectAtIndex:i] leafForKey:@"folder_id"] db:mySqlite.database];
							todoCategory.syncFlag=2;
							todoCategory.lastimeSync=[DateTimeUtil getTodayString];
							dbFlag=[mySqlite updTodoCategory:todoCategory];
							[todoCategory release];
							
							if(resultCode==RP_PERM_ERR){
								DoLog(ERROR,@"folder server reply for upd perm_error.%@",[[myArrays objectAtIndex:i] leafForKey:@"folder_id"]);
							}
						}else{
							DoLog(ERROR,@"folder server reply for upd has error.%d",resultCode);
							result=2;
						}
					}
					//[myArrays release];
				}
				if([[myNode leafForKey:@"fld_s_rpl_del_count"] intValue]>0){/*處理回覆刪除*/
					myArrays=[myNode objectsForKey:@"fld_s_rpl_del"];
					for(int i=0;i<[myArrays count];i++){
						resultCode=[[[myArrays objectAtIndex:i] leafForKey:@"result"]intValue];
						//DoLog(DEBUG,@"fld_s_rpl_del r=%d f=%@",resultCode,[[myArrays objectAtIndex:i] leafForKey:@"folder_id"]);
						if(resultCode==RP_SUCC || resultCode==RP_PERM_ERR){
							todoCategory=[self getCategoryByServerId:[[myArrays objectAtIndex:i] leafForKey:@"folder_id"] db:mySqlite.database];
							todoCategory.syncFlag=2;
							todoCategory.lastimeSync=[DateTimeUtil getTodayString];
							dbFlag=[mySqlite delTodoCategory:todoCategory];
							[todoCategory release];
							
							if(resultCode==RP_PERM_ERR){
								DoLog(ERROR,@"folder server reply for del perm_error.%@",[[myArrays objectAtIndex:i] leafForKey:@"folder_id"]);
							}
						}else{
							DoLog(ERROR,@"folder server reply for del has error.%d",resultCode);
							result=2;
						}
					}
					//[myArrays release];
				}
				[myNode release];
			}
			
			//DoLog(DEBUG,@"fld_s_req_count=%@",[root leafForKey:@"fld_s_req_count"]);
			if([[root leafForKey:@"fld_s_req_count"] intValue]>0){
				myNode=[root objectForKey:@"fld_s_req"];
				if([[myNode leafForKey:@"fld_s_add_count"] intValue]>0){/*處理新增需求*/
					
					TodoCategory *defaultCategory=[[TodoCategory alloc] initWithCategoryId:@"1" database:mySqlite.database];
					if([defaultCategory.folderId length]<=0){
						[mySqlite insDefaultCategory];
						defaultCategory=[[TodoCategory alloc] initWithCategoryId:@"1" database:mySqlite.database];
					}else{
						DoLog(DEBUG,@"%@ %@",defaultCategory.folderId,defaultCategory.serverId);
						/*
						if([defaultCategory.serverId longLongValue]!=0)
							defaultCategory.folderType=0;
						[mySqlite updTodoCategory:defaultCategory];
						 */
					}
					
					myArrays=[myNode objectsForKey:@"fld_s_add"];
					for(int i=0;i<[myArrays count];i++){
						todoCategory=[[TodoCategory alloc]init];
												
						todoCategory.serverId=[[myArrays objectAtIndex:i] leafForKey:@"folder_id"];
						myDatas=[[[myArrays objectAtIndex:i] objectForKey:@"folder_data"] dictionaryForChildren];
						//[myDatas objectForKey:@"parent_id"];
						todoCategory.folderName=[myDatas objectForKey:@"display_name"];
						todoCategory.folderType=[[myDatas objectForKey:@"folder_type"]integerValue];
						
						todoCategory.colorRgb=[[myDatas objectForKey:@"color_rgb"] integerValue];
						todoCategory.photoPath=[myDatas objectForKey:@"photo_path"];
						todoCategory.memo=[myDatas objectForKey:@"memo"];
						todoCategory.displayFlag=1;
						todoCategory.stateFlag=0;
						todoCategory.syncFlag=2;
						todoCategory.createdDatetime=[DateTimeUtil getTodayString];
						todoCategory.lastimeSync=[DateTimeUtil getTodayString];
						//DoLog(DEBUG,@"fld_s_add=%@ %@ %@ %@ %d %@ %@",todoCategory.folderId,todoCategory.folderName,todoCategory.photoPath,todoCategory.memo,todoCategory.colorRgb,[myDatas objectForKey:@"parent_id"],[myDatas objectForKey:@"folder_type"]);
						//dbFlag=[mySqlite insTodoCategory:todoCategory];
						
						
						//DoLog(INFO,@"%d %@ %@",todoCategory.folderType,defaultCategory.folderId,defaultCategory.serverId);
						//DoLog(INFO,@"%d %d",(todoCategory.folderType==1),([defaultCategory.serverId longLongValue]==0));
						
						if(todoCategory.folderType==1 && [defaultCategory.serverId longLongValue]==0){
							todoCategory.modifiedDatetime=[DateTimeUtil getTodayString];
							todoCategory.folderId=@"1";
							dbFlag=[mySqlite updTodoCategory:todoCategory];
							if(dbFlag==YES)
								defaultCategory.serverId=todoCategory.serverId;
						}else{
							todoCategory.folderType=0;
							dbFlag=[mySqlite insTodoCategory:todoCategory];
						}
						
						
						
						/*產生回覆資料*/
						replyDictionary=[[NSMutableDictionary alloc]init];
						[replyDictionary setObject:@"0" forKey:@"stateFlag"];
						[replyDictionary setObject:todoCategory.serverId forKey:@"serverId"];
						if(dbFlag==YES)
							[replyDictionary setObject:@"0" forKey:@"result"];
						else{
							[replyDictionary setObject:@"2" forKey:@"result"];
							result=2;
						}
						[replyData addObject:replyDictionary];
						[replyDictionary release];
						[todoCategory release];
					}
					//[myArrays release];
					[defaultCategory release];
				}
				if([[myNode leafForKey:@"fld_s_upd_count"] intValue]>0){/*處理修改需求*/
					myArrays=[myNode objectsForKey:@"fld_s_upd"];
					for(int i=0;i<[myArrays count];i++){
						todoCategory=[self getCategoryByServerId:[[myArrays objectAtIndex:i] leafForKey:@"folder_id"] db:mySqlite.database];
						//DoLog(DEBUG,@"fld_s_upd=%@ %@",[[myArrays objectAtIndex:i] leafForKey:@"folder_id"],todoCategory.folderId);
						
						if(todoCategory != nil && [todoCategory.folderId length]>0 && [todoCategory.folderId intValue]!=-1){
							
							if(todoCategory.syncFlag==2 || [syncPolicy isEqualToString:@"S"]==YES){/*已同步或server為主才能修改*/
								myDatas=[[[myArrays objectAtIndex:i] objectForKey:@"folder_data"] dictionaryForChildren];
								//[myDatas objectForKey:@"parent_id"];
								todoCategory.folderName=[myDatas objectForKey:@"display_name"];
								todoCategory.folderType=[[myDatas objectForKey:@"folder_type"] intValue];
								todoCategory.colorRgb=[[myDatas objectForKey:@"color_rgb"] intValue];
								todoCategory.photoPath=[myDatas objectForKey:@"photo_path"];
								todoCategory.memo=[myDatas objectForKey:@"memo"];
								todoCategory.stateFlag=1;
								todoCategory.modifiedDatetime=[DateTimeUtil getTodayString];
								todoCategory.lastimeSync=[DateTimeUtil getTodayString];
								DoLog(DEBUG,@"fld_s_upd=%@",[todoCategory description]);
								
								dbFlag=[mySqlite updTodoCategory:todoCategory];
								if(dbFlag==YES)
									resultCode=RP_SUCC;
								else{
									resultCode=RP_TMP_ERR;
									result=2;
								}
							}else
								resultCode=RP_POLICY;
						}else if(todoCategory!=nil && [todoCategory.folderId length]>0 && [todoCategory.folderId intValue]==-1){/*無資料*/
							resultCode=RP_PERM_ERR;
						}else{
							resultCode=RP_TMP_ERR;
							result=2;
						}
						[todoCategory release];
						
						/*產生回覆資料*/
						replyDictionary=[[NSMutableDictionary alloc]init];
						[replyDictionary setObject:@"1" forKey:@"stateFlag"];
						[replyDictionary setObject:[[myArrays objectAtIndex:i] leafForKey:@"folder_id"] forKey:@"serverId"];
						[replyDictionary setObject:[NSString stringWithFormat:@"%d",resultCode] forKey:@"result"];
						[replyData addObject:replyDictionary];
						[replyDictionary release];
					}
					//[myArrays release];
				}
				if([[myNode leafForKey:@"fld_s_del_count"] intValue]>0){/*處理刪除需求*/
					myArrays=[myNode objectsForKey:@"fld_s_del"];
					for(int i=0;i<[myArrays count];i++){
						todoCategory=[self getCategoryByServerId:[[myArrays objectAtIndex:i] leafForKey:@"folder_id"] db:mySqlite.database];
						//DoLog(DEBUG,@"fld_s_del=%@ %@",[[myArrays objectAtIndex:i] leafForKey:@"folder_id"],todoCategory.folderId);
						
						if(todoCategory != nil && [todoCategory.folderId length]>0 && [todoCategory.folderId intValue]!=-1){
							
							if(todoCategory.syncFlag==2 || [syncPolicy isEqualToString:@"S"]==YES){/*已同步或server為主才能刪除*/
								todoCategory.stateFlag=2;
								todoCategory.lastimeSync=[DateTimeUtil getTodayString];
								//DoLog(DEBUG,@"fld_s_del=%@",[todoCategory description]);
								
								dbFlag=[mySqlite delTodoCategory:todoCategory];
								if(dbFlag==YES)
									resultCode=RP_SUCC;
								else{
									resultCode=RP_TMP_ERR;
									result=2;
								}
							}else
								resultCode=RP_POLICY;
						}else if(todoCategory!=nil && [todoCategory.folderId length]>0 && [todoCategory.folderId intValue]==-1){/*無資料*/
							resultCode=RP_PERM_ERR;
						}else{
							resultCode=RP_TMP_ERR;
							result=2;
						}
						[todoCategory release];
						
						/*產生回覆資料*/
						replyDictionary=[[NSMutableDictionary alloc]init];
						[replyDictionary setObject:@"2" forKey:@"stateFlag"];
						[replyDictionary setObject:[[myArrays objectAtIndex:i] leafForKey:@"folder_id"] forKey:@"serverId"];
						[replyDictionary setObject:[NSString stringWithFormat:@"%d",resultCode] forKey:@"result"];
						[replyData addObject:replyDictionary];
						[replyDictionary release];
					}
					//[myArrays release];
				}
				[myNode release];
			}
			
			
			DoLog(DEBUG,@"i=%d session=%d has_more=%@ reply=%d ack=%@",i,session,[root leafForKey:@"has_more"],[replyData count],[root leafForKey:@"ack"]);
			if(i>=session && [replyData count]<=0){/*無需回覆且無資料需要同步結束迴圈*/
				//[self updSyncSeq:mySqlite.database sequence:syncSeq session:sessionSeq result:1];
				flag=NO;
				//result=0;
			}else
				flag=YES;
			
			[root release];
			//[data release];
			if(stopFlag==YES){
				result=5;
				break;
			}
		}while(flag==YES);
		[requestXML release];
		[replyData release];
	}
	[folderIds release];
	
	/*解鎖資料,失敗會有問題*/
	if(SQLITE_DONE != sqlite3_step(sync_category2)){
		DoLog(ERROR,@"Error update data for unlock. '%s'", sqlite3_errmsg(mySqlite.database)); 
		sqlite3_reset(sync_category2);
		return 1;
	}
	sqlite3_reset(sync_category2);
	
	//[pool release];
	return result;
}


- (void) cancel{
	[super cancel];
	stopFlag=YES;
}


- (void) main
{
	/*
    if(isSyncing==NO){
		stopFlag=NO;
		[self start];
	}
	*/
}

- (void) dealloc{
	[delegate release];
	[errorFlag release];
	[super dealloc];
}
//#modify
-(NSDictionary *) getSyncSeq:(sqlite3 *) database{
	NSString *syncSeq;
	NSString *sessionSeq;
	NSInteger syncResult;
	NSInteger count;
	NSString *logId;
	NSString *syncRange;
		
	static sqlite3_stmt *sel_sequence = nil;
	static sqlite3_stmt *ins_sequence = nil;
	static sqlite3_stmt *upd_sequence = nil;
		
	if(sel_sequence == nil){
		const char *sql1 = "SELECT log_id,sync_seq,session_seq,result,count(*),sync_range FROM sync_log order by sync_seq desc limit 1";
			
		if (sqlite3_prepare_v2(database, sql1, -1, &sel_sequence, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare select statement error='%s'.", sqlite3_errmsg(database));
			return nil;
			//return -1;
		}
	}
		
	if(ins_sequence == nil){
		const char *sql2 = "INSERT into sync_log (sync_seq,session_seq,result,start_time,sync_range) values(?,1,0,?,0)";
			
		if (sqlite3_prepare_v2(database, sql2, -1, &ins_sequence, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare insert statement error='%s'.", sqlite3_errmsg(database));
			return nil;
			//return -1;
		}
	}
	
	if (upd_sequence == nil) {
		const char *upd_sequence_sql = "update sync_log set sync_seq=?,session_seq=?,result=?,start_time=?,end_time=? where log_id=?";
		if (sqlite3_prepare_v2(database, upd_sequence_sql, -1, &upd_sequence, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare update statement error='%s'.", sqlite3_errmsg(database));
			return nil;
		}
	}
	
	if(sqlite3_step(sel_sequence) == SQLITE_ROW) {
		if((char *)sqlite3_column_text(sel_sequence,0)!=NULL)
			logId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(sel_sequence,0)];
		else
			logId=@"";
		if((char *)sqlite3_column_text(sel_sequence,1)!=NULL)
			syncSeq=[NSString stringWithUTF8String:(char*)sqlite3_column_text(sel_sequence,1)];
		else
			syncSeq=@"";
		if((char *)sqlite3_column_text(sel_sequence,2)!=NULL)
			sessionSeq=[NSString stringWithUTF8String:(char*)sqlite3_column_text(sel_sequence,2)];
		else
			sessionSeq=@"";
		syncResult=sqlite3_column_int(sel_sequence,3);
		count=sqlite3_column_int(sel_sequence,4);
		if((char *)sqlite3_column_text(sel_sequence,5)!=NULL)
			syncRange=[NSString stringWithUTF8String:(char*)sqlite3_column_text(sel_sequence,5)];
		else
			syncRange=@"0";
	}
	sqlite3_reset(sel_sequence);
		
	if(count==0 || syncResult==1){
		sessionSeq=@"1";
		
		if(count==0){
			syncSeq=@"1";
			
			sqlite3_bind_int(ins_sequence,1,[syncSeq intValue]);
			sqlite3_bind_text(ins_sequence,2,[[DateTimeUtil getTodayString] UTF8String],-1,SQLITE_TRANSIENT);
			
			if(SQLITE_DONE != sqlite3_step(ins_sequence)){
				DoLog(ERROR,@"Error insert sequence data. '%s'", sqlite3_errmsg(database));
				sqlite3_reset(ins_sequence);
				return nil;
				//return -1;
			}
			sqlite3_reset(ins_sequence);			
		}else{
			syncSeq=[NSString stringWithFormat:@"%ld",([syncSeq longLongValue]+1)];
			
			int i=1;
			sqlite3_bind_text(upd_sequence,i++,[syncSeq UTF8String],-1,SQLITE_TRANSIENT);
			sqlite3_bind_int(upd_sequence,i++,[sessionSeq intValue]);
			sqlite3_bind_int(upd_sequence,i++,0);
			sqlite3_bind_text(upd_sequence,i++,[[DateTimeUtil getTodayString] UTF8String],-1,SQLITE_TRANSIENT);
			sqlite3_bind_text(upd_sequence,i++,[[DateTimeUtil getTodayString] UTF8String],-1,SQLITE_TRANSIENT);
			
			sqlite3_bind_text(upd_sequence,i++,[logId UTF8String],-1,SQLITE_TRANSIENT);
			
			if(SQLITE_DONE != sqlite3_step(upd_sequence)){
				DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
				sqlite3_reset(upd_sequence);
				return nil;
			}
			sqlite3_reset(upd_sequence);
		}
	}
		
	NSDictionary *result=nil;
	if([syncSeq length]>0 && [sessionSeq length]>0)
		result=[NSDictionary dictionaryWithObjectsAndKeys:syncSeq,@"sync_seq",sessionSeq,@"session_seq",syncRange,@"sync_range",nil];
		
	return result;	
		
	//return [syncSeq intValue];
}
// getCountsOfSyncLog 
-(NSInteger) getCountsOfSyncLog:(sqlite3 *) database{
	NSInteger count;
	
	static sqlite3_stmt *sel_sequence = nil;
	
	if(sel_sequence == nil){
		const char *sql1 = "SELECT count(*) FROM sync_log ";
		
		if (sqlite3_prepare_v2(database, sql1, -1, &sel_sequence, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare select statement error='%s'.", sqlite3_errmsg(database));
			return -1;
		}
	}
	
	if(sqlite3_step(sel_sequence) == SQLITE_ROW) {
		count=sqlite3_column_int(sel_sequence,0);
	}else{
		count = -1;
	}
	sqlite3_reset(sel_sequence);
	return count;	
}
	
-(BOOL) updSyncSeq:(sqlite3 *) database sequence:(NSInteger) syncSeq session:(NSInteger) sessionSeq result:(NSInteger)status{
	BOOL result;
	
	static sqlite3_stmt *update_sequence = nil;
	
	if (update_sequence == nil) {
		const char *update_sequence_sql = "update sync_log set session_seq=?,result=?,end_time=? where sync_seq=?";
		if (sqlite3_prepare_v2(database, update_sequence_sql, -1, &update_sequence, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	int i=1;
	sqlite3_bind_int(update_sequence,i++,sessionSeq);
	sqlite3_bind_int(update_sequence,i++,status);
	sqlite3_bind_text(update_sequence,i++,[[DateTimeUtil getTodayString] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(update_sequence,i++,syncSeq);
		
	if(SQLITE_DONE != sqlite3_step(update_sequence)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		result=NO;
	}else
		result=YES;
	sqlite3_reset(update_sequence);
	
	return result;
}
//#add
-(BOOL) updSyncSeq:(sqlite3 *) database syncRange:(NSString*) syncRange sequence:(NSInteger) syncSeq session:(NSInteger) sessionSeq result:(NSInteger)status{
	BOOL result;
	
	static sqlite3_stmt *update_sequence = nil;
	
	if (update_sequence == nil) {
		const char *update_sequence_sql = "update sync_log set session_seq=?,result=?,end_time=?,sync_range=? where sync_seq=?";
		if (sqlite3_prepare_v2(database, update_sequence_sql, -1, &update_sequence, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	int i=1;
	sqlite3_bind_int(update_sequence,i++,sessionSeq);
	sqlite3_bind_int(update_sequence,i++,status);
	sqlite3_bind_text(update_sequence,i++,[[DateTimeUtil getTodayString] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(update_sequence,i++,[syncRange UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(update_sequence,i++,syncSeq);
	
	if(SQLITE_DONE != sqlite3_step(update_sequence)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		result=NO;
	}else
		result=YES;
	sqlite3_reset(update_sequence);
	
	return result;
}




/*
-(BOOL) resetSyncSeq:(sqlite3 *)database{
	BOOL result;
		
	static sqlite3_stmt *delete_sequence = nil;
		
	if (delete_sequence == nil) {
		const char *delete_sequence_sql = "delete from sync_log";
		if (sqlite3_prepare_v2(database, delete_sequence_sql, -1, &delete_sequence, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
		
	if(SQLITE_DONE != sqlite3_step(delete_sequence)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		result=NO;
	}else
		result=YES;
	sqlite3_reset(delete_sequence);
		
	return result;
}
*/
- (TodoCategory *) getCategoryByServerId:(NSString *) serverId db:(sqlite3 *)database{
	TodoCategory *todoCategory=nil;
	NSInteger count;
	
	static sqlite3_stmt *folder_server_id = nil;
	
	if(folder_server_id == nil){
		const char *folder_server_id_sql = "SELECT folder_id,count(*) FROM pim_cal_folder where server_id=?";
		
		if (sqlite3_prepare_v2(database, folder_server_id_sql, -1, &folder_server_id, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare statement error='%s'.", sqlite3_errmsg(database));
			return nil;
		}
	}
	
	sqlite3_bind_text(folder_server_id,1,[serverId UTF8String],-1,SQLITE_TRANSIENT);
	
	NSString *folderId;	
	if(sqlite3_step(folder_server_id) == SQLITE_ROW) {
		if((char *)sqlite3_column_text(folder_server_id,0)!=NULL)
			folderId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(folder_server_id,0)];
		count=sqlite3_column_int(folder_server_id,1);
		if(count!=1){
			todoCategory=[[TodoCategory alloc]init];
			todoCategory.folderId=@"-1";
		}else
			todoCategory = [[TodoCategory alloc]initWithCategoryId:folderId database:database ];
	} 
	sqlite3_reset(folder_server_id);
	
	return todoCategory;
}

// getResultOfRestoreLog 
-(NSInteger) getResultOfRestoreLog:(sqlite3 *) database{
	NSInteger result = -1;
	
	static sqlite3_stmt *sel_sequence = nil;
	
	if(sel_sequence == nil){
		const char *sql1 = "SELECT restore_result FROM restore_log WHERE restore_result = 1 ORDER BY restore_bgn_time desc ";
		
		if (sqlite3_prepare_v2(database, sql1, -1, &sel_sequence, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare select statement error='%s'.", sqlite3_errmsg(database));
			return -1;
		}
	}
	
	if(sqlite3_step(sel_sequence) == SQLITE_ROW) {
		result=sqlite3_column_int(sel_sequence,0);
	}else{
		result = -1;
	}
	sqlite3_reset(sel_sequence);
	return result;	
}


//-------------restore
-(NSInteger) doRestore:(MySqlite *)mySqlite{
	
	NSInteger resultFlag = 0;
	NSInteger restoreResult = [self getResultOfRestoreLog:mySqlite.database];
	DoLog(DEBUG,@"restoreResult:%d",restoreResult);
	
	// first time
	if(restoreResult == 1){
		
		
		BOOL dbResult = [mySqlite deletePimCalendarFolderRecurrence];
		if(dbResult == NO){
			resultFlag = (resultFlag | [self.errorFlag SYNC_RESTORE_DEL_FAIL]);
		}
	}
	
	return resultFlag;
}


//-------------init sync 
-(NSInteger) doInitSync:(MySqlite *)mySqlite{
	
	NSInteger resultFlag = 0;		//check the sync result
	
	//NSString *serviceId=[[NSUserDefaults standardUserDefaults] stringForKey:SERVICEID];
	//NSString *authId=[[NSUserDefaults standardUserDefaults] stringForKey:AUTHID];
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	/*
	if(serviceId==nil || [serviceId length]<=0)
		serviceId=DEFAULTSID;
	if(authId==nil || [authId length]<=0)
		authId=DEFAULTMSISDN;
	*/
	
	int initAction = 1; // init action
	
	NSInteger count = [self getCountsOfSyncLog:mySqlite.database];
	DoLog(DEBUG,@"initCount:%d",count);
	
	// first time
	if(count == 0){
		// get XML
		NSMutableData *xmlData = [NSMutableData data]; //fill out the xml data
		[xmlData appendData:[[NSString stringWithString:@"xml=<sync_init_req>"] dataUsingEncoding:NSUTF8StringEncoding]];
		[xmlData appendData:[[NSString stringWithFormat:@"<auth_id>%@</auth_id>", authId] dataUsingEncoding:NSUTF8StringEncoding]];
		[xmlData appendData:[[NSString stringWithFormat:@"<service_id>%@</service_id>", serviceId] dataUsingEncoding:NSUTF8StringEncoding]];
		[xmlData appendData:[[NSString stringWithFormat:@"<action>%d</action>", initAction] dataUsingEncoding:NSUTF8StringEncoding]]; 
		[xmlData appendData:[[NSString stringWithString:@"</sync_init_req>"] dataUsingEncoding:NSUTF8StringEncoding]];
		NSString    *str = [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] autorelease];
		DoLog(DEBUG,@"xml: %@",str);
		
		// http request
		//creating the url request:
		NSURL *cgiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",SYNCINITURL,[DateTimeUtil getUrlDateString]]];
		NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:cgiUrl];
		//adding header information:
		[postRequest setHTTPMethod:@"POST"];
		[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
		
		[InterfaceUtil setHeader:postRequest];
		
		//setting up the body:
		NSMutableData *postBody = [NSMutableData data];
		[postBody appendData:xmlData];
		[postRequest setHTTPBody:postBody];
		
		NSHTTPURLResponse * returnResponse = nil;
		NSError *returnError = nil;
		NSData *returnData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
		int statusCode = returnResponse.statusCode;
		DoLog(DEBUG,@"statusCode:%d",statusCode);
		DoLog(DEBUG,@"%@",[[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease]);
		//if http request fail, end sync 
		if(statusCode != 200){
			resultFlag = (resultFlag | [self.errorFlag SYNC_HTTP_FAIL]);
		}
		
		TreeNode *root = [[XMLParser sharedInstance] parseXMLFromData:returnData];
		// return result ==1(Fail), end sync
		if([root leafForKey:@"result"] ==nil || [[root leafForKey:@"result"] intValue] == 1){
			resultFlag = (resultFlag | [self.errorFlag SYNC_RESULT_FAIL]);
		}
		
	}
	
	return resultFlag;
}







//-------------recurrence sync

//#modify
-(NSInteger) doRecurrenceSync:(MySqlite *)mySqlite seq:(NSInteger)sId{
	
	
	int limit = 5;			//the max number of recoreds for a session
	int offset = 0;			//skip the fail request
	
	int roopLimit = 100000/limit;	//to break the roop if ack is not returen
	int roopCount = 0;
	
	BOOL hasMoreDataClient = YES; //value of has_more tag of client
	BOOL hasMoreDataServer = YES; //valus of has_more tag of client
	BOOL ack = NO;
	
	NSInteger syncSeq = 0;		//sync sequence
	NSInteger sessionSeq = 0;	//session sequence
	NSInteger resultFlag = 0;		//check the sync result
	
	limit=[ProfileUtil integerForKey:MAXSYNCAMOUNT];
	if(limit<=0)
		limit=DEFAULTMAXSYNC;
	
	//sync policy C:client S:server
	//NSString *syncPolicy=[[NSUserDefaults standardUserDefaults] objectForKey:SYNCRULE]; 
	NSString *syncPolicy=[ProfileUtil stringForKey:SYNCRULE];
	if(syncPolicy==nil || [syncPolicy length]<=0)
		syncPolicy=@"C";
	
	
	
	//keep unsync server in dictionary for collision detection
	NSMutableDictionary *collisionDictionary = [[NSMutableDictionary alloc] init]; 
	if([syncPolicy compare:@"C"] == 0){
		NSArray *keyTmp = [mySqlite getRecurrenceSyncServerId];
		for(int i=0;i<[keyTmp count]; i++){
			//DoLog(DEBUG,@"key: %@",[keyTmp objectAtIndex:i]);
			[collisionDictionary setObject:@"1" forKey:[keyTmp objectAtIndex:i]];
		}
	}
	
	NSDictionary *tmpDictionary=[self getSyncSeq:mySqlite.database];//get sync_seq
	if(tmpDictionary!=nil){
		
		syncSeq=[[tmpDictionary objectForKey:@"sync_seq"] intValue];
		sessionSeq=[[tmpDictionary objectForKey:@"session_seq"] intValue];
		
		//set sync range by setting
		NSDate *now = [NSDate date];
		//NSCalendar *cal = [NSCalendar currentCalendar];
		//NSDateComponents *comp= [[NSDateComponents alloc] init];
		NSString *nowDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		NSString *syncBeginDateTimeString =@"00000000000000";
		
		//NSString *tmpString=[[NSUserDefaults standardUserDefaults] stringForKey:KEEPRULE];
		/*NSString *tmpString=[ProfileUtil stringForKey:KEEPRULE];
		if(tmpString==nil)
			tmpString=@"9";
		if([tmpString integerValue] == 5){
			[comp setMonth:-24];
			now = [cal dateByAddingComponents:comp toDate:now options:0];
			syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		}else if ([tmpString integerValue] == 4){
			[comp setMonth:-12];
			now = [cal dateByAddingComponents:comp toDate:now options:0];
			syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		}else if ([tmpString integerValue] == 3){
			[comp setMonth:-6];
			now = [cal dateByAddingComponents:comp toDate:now options:0];
			syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		}else if ([tmpString integerValue] == 2){
			[comp setMonth:-3];
			now = [cal dateByAddingComponents:comp toDate:now options:0];
			syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		}else if ([tmpString integerValue] == 1){
			[comp setMonth:-1];
			now = [cal dateByAddingComponents:comp toDate:now options:0];
			syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		}
		[comp release];*/
		DoLog(DEBUG,@"start:%@, end:%@",syncBeginDateTimeString,nowDateTimeString);
		
		NSMutableData *respData = [NSMutableData data]; //fill out the xml data of tag con_c_rpl 
		
		int rplyAddCount = 0; //count the rplyAdd
		int rplyUpdCount = 0; //count the rplyUpd
		int rplyDelCount = 0; //count the rplyDel
		
		//client has unsync data , server has unsync data ,ack not return
		while (hasMoreDataClient || hasMoreDataServer || !ack ){
			
			// *Step 1: get primary key
			NSArray *pkArray = nil;
			if(hasMoreDataClient){
				pkArray = [mySqlite getRecurrenceSyncCalendarIdByStartTime:syncBeginDateTimeString LastWrite:nowDateTimeString Limit: limit offset: offset];
				//DoLog(DEBUG,@"count: %d",[pkArray count]);
			}
			//DoLog(DEBUG,@"count: %d,limit:%d, offset:%d ",[pkArray count],limit,offset);
			
			if( [pkArray count] == 0){
				hasMoreDataClient = NO;
			}
			
			NSInteger respCount=(rplyAddCount+rplyUpdCount+rplyDelCount);// >0: client has reply data
			
			// *Step 2: gen XML
			NSData *xmlData = [self setRecurrenceRequest:pkArray setContentResponse:respData respCount:respCount syncSeq:syncSeq sessionSeq:sessionSeq hasMore:hasMoreDataClient database:mySqlite];
			NSString    *str = [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] autorelease];
			DoLog(DEBUG,@"xml: %@",str);
			
			
			// *Step 3: http request
			//creating the url request:
			NSURL *cgiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",RECURRENCESYNCURL,[DateTimeUtil getUrlDateString]]];
			NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:cgiUrl];
			
			//adding header information:
			[postRequest setHTTPMethod:@"POST"];
			[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
			
			[InterfaceUtil setHeader:postRequest];
			
			//setting up the body:
			NSMutableData *postBody = [NSMutableData data];
			[postBody appendData:xmlData];
			//[postBody appendData:[[NSString stringWithString:@"xml="] dataUsingEncoding:NSUTF8StringEncoding]];
			//[postBody appendData:xmlData];
			//NSData *data = [[NSData alloc] initWithData:[@"xml=<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>3</con_s_req_count><con_s_req><con_s_add_count>1</con_s_add_count><con_s_add><server_id>sId</server_id><application_data><calendar_id>aId</calendar_id></application_data></con_s_add></con_s_req><has_more_data>no</has_more_data><ack></ack></content_sync_rsp>" dataUsingEncoding:NSUTF8StringEncoding]];
			//[postBody appendData:data];
			//[data release];
			[postRequest setHTTPBody:postBody];
			
			NSHTTPURLResponse * returnResponse = nil;
			NSError *returnError = nil;
			NSData *returnData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
			int statusCode = returnResponse.statusCode;
			DoLog(DEBUG,@"statusCode:%d",statusCode);
			DoLog(INFO,@"%@",[[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease]);
			//if http request fail, end sync 
			if(statusCode != 200){
				resultFlag == (resultFlag | [self.errorFlag SYNC_HTTP_FAIL]);
				break;
			}
			
			
			// *Step 4: parse reponse
			
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>3</con_s_req_count><con_s_req><con_s_add_count>1</con_s_add_count><con_s_add><server_id>sId</server_id><application_data><calendar_id>aId</calendar_id></application_data></con_s_add></con_s_req><has_more_data>no</has_more_data><ack></ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>6</con_s_req_count><con_s_req><con_s_ add_count>1</con_s_ add_count>< con_s_add><server_id>123</server_id><calendar_data><subject>subject1</subject></calendar_data></con_s_add></con_s_req><con_s_reply_count>5</con_s_reply_count><con_s_reply></con_s_reply><has_more_data>111</has_more_data><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>0</con_s_req_count><con_s_req><con_s_add_count>add1</con_s_add_count><con_s_add><server_id>sid</server_id><calendar_data><folder_id>FFF</folder_id><subject>sususussu</subject></calendar_data></con_s_add><con_s_add><server_id>sid</server_id><calendar_data><folder_id>FFF</folder_id><subject>ssssssuuuuuu</subject></calendar_data></con_s_add></con_s_req><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_rpl_count>1</con_s_rpl_count><con_s_rpl><con_s_rpl_add_count>1</con_s_rpl_add_count><con_s_rpl_add><client_id>1</client_id><server_id>555</server_id><result>0</result></con_s_rpl_add></con_s_rpl><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//upd:data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_rpl_count>1</con_s_rpl_count><con_s_rpl><con_s_rpl_upd_count>1</con_s_rpl_upd_count><con_s_rpl_upd><client_id>1</client_id><server_id>555</server_id><result>0</result></con_s_rpl_upd></con_s_rpl><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_rpl_count>1</con_s_rpl_count><con_s_rpl><con_s_rpl_del_count>1</con_s_rpl_del_count><con_s_rpl_del><client_id>1</client_id><server_id>555</server_id><result>0</result></con_s_rpl_del></con_s_rpl><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>1</con_s_req_count><con_s_req><con_s_add_count>1</con_s_add_count><con_s_add><server_id>15</server_id><calendar_data><folder_id>0</folder_id><create_time>20100329000000</create_time><cal_type>0</cal_type><all_day_event>1</all_day_event><time_zone>0</time_zone><busy_status>0</busy_status><organizer_name>organizer_name</organizer_name><organizer_email>organizer_email</organizer_email><end_time>20100331200000</end_time><location>0</location><reminder>0</reminder><sensitivity>0</sensitivity><subject>subjectadd</subject><start_time>20100331100000</start_time><uid>0</uid><meeting_status>0</meeting_status><disallow_newtime>0</disallow_newtime><response_requested>0</response_requested><appointment_replytime>0</appointment_replytime><response_type>0</response_type><cal_recurrence_id>0</cal_recurrence_id><is_exception>0</is_exception><note_id>0</note_id><event_desc>0</event_desc><memo>0</memo><reminder_dismiss>0</reminder_dismiss><reminder_start_time>0</reminder_start_time></calendar_data></con_s_add></con_s_req><has_more>N</has_more><ack>1</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//upd data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>1</con_s_req_count><con_s_req><con_s_upd_count>1</con_s_upd_count><con_s_upd><server_id>15</server_id><calendar_data><folder_id>0</folder_id><create_time>20100329000000</create_time><cal_type>0</cal_type><all_day_event>1</all_day_event><time_zone>0</time_zone><busy_status>0</busy_status><organizer_name>organizer_name</organizer_name><organizer_email>organizer_email</organizer_email><end_time>20100331200000</end_time><location>0</location><reminder>0</reminder><sensitivity>0</sensitivity><subject>subjectmodify</subject><start_time>20100331100000</start_time><uid>0</uid><meeting_status>0</meeting_status><disallow_newtime>0</disallow_newtime><response_requested>0</response_requested><appointment_replytime>0</appointment_replytime><response_type>0</response_type><cal_recurrence_id>0</cal_recurrence_id><is_exception>0</is_exception><note_id>0</note_id><event_desc>0</event_desc><memo>0</memo><reminder_dismiss>0</reminder_dismiss><reminder_start_time>0</reminder_start_time></calendar_data></con_s_upd></con_s_req><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>1</con_s_req_count><con_s_req><con_s_del_count>1</con_s_del_count><con_s_del><server_id>15</server_id><calendar_data><folder_id>0</folder_id><create_time>20100329000000</create_time><cal_type>0</cal_type><all_day_event>1</all_day_event><time_zone>0</time_zone><busy_status>0</busy_status><organizer_name>organizer_name</organizer_name><organizer_email>organizer_email</organizer_email><end_time>20100331200000</end_time><location>0</location><reminder>0</reminder><sensitivity>0</sensitivity><subject>subjectmodify</subject><start_time>20100331100000</start_time><uid>0</uid><meeting_status>0</meeting_status><disallow_newtime>0</disallow_newtime><response_requested>0</response_requested><appointment_replytime>0</appointment_replytime><response_type>0</response_type><cal_recurrence_id>0</cal_recurrence_id><is_exception>0</is_exception><note_id>0</note_id><event_desc>0</event_desc><memo>0</memo><reminder_dismiss>0</reminder_dismiss><reminder_start_time>0</reminder_start_time></calendar_data></con_s_del></con_s_req><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//TreeNode *root = [[XMLParser sharedInstance] parseXMLFromData:data];
			
			TreeNode *root = [[XMLParser sharedInstance] parseXMLFromData:returnData];
			
			// return result ==1(Fail), end sync
			if([root leafForKey:@"result"] ==nil || [[root leafForKey:@"result"] intValue] == 1){
				resultFlag = (resultFlag | [self.errorFlag SYNC_RESULT_FAIL]);
				break;
			}
			
			//DoLog(DEBUG,@"result:%@",[root leafForKey:@"result"]);
			//DoLog(DEBUG,@"sync_seq:%@",[root leafForKey:@"sync_seq"]);
			//DoLog(DEBUG,@"session_seq:%@",[root leafForKey:@"session_seq"]);
			//DoLog(DEBUG,@"ack:%@",[root leafForKey:@"ack"]);
			//DoLog(DEBUG,@"has_more:%@",[root leafForKey:@"has_more"]);
			//DoLog(DEBUG,@"has_more_client:%d",hasMoreDataClient);
			
			if([root leafForKey:@"has_more"] != nil && [[root leafForKey:@"has_more"] compare:@"Y"] == 0){
				hasMoreDataServer = YES;
			}else{
				hasMoreDataServer = NO;
			}
			
			//DoLog(DEBUG,@"con_s_rpl_count:%@",[root leafForKey:@"con_s_rpl_count"]);
			int rplCount = [[root leafForKey:@"recur_s_rpl_count"] intValue];
			if(rplCount > 0){
				TreeNode *myServerResponse=[root objectForKey:@"recur_s_rpl"];
				
				//response ADD part result
				//DoLog(DEBUG,@"con_s_rpl_add_count:%@",[myServerResponse leafForKey:@"con_s_rpl_add_count"]);
				int addCount = [[myServerResponse leafForKey:@"recur_s_rpl_add_count"] intValue];
				if(addCount > 0){
					NSMutableArray *myAdd=[myServerResponse objectsForKey:@"recur_s_rpl_add"];
					for(int i=0;i<[myAdd count];i++){
						//DoLog(DEBUG,@"ADD reply %d -----------",i);
						//DoLog(DEBUG,@"client_id:%@",[[myAdd objectAtIndex:i] leafForKey:@"client_id"]);
						//DoLog(DEBUG,@"server_id:%@",[[myAdd objectAtIndex:i] leafForKey:@"server_id"]);
						//DoLog(DEBUG,@"result:%@",[[myAdd objectAtIndex:i] leafForKey:@"result"]);
						//DBACTION
						if([[myAdd objectAtIndex:i] leafForKey:@"result"]!=nil){
							NSString *clientId = [[myAdd objectAtIndex:i] leafForKey:@"client_id"];
							NSString *serverId = [[myAdd objectAtIndex:i] leafForKey:@"server_id"];
							NSString *r = [[myAdd objectAtIndex:i] leafForKey:@"result"];
							if([r integerValue] == 0){
								[mySqlite updatePimCalendarSetSyncFlag:2 ServerId:serverId SyncId:[NSString stringWithFormat:@"%d",syncSeq] WhereCalendarId:clientId];
							}else if([r integerValue] == 1){
								//conflict do nothing
							}else if([r integerValue] == 2){
								offset++;
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_ADD_FAIL_2]);
							}else if([r integerValue] == 3){
								[mySqlite updatePimCalendarSetSyncFlag:2 ServerId:serverId SyncId:[NSString stringWithFormat:@"%d",syncSeq] WhereCalendarId:clientId];
								[mySqlite updatePimCalendarSetSyncFlag:2 SyncId:[NSString stringWithFormat:@"%d",syncSeq] WhereCalRecurrenceId:clientId];
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_ADD_FAIL_3]);
							}else{
								offset++;
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_ADD_FAIL_O]);
							}
						}
					}
				}
				
				//response DEL part result
				//DoLog(DEBUG,@"con_s_rpl_del_count:%@",[myServerResponse leafForKey:@"con_s_rpl_del_count"]);
				int delCount = [[myServerResponse leafForKey:@"recur_s_rpl_del_count"] intValue];
				if(delCount > 0){
					NSMutableArray *myDel=[myServerResponse objectsForKey:@"recur_s_rpl_del"];
					for(int i=0;i<[myDel count];i++){
						//DoLog(DEBUG,@"DEL reply %d -----------",i);
						//DoLog(DEBUG,@"server_id:%@",[[myDel objectAtIndex:i] leafForKey:@"server_id"]);
						//DoLog(DEBUG,@"result:%@",[[myDel objectAtIndex:i] leafForKey:@"result"]);
						//DBACTION
						if([[myDel objectAtIndex:i] leafForKey:@"result"]!=nil){
							NSString *serverId = [[myDel objectAtIndex:i] leafForKey:@"server_id"];
							NSString *r = [[myDel objectAtIndex:i] leafForKey:@"result"];
							TodoEvent *todoEvent = [[TodoEvent alloc] initWithServerId:serverId database:mySqlite.database];
							if([r integerValue] == 0){
								[mySqlite deleteRecurrenceEventByCalendarId:todoEvent.calendarId];
							}else if([r integerValue] == 1){
								// conflict
							}else if([r integerValue] == 2){
								offset++;
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_DEL_FAIL_2]);
							}else if([r integerValue] == 3){
								[mySqlite updatePimCalendarSetSyncFlag:2 SyncId:[NSString stringWithFormat:@"%d",syncSeq] WhereServerId:serverId];
								TodoEvent *tmpEvent = [[TodoEvent alloc] initWithServerId:serverId database:mySqlite.database];
								[mySqlite updatePimCalendarSetSyncFlag:2 SyncId:[NSString stringWithFormat:@"%d",syncSeq] WhereCalRecurrenceId:tmpEvent.calendarId];
								[tmpEvent release];
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_DEL_FAIL_3]);
							}else{
								offset++;
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_DEL_FAIL_O]);
							}
							[todoEvent release];
						}
					}
				}
			}
			
			// *Step 5: do server request
			
			//reset respData
			respData = [NSMutableData data];
			
			//reset count
			rplyAddCount=0;
			rplyUpdCount=0;
			rplyDelCount=0;
			
			//DoLog(DEBUG,@"con_s_req_count:%@",[root leafForKey:@"con_s_req_count"]);
			int sReqCount = [[root leafForKey:@"recur_s_req_count"] intValue];
			if(sReqCount > 0){
				TreeNode *myServerRequest=[root objectForKey:@"recur_s_req"];
				NSMutableDictionary *myData ;
				
				//add part
				//DoLog(DEBUG,@"con_s_add_count:%@",[myServerRequest leafForKey:@"con_s_add_count"]);
				int sAddCount = [[myServerRequest leafForKey:@"recur_s_add_count"] intValue];
				if(sAddCount > 0){
					NSMutableArray *myAddReq=[myServerRequest objectsForKey:@"recur_s_add"];
					
					for(int i=0;i<[myAddReq count];i++){
						
						//DoLog(DEBUG,@"ADD req %d -----------",i);
						//DoLog(DEBUG,@"server_id:%@",[[myAddReq objectAtIndex:i] leafForKey:@"server_id"]);
						NSString *myServerId = [[myAddReq objectAtIndex:i] leafForKey:@"server_id"];
						myData=[[[myAddReq objectAtIndex:i] objectForKey:@"calendar_data"] dictionaryForChildren];
						
						//DoLog(DEBUG,@"folder_id:%@",[myData objectForKey:@"folder_id"]);
						//DoLog(DEBUG,@"create_time:%@",[myData objectForKey:@"create_time"]);
						//DoLog(DEBUG,@"all_day_event:%@",[myData objectForKey:@"all_day_event"]);
						//DoLog(DEBUG,@"time_zone:%@",[myData objectForKey:@"time_zone"]);
						//DoLog(DEBUG,@"busy_status:%@",[myData objectForKey:@"busy_status"]);
						//DoLog(DEBUG,@"organizer_name:%@",[myData objectForKey:@"organizer_name"]);
						//DoLog(DEBUG,@"organizer_email:%@",[myData objectForKey:@"organizer_email"]);
						//DoLog(DEBUG,@"end_time:%@",[myData objectForKey:@"end_time"]);
						//DoLog(DEBUG,@"location:%@",[myData objectForKey:@"location"]);
						//DoLog(DEBUG,@"reminder:%@",[myData objectForKey:@"reminder"]);
						//DoLog(DEBUG,@"sensitivity:%@",[myData objectForKey:@"sensitivity"]);
						//DoLog(DEBUG,@"subject:%@",[myData objectForKey:@"subject"]);
						//DoLog(DEBUG,@"start_time:%@",[myData objectForKey:@"start_time"]);
						//DoLog(DEBUG,@"uid:%@",[myData objectForKey:@"uid"]);
						//DoLog(DEBUG,@"disallow_newtime:%@",[myData objectForKey:@"disallow_newtime"]);
						//DoLog(DEBUG,@"response_requested:%@",[myData objectForKey:@"response_requested"]);
						//DoLog(DEBUG,@"appointment_replytime:%@",[myData objectForKey:@"appointment_replytime"]);
						//DoLog(DEBUG,@"response_type:%@",[myData objectForKey:@"response_type"]);
						//DoLog(DEBUG,@"cal_recurrence_id:%@",[myData objectForKey:@"cal_recurrence_id"]);
						//DoLog(DEBUG,@"is_exception:%@",[myData objectForKey:@"is_exception"]);
						//DoLog(DEBUG,@"note_id:%@",[myData objectForKey:@"note_id"]);
						//DoLog(DEBUG,@"event_desc:%@",[myData objectForKey:@"event_desc"]);
						//DoLog(DEBUG,@"memo:%@",[myData objectForKey:@"memo"]);
						//DoLog(DEBUG,@"reminder_dismiss:%@",[myData objectForKey:@"reminder_dismiss"]);
						//DoLog(DEBUG,@"reminder_start_time:%@",[myData objectForKey:@"reminder_start_time"]);
						//DoLog(DEBUG,@"attach_file_count:%@",[myData objectForKey:@"attach_file_count"]);
						
						//TreeNode *fileNode = [myData objectForKey:@"attach_file"];
						//DoLog(DEBUG,@"file_size:%@",[fileNode leafForKey:@"file_size"]);
						//DoLog(DEBUG,@"file_type:%@",[fileNode leafForKey:@"file_type"]);
						//DoLog(DEBUG,@"file_content:%@",[fileNode leafForKey:@"file_content"]);
						
						
						//DBACTION
						TodoEvent *todoEvent = [[TodoEvent alloc] init];
						EventRecurrence *eventRecurrence = [[EventRecurrence alloc] init];
						TodoCategory *todoCategory = [[TodoCategory alloc] initWithCategoryServerId:[myData objectForKey:@"folder_id"] database:mySqlite.database];
						
						[todoEvent setUserId:@"777"];
						[todoEvent setFolderId:todoCategory.folderId];
						[todoEvent setLastWrite:[DateTimeUtil getTodayString]];
						[todoEvent setIsSynced:2];
						[todoEvent setStatus:1];
						[todoEvent setNeedSync:2];
						[todoEvent setTimeZone:[[myData objectForKey:@"time_zone"] integerValue]];
						[todoEvent setAllDayEvent:[[myData objectForKey:@"all_day_event"] integerValue]];
						[todoEvent setBusyStatus:[[myData objectForKey:@"busy_status"] integerValue]];
						[todoEvent setOrganizerName:[myData objectForKey:@"organizer_name"]];
						[todoEvent setOrganizerEmail:[myData objectForKey:@"organizer_email"]];
						[todoEvent setDtStamp:[myData objectForKey:@"create_time"]];
						[todoEvent setEndTime:[myData objectForKey:@"end_time"]];			
						[todoEvent setLocation:[myData objectForKey:@"location"]];
						[todoEvent setReminder:[[myData objectForKey:@"reminder"] integerValue]];
						[todoEvent setSensitivity:[[myData objectForKey:@"sensitivity"] integerValue]];
						[todoEvent setSubject:[myData objectForKey:@"subject"]];
						[todoEvent setEventDesc:[myData objectForKey:@"event_desc"]];
						[todoEvent setStartTime:[myData objectForKey:@"start_time"]];
						[todoEvent setUid:[myData objectForKey:@"uid"]];
						[todoEvent setMeetingStatus:0];
						[todoEvent setDisallowNewTimeProposal:[[myData objectForKey:@"disallow_newtime"] integerValue]];
						[todoEvent setResponseRequested:[[myData objectForKey:@"response_requested"] integerValue]];
						[todoEvent setAppointmentReplyTime:[myData objectForKey:@"appointment_replytime"]];
						[todoEvent setResponseType:[[myData objectForKey:@"response_type"] integerValue]];
						[todoEvent setCalRecurrenceId:[myData objectForKey:@"cal_recurrence_id"]];
						[todoEvent setIsException:[[myData objectForKey:@"is_exception"] integerValue]];
						[todoEvent setDeleted:0];
						[todoEvent setPicturePath:@"PicturePath"];
						[todoEvent setVoicePath:@"VoicePath"];
						[todoEvent setNoteId:[myData objectForKey:@"note_id"]];
						[todoEvent setMemo:[myData objectForKey:@"memo"]];
						[todoEvent setReminderDismiss:[[myData objectForKey:@"reminder_dismiss"] integerValue]];
						[todoEvent setReminderStartTime:[myData objectForKey:@"reminder_start_time"]];
						[todoEvent setServerId:myServerId];
						[todoEvent setCalType:[[myData objectForKey:@"cal_type"]integerValue]];
						[todoEvent setSyncId:[NSString stringWithFormat:@"%d",syncSeq]];
						
						
						myData=[[[myAddReq objectAtIndex:i] objectForKey:@"recurrence_data"] dictionaryForChildren];
						[eventRecurrence setCalendarId:@""];
						[eventRecurrence setType:[[myData objectForKey:@"recurrence_type"] integerValue]];
						[eventRecurrence setOccurrences:[[myData objectForKey:@"occurrences"] integerValue]];
						[eventRecurrence setInterval:[[myData objectForKey:@"cal_interval"] integerValue]];
						[eventRecurrence setWeekOfMonth:[[myData objectForKey:@"week_of_month"] integerValue]];
						[eventRecurrence setDayOfWeek:[[myData objectForKey:@"day_of_week"] integerValue]];
						[eventRecurrence setMonthOfYear:[[myData objectForKey:@"month_of_year"] integerValue]];
						[eventRecurrence setUntil:[myData objectForKey:@"until_datetime"]];
						[eventRecurrence setDayOfMonth:[[myData objectForKey:@"day_of_month"] integerValue]];
						[eventRecurrence setStart:[myData objectForKey:@"start_datetime"]];
						[eventRecurrence setFolderId:todoCategory.folderId];
						
						BOOL result = YES;
						if ([mySqlite checkExistOfServerId:myServerId] ==NO){
							result = [mySqlite insToEvent:todoEvent EventRecurrence:eventRecurrence Database:mySqlite.database];
						}
						NSString *r = @"0";
						if(result == NO){
							r = @"2";
							resultFlag = (resultFlag | [self.errorFlag SYNC_REQ_ADD_FAIL]);
						}
						
						TodoEvent *tmpEvent = [[TodoEvent alloc] initWithServerId:myServerId database:mySqlite.database];
						if(tmpEvent != nil){
							[respData appendData:[[NSString stringWithFormat:@"<recur_c_rpl_add><client_id>%@</client_id><server_id>%@</server_id><result>%@</result></recur_c_rpl_add>",tmpEvent.calendarId,myServerId,r] dataUsingEncoding:NSUTF8StringEncoding]];
						}else{
							[respData appendData:[[NSString stringWithFormat:@"<recur_c_rpl_add><client_id></client_id><server_id>%@</server_id><result>%@</result></recur_c_rpl_add>",myServerId,r] dataUsingEncoding:NSUTF8StringEncoding]];
						}
						rplyAddCount++;
						[tmpEvent release];
						[todoEvent release];
						[todoCategory release];
						[eventRecurrence release];
					}
				}
				
				
				//DoLog(DEBUG,@"con_s_del_count:%@",[myServerRequest leafForKey:@"con_s_del_count"]);
				int sDelCount = [[myServerRequest leafForKey:@"recur_s_del_count"] intValue];
				if(sDelCount > 0){
					NSMutableArray *myDelReq=[myServerRequest objectsForKey:@"recur_s_del"];
					for(int i=0;i<[myDelReq count];i++){
						//DoLog(DEBUG,@"server_id:%@",[[myDelReq objectAtIndex:i] leafForKey:@"server_id"]);
						NSString *myServerId = [[myDelReq objectAtIndex:i] leafForKey:@"server_id"];
						
						//DBACTION
						NSString *r = @"0";
						if([collisionDictionary objectForKey:myServerId] == nil){
							//do delete
							TodoEvent *todoEvent = [[TodoEvent alloc] initWithServerId:myServerId database:mySqlite.database];
							BOOL dbResult = [mySqlite deleteRecurrenceEventByCalendarId:todoEvent.calendarId];
							if(dbResult == NO){
								r = @"2";
								resultFlag = (resultFlag | [self.errorFlag SYNC_REQ_DEL_FAIL]);
							}
							[todoEvent release];
						}else{
							//collision
							r = @"1";
						}
						[respData appendData:[[NSString stringWithFormat:@"<recur_c_rpl_del><server_id>%@</server_id><result>%@</result></recur_c_rpl_del>",myServerId,r] dataUsingEncoding:NSUTF8StringEncoding]];
						rplyDelCount++;
					}
				}
				[respData appendData:[[NSString stringWithFormat:@"<recur_c_rpl_add_count>%d</recur_c_rpl_add_count>", rplyAddCount] dataUsingEncoding:NSUTF8StringEncoding]];
				[respData appendData:[[NSString stringWithFormat:@"<recur_c_rpl_del_count>%d</recur_c_rpl_del_count>", rplyDelCount] dataUsingEncoding:NSUTF8StringEncoding]];
				
				
			}
			
			sessionSeq++;
			
			if([root leafForKey:@"ack"] != nil && [[root leafForKey:@"ack"] compare:@"Y"] == 0){
				//DoLog(DEBUG,@"ack:%@",[root leafForKey:@"ack"]);
				ack = YES;
				break;
			}else{
				ack = NO;
			}
			//check loop limit
			roopCount++;
			if(roopCount> roopLimit){
				resultFlag = (resultFlag | [self.errorFlag SYNC_ROOP_LIMIT]);
				break;
			}
			
			if(stopFlag==YES){
				resultFlag = (resultFlag | [self.errorFlag SYNC_USER_STOP]);
				break;
			}
		}
	}else{
		resultFlag = (resultFlag | [self.errorFlag SYNC_SYNCSEQ_FAIL]);
	}
	
	/*
	if(resultFlag == 0){
		[self updSyncSeq:mySqlite.database sequence:syncSeq session:sessionSeq result:1];
	}
	*/
	
	[collisionDictionary release];
	return resultFlag;
}


- (NSData *) setRecurrenceRequest:(NSArray *) iPkArray setContentResponse:(NSMutableData *)iRespData respCount:(NSInteger)respCount syncSeq:(NSInteger)syncSeq sessionSeq:(NSInteger)sessionSeq hasMore:(BOOL)hasMoreDataClient database:(MySqlite *)mySqlite {
	
	NSMutableData *xmlData = [NSMutableData data];
	
	//NSString *serviceId=[[NSUserDefaults standardUserDefaults] stringForKey:SERVICEID];
	//NSString *authId=[[NSUserDefaults standardUserDefaults] stringForKey:AUTHID];
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	/*
	if(serviceId==nil || [serviceId length]<=0)
		serviceId=DEFAULTSID;
	if(authId==nil || [authId length]<=0)
		authId=DEFAULTMSISDN;
	 */
	//#define POLICY_SRV    "S"    /* 同步機制:衝突時以server為主 */
	//#define POLICY_CLI    "C"    /* 同步機制:衝突時以client為主 */
	//NSString *syncPolicy=[[NSUserDefaults standardUserDefaults] objectForKey:SYNCRULE];
	NSString *syncPolicy=[ProfileUtil stringForKey:SYNCRULE];
	if(syncPolicy==nil || [syncPolicy length]<=0)
		syncPolicy=@"C";
	
	
	int recur_c_req_count = 0;
	int recur_c_add_count = 0;
	int recur_c_del_count = 0;
	//int recur_c_upd_count = 0;
	
	int recur_c_rpl_count = 0;
	//int recur_c_rpl_add_count = 0;
	//int recur_c_rpl_del_count = 0;
	//int recur_c_rpl_upd_count = 0;
	
	[xmlData appendData:[[NSString stringWithString:@"xml=<recurrence_sync_req>"] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<auth_id>%@</auth_id>", authId] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<service_id>%@</service_id>", serviceId] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<sync_seq>%d</sync_seq>", syncSeq] dataUsingEncoding:NSUTF8StringEncoding]]; 
	[xmlData appendData:[[NSString stringWithFormat:@"<session_seq>%d</session_seq>", sessionSeq] dataUsingEncoding:NSUTF8StringEncoding]];	
	[xmlData appendData:[[NSString stringWithFormat:@"<sync_policy>%@</sync_policy>", syncPolicy] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	
	/* con_c_rpl_count 的數目 */
	if (respCount > 0)
		recur_c_rpl_count = 1;
	
	[xmlData appendData:[[NSString stringWithFormat:@"<recur_c_rpl_count>%d</recur_c_rpl_count>", recur_c_rpl_count] dataUsingEncoding:NSUTF8StringEncoding]];
	
	/* 設定 con_c_rpl 的內容 */
	[xmlData appendData:[[NSString stringWithFormat:@"<recur_c_rpl>"] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:iRespData];	
	[xmlData appendData:[[NSString stringWithFormat:@"</recur_c_rpl>"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	
	// con_c_req_count 的數目
	if ([iPkArray count] > 0)
		recur_c_req_count = 1;
	
	[xmlData appendData:[[NSString stringWithFormat:@"<recur_c_req_count>%d</recur_c_req_count>", recur_c_req_count] dataUsingEncoding:NSUTF8StringEncoding]];
	
	/*設定 con_c_req 的內容*/
	[xmlData appendData:[[NSString stringWithFormat:@"<recur_c_req>"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	for(int i=0; i<[iPkArray count]; i++)
	{
		TodoEvent *todoEvent = [[TodoEvent alloc] initWithEventId:[iPkArray objectAtIndex:i] database:mySqlite.database];
		TodoCategory *todoCategory = [[TodoCategory alloc] initWithCategoryId:todoEvent.folderId database:mySqlite.database];
		EventRecurrence *eventRecurrence = [[EventRecurrence alloc] initWithId:todoEvent.calendarId database:mySqlite.database];
		
		DoLog(DEBUG,@"subject:%@",todoEvent.subject);
		DoLog(DEBUG,@"status:%d",todoEvent.status);
		DoLog(DEBUG,@"todoEvent:folderId:%@",todoEvent.folderId);
		DoLog(DEBUG,@"todoCategory.serverId:%@",todoCategory.serverId);
		DoLog(DEBUG,@"eventRecurrence.calendarId:%@",eventRecurrence.calendarId);
		
		if (todoEvent.status == 1)
		{
			[xmlData appendData:[[NSString stringWithFormat:@"<recur_c_add>"] dataUsingEncoding:NSUTF8StringEncoding]];
			
			[xmlData appendData:[[NSString stringWithFormat:@"<client_id>%@</client_id>", todoEvent.calendarId] dataUsingEncoding:NSUTF8StringEncoding]];
			//DoLog(DEBUG,@"bk1");
			[xmlData appendData:[[NSString stringWithFormat:@"<calendar_data>"] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<folder_id>%@</folder_id>", todoCategory.serverId] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<create_time>%@</create_time>", todoEvent.dtStamp] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<cal_type>%d</cal_type>", todoEvent.calType] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<all_day_event>%d</all_day_event>", todoEvent.allDayEvent] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<time_zone>%d</time_zone>", todoEvent.timeZone] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<busy_status>%d</busy_status>", todoEvent.busyStatus] dataUsingEncoding:NSUTF8StringEncoding]];
			//DoLog(DEBUG,@"bk2");
			[xmlData appendData:[[NSString stringWithFormat:@"<organizer_name>%@</organizer_name>", todoEvent.organizerName] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<organizer_email>%@</organizer_email>", todoEvent.organizerEmail] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<end_time>%@</end_time>", todoEvent.endTime] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<location>%@</location>", todoEvent.location] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<reminder>%d</reminder>", todoEvent.reminder] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<sensitivity>%d</sensitivity>", todoEvent.sensitivity] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<subject>%@</subject>", todoEvent.subject] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<start_time>%@</start_time>", todoEvent.startTime] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<uid>%@</uid>", todoEvent.uid] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<meeting_status>%d</meeting_status>", todoEvent.meetingStatus] dataUsingEncoding:NSUTF8StringEncoding]];
			//DoLog(DEBUG,@"bk3");
			[xmlData appendData:[[NSString stringWithFormat:@"<disallow_newtime>%d</disallow_newtime>", todoEvent.disallowNewTimeProposal] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<response_requested>%d</response_requested>", todoEvent.responseRequested] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<appointment_replytime>%@</appointment_replytime>", todoEvent.appointmentReplyTime] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<response_type>%d</response_type>", todoEvent.responseType] dataUsingEncoding:NSUTF8StringEncoding]];
			//[xmlData appendData:[[NSString stringWithFormat:@"<cal_recurrence_id>%@</cal_recurrence_id>", @"0"] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<cal_recurrence_id>%@</cal_recurrence_id>", todoEvent.calRecurrenceId] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<is_exception>%d</is_exception>", todoEvent.isException] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<note_id>%@</note_id>", todoEvent.noteId] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<event_desc>%@</event_desc>", todoEvent.eventDesc] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<memo>%@</memo>", todoEvent.memo] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<reminder_dismiss>%d</reminder_dismiss>", todoEvent.reminderDismiss] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<reminder_start_time>%@</reminder_start_time>", todoEvent.reminderStartTime] dataUsingEncoding:NSUTF8StringEncoding]];
			//DoLog(DEBUG,@"bk4");
			[xmlData appendData:[[NSString stringWithFormat:@"<attach_file_count>%d</attach_file_count>", 0] dataUsingEncoding:NSUTF8StringEncoding]];
			/*[xmlData appendData:[[NSString stringWithFormat:@"attach_file"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"<file_size>%@</file_size>", @"file_size"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"<file_type>%@</file_type>", @"file_type"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"<file_content>%@</file_content>", @"file_content"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"</attach_file>", todoEvent.calendarId] dataUsingEncoding:NSUTF8StringEncoding]];*/
			
			[xmlData appendData:[[NSString stringWithFormat:@"</calendar_data>"] dataUsingEncoding:NSUTF8StringEncoding]];
			
			
			[xmlData appendData:[[NSString stringWithFormat:@"<recurrence_data>"] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<recurrence_type>%d</recurrence_type>", eventRecurrence.type] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<occurrences>%d</occurrences>", eventRecurrence.occurrences] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<cal_interval>%d</cal_interval>", eventRecurrence.interval] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<week_of_month>%d</week_of_month>", eventRecurrence.weekOfMonth] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<day_of_week>%d</day_of_week>", eventRecurrence.dayOfWeek] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<month_of_year>%d</month_of_year>", eventRecurrence.monthOfYear] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<until_datetime>%@</until_datetime>", eventRecurrence.until] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<day_of_month>%d</day_of_month>", eventRecurrence.dayOfMonth] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<start_datetime>%@</start_datetime>", eventRecurrence.start] dataUsingEncoding:NSUTF8StringEncoding]];
			
			[xmlData appendData:[[NSString stringWithFormat:@"</recurrence_data>"] dataUsingEncoding:NSUTF8StringEncoding]];
			
			[xmlData appendData:[[NSString stringWithFormat:@"</recur_c_add>"] dataUsingEncoding:NSUTF8StringEncoding]];
			
			recur_c_add_count++;
		}
		/* calendar 為 del */
		else if (todoEvent.status == 3)
		{
			[xmlData appendData:[[NSString stringWithFormat:@"<recur_c_del>"] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<server_id>%@</server_id>", todoEvent.serverId] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"</recur_c_del>"] dataUsingEncoding:NSUTF8StringEncoding]];
			recur_c_del_count++;
		}
		
		[eventRecurrence release];
		[todoCategory release];
		[todoEvent release];
		
	}
	// 設定 request 各數目
	[xmlData appendData:[[NSString stringWithFormat:@"<recur_c_add_count>%d</recur_c_add_count>", recur_c_add_count] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<recur_c_del_count>%d</recur_c_del_count>", recur_c_del_count] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[xmlData appendData:[[NSString stringWithFormat:@"</recur_c_req>"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	
	if(hasMoreDataClient == YES){
		[xmlData appendData:[[NSString stringWithFormat:@"<has_more>%@</has_more>", @"Y"] dataUsingEncoding:NSUTF8StringEncoding]];
	}else{
		[xmlData appendData:[[NSString stringWithFormat:@"<has_more>%@</has_more>", @"N"] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[xmlData appendData:[[NSString stringWithFormat:@"</recurrence_sync_req>"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return xmlData;
	
}


//-------------content sync

//#modify
-(NSInteger) doContentSync:(MySqlite *)mySqlite seq:(NSInteger)sId{
	
	int limit = 5;			//the max number of recoreds for a session
	int offset = 0;			//skip the fail request
	
	int roopLimit = 100000/limit;	//to break the roop if ack is not returen
	int roopCount = 0;
	
	BOOL hasMoreDataClient = YES; //value of has_more tag of client
	BOOL hasMoreDataServer = YES; //valus of has_more tag of client
	BOOL ack = NO;
	
	NSInteger syncSeq = 0;		//sync sequence
	NSInteger sessionSeq = 0;	//session sequence
	NSInteger resultFlag = 0;		//check the sync result
	NSString *newSyncRange;
	NSString *oldSyncRange;
	
	
	limit=[ProfileUtil integerForKey:MAXSYNCAMOUNT];
	if(limit<=0)
		limit=DEFAULTMAXSYNC;
	//DoLog(INFO,@"limit:%d",limit);
	//limit=11;
	//sync policy C:client S:server
	//NSString *syncPolicy=[[NSUserDefaults standardUserDefaults] objectForKey:SYNCRULE]; 
	NSString *syncPolicy=[ProfileUtil stringForKey:SYNCRULE];
	if(syncPolicy==nil || [syncPolicy length]<=0)
		syncPolicy=@"C";
	
	
	
	//keep unsync server in dictionary for collision detection
	NSMutableDictionary *collisionDictionary = [[NSMutableDictionary alloc] init]; 
	if([syncPolicy compare:@"C"] == 0){
		NSArray *keyTmp = [mySqlite getTodoEventSyncServerId];
		for(int i=0;i<[keyTmp count]; i++){
			//DoLog(DEBUG,@"key: %@",[keyTmp objectAtIndex:i]);
			[collisionDictionary setObject:@"1" forKey:[keyTmp objectAtIndex:i]];
		}
	}
	
	NSDictionary *tmpDictionary=[self getSyncSeq:mySqlite.database];//get sync_seq
	if(tmpDictionary!=nil){
		
		syncSeq=[[tmpDictionary objectForKey:@"sync_seq"] intValue];
		sessionSeq=[[tmpDictionary objectForKey:@"session_seq"] intValue];
		oldSyncRange=[tmpDictionary objectForKey:@"sync_range"];
		
		//set sync range by setting
		NSDate *now = [NSDate date];
		NSCalendar *cal = [NSCalendar currentCalendar];
		NSDateComponents *comp= [[NSDateComponents alloc] init];
		NSString *nowDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		NSString *syncBeginDateTimeString =@"0";
		//NSString *tmpString=[[NSUserDefaults standardUserDefaults] stringForKey:KEEPRULE];
		NSString *tmpString=[ProfileUtil stringForKey:KEEPRULE];
		if(tmpString==nil)
			tmpString=@"9";
		if([tmpString integerValue] == 5){
			[comp setMonth:-24];
			now = [cal dateByAddingComponents:comp toDate:now options:0];
			syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		}else if ([tmpString integerValue] == 4){
			[comp setMonth:-12];
			now = [cal dateByAddingComponents:comp toDate:now options:0];
			syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		}else if ([tmpString integerValue] == 3){
			[comp setMonth:-6];
			now = [cal dateByAddingComponents:comp toDate:now options:0];
			syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		}else if ([tmpString integerValue] == 2){
			[comp setMonth:-3];
			now = [cal dateByAddingComponents:comp toDate:now options:0];
			syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		}else if ([tmpString integerValue] == 1){
			[comp setMonth:-1];
			now = [cal dateByAddingComponents:comp toDate:now options:0];
			syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
		}
		[comp release];
		DoLog(DEBUG,@"start:%@, end:%@",syncBeginDateTimeString,nowDateTimeString);
		NSRange range;
		range.location=0;
		range.length=8;
		if([syncBeginDateTimeString length]>8){
			newSyncRange = [syncBeginDateTimeString substringWithRange:range];
		}else{
			newSyncRange = @"0";
		}
		
		
		NSMutableData *respData = [NSMutableData data]; //fill out the xml data of tag con_c_rpl 
		
		int rplyAddCount = 0; //count the rplyAdd
		int rplyUpdCount = 0; //count the rplyUpd
		int rplyDelCount = 0; //count the rplyDel
		
		//client has unsync data , server has unsync data ,ack not return
		while (hasMoreDataClient || hasMoreDataServer || !ack ){
			
			// *Step 1: get primary key
			NSArray *pkArray = nil;
			if(hasMoreDataClient){
				pkArray = [mySqlite getTodoEventSyncCalendarIdByStartTime:syncBeginDateTimeString LastWrite:nowDateTimeString Limit: limit offset: offset];
				//DoLog(DEBUG,@"count: %d",[pkArray count]);
			}
			//DoLog(DEBUG,@"count: %d,limit:%d, offset:%d ",[pkArray count],limit,offset);
			
			if( [pkArray count] == 0){
				hasMoreDataClient = NO;
			}
			
			NSInteger respCount=(rplyAddCount+rplyUpdCount+rplyDelCount);// >0: client has reply data
			
			// *Step 2: gen XML
			NSData *xmlData = [self setContentRequest:pkArray setContentResponse:respData respCount:respCount syncSeq:syncSeq sessionSeq:sessionSeq hasMore:hasMoreDataClient newSyncRange:newSyncRange oldSyncRange:oldSyncRange  database:mySqlite];
			NSString    *str = [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] autorelease];
			DoLog(DEBUG,@"xml: %@",str);
			
			
			// *Step 3: http request
			//creating the url request:
			NSURL *cgiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",CONTENTSYNCURL,[DateTimeUtil getUrlDateString]]];
			NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:cgiUrl];
			
			//adding header information:
			[postRequest setHTTPMethod:@"POST"];
			[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
			
			[InterfaceUtil setHeader:postRequest];
			
			//setting up the body:
			NSMutableData *postBody = [NSMutableData data];
			[postBody appendData:xmlData];
			//[postBody appendData:[[NSString stringWithString:@"xml="] dataUsingEncoding:NSUTF8StringEncoding]];
			//[postBody appendData:xmlData];
			//NSData *data = [[NSData alloc] initWithData:[@"xml=<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>3</con_s_req_count><con_s_req><con_s_add_count>1</con_s_add_count><con_s_add><server_id>sId</server_id><application_data><calendar_id>aId</calendar_id></application_data></con_s_add></con_s_req><has_more_data>no</has_more_data><ack></ack></content_sync_rsp>" dataUsingEncoding:NSUTF8StringEncoding]];
			//[postBody appendData:data];
			//[data release];
			[postRequest setHTTPBody:postBody];
			
			NSHTTPURLResponse * returnResponse = nil;
			NSError *returnError = nil;
			NSData *returnData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
			int statusCode = returnResponse.statusCode;
			DoLog(DEBUG,@"statusCode:%d",statusCode);
			DoLog(DEBUG,@"%@",[[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease]);
			//if http request fail, end sync 
			if(statusCode != 200){
				resultFlag = (resultFlag | [self.errorFlag SYNC_HTTP_FAIL]);
				break;
			}
			
			
			
			// *Step 4: parse reponse
			
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>3</con_s_req_count><con_s_req><con_s_add_count>1</con_s_add_count><con_s_add><server_id>sId</server_id><application_data><calendar_id>aId</calendar_id></application_data></con_s_add></con_s_req><has_more_data>no</has_more_data><ack></ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>6</con_s_req_count><con_s_req><con_s_ add_count>1</con_s_ add_count>< con_s_add><server_id>123</server_id><calendar_data><subject>subject1</subject></calendar_data></con_s_add></con_s_req><con_s_reply_count>5</con_s_reply_count><con_s_reply></con_s_reply><has_more_data>111</has_more_data><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>0</con_s_req_count><con_s_req><con_s_add_count>add1</con_s_add_count><con_s_add><server_id>sid</server_id><calendar_data><folder_id>FFF</folder_id><subject>sususussu</subject></calendar_data></con_s_add><con_s_add><server_id>sid</server_id><calendar_data><folder_id>FFF</folder_id><subject>ssssssuuuuuu</subject></calendar_data></con_s_add></con_s_req><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_rpl_count>1</con_s_rpl_count><con_s_rpl><con_s_rpl_add_count>1</con_s_rpl_add_count><con_s_rpl_add><client_id>1</client_id><server_id>555</server_id><result>0</result></con_s_rpl_add></con_s_rpl><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//upd:data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_rpl_count>1</con_s_rpl_count><con_s_rpl><con_s_rpl_upd_count>1</con_s_rpl_upd_count><con_s_rpl_upd><client_id>1</client_id><server_id>555</server_id><result>0</result></con_s_rpl_upd></con_s_rpl><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_rpl_count>1</con_s_rpl_count><con_s_rpl><con_s_rpl_del_count>1</con_s_rpl_del_count><con_s_rpl_del><client_id>1</client_id><server_id>555</server_id><result>0</result></con_s_rpl_del></con_s_rpl><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>1</con_s_req_count><con_s_req><con_s_add_count>1</con_s_add_count><con_s_add><server_id>15</server_id><calendar_data><folder_id>0</folder_id><create_time>20100329000000</create_time><cal_type>0</cal_type><all_day_event>1</all_day_event><time_zone>0</time_zone><busy_status>0</busy_status><organizer_name>organizer_name</organizer_name><organizer_email>organizer_email</organizer_email><end_time>20100331200000</end_time><location>0</location><reminder>0</reminder><sensitivity>0</sensitivity><subject>subjectadd</subject><start_time>20100331100000</start_time><uid>0</uid><meeting_status>0</meeting_status><disallow_newtime>0</disallow_newtime><response_requested>0</response_requested><appointment_replytime>0</appointment_replytime><response_type>0</response_type><cal_recurrence_id>0</cal_recurrence_id><is_exception>0</is_exception><note_id>0</note_id><event_desc>0</event_desc><memo>0</memo><reminder_dismiss>0</reminder_dismiss><reminder_start_time>0</reminder_start_time></calendar_data></con_s_add></con_s_req><has_more>N</has_more><ack>1</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//upd data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>1</con_s_req_count><con_s_req><con_s_upd_count>1</con_s_upd_count><con_s_upd><server_id>15</server_id><calendar_data><folder_id>0</folder_id><create_time>20100329000000</create_time><cal_type>0</cal_type><all_day_event>1</all_day_event><time_zone>0</time_zone><busy_status>0</busy_status><organizer_name>organizer_name</organizer_name><organizer_email>organizer_email</organizer_email><end_time>20100331200000</end_time><location>0</location><reminder>0</reminder><sensitivity>0</sensitivity><subject>subjectmodify</subject><start_time>20100331100000</start_time><uid>0</uid><meeting_status>0</meeting_status><disallow_newtime>0</disallow_newtime><response_requested>0</response_requested><appointment_replytime>0</appointment_replytime><response_type>0</response_type><cal_recurrence_id>0</cal_recurrence_id><is_exception>0</is_exception><note_id>0</note_id><event_desc>0</event_desc><memo>0</memo><reminder_dismiss>0</reminder_dismiss><reminder_start_time>0</reminder_start_time></calendar_data></con_s_upd></con_s_req><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//data = [[NSData alloc] initWithData:[@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?><content_sync_rsp><sync_seq>1</sync_seq><session_seq>2</session_seq><con_s_req_count>1</con_s_req_count><con_s_req><con_s_del_count>1</con_s_del_count><con_s_del><server_id>15</server_id><calendar_data><folder_id>0</folder_id><create_time>20100329000000</create_time><cal_type>0</cal_type><all_day_event>1</all_day_event><time_zone>0</time_zone><busy_status>0</busy_status><organizer_name>organizer_name</organizer_name><organizer_email>organizer_email</organizer_email><end_time>20100331200000</end_time><location>0</location><reminder>0</reminder><sensitivity>0</sensitivity><subject>subjectmodify</subject><start_time>20100331100000</start_time><uid>0</uid><meeting_status>0</meeting_status><disallow_newtime>0</disallow_newtime><response_requested>0</response_requested><appointment_replytime>0</appointment_replytime><response_type>0</response_type><cal_recurrence_id>0</cal_recurrence_id><is_exception>0</is_exception><note_id>0</note_id><event_desc>0</event_desc><memo>0</memo><reminder_dismiss>0</reminder_dismiss><reminder_start_time>0</reminder_start_time></calendar_data></con_s_del></con_s_req><has_more>111</has_more><ack>1235</ack></content_sync_rsp>" dataUsingEncoding:NSUnicodeStringEncoding]];
			//TreeNode *root = [[XMLParser sharedInstance] parseXMLFromData:data];
			
			TreeNode *root = [[XMLParser sharedInstance] parseXMLFromData:returnData];
			
			// return result ==1(Fail), end sync
			if([root leafForKey:@"result"] ==nil || [[root leafForKey:@"result"] intValue] == 1){
				resultFlag = (resultFlag | [self.errorFlag SYNC_RESULT_FAIL]);
				break;
			}
			
			//DoLog(DEBUG,@"result:%@",[root leafForKey:@"result"]);
			//DoLog(DEBUG,@"sync_seq:%@",[root leafForKey:@"sync_seq"]);
			//DoLog(DEBUG,@"session_seq:%@",[root leafForKey:@"session_seq"]);
			//DoLog(DEBUG,@"ack:%@",[root leafForKey:@"ack"]);
			//DoLog(DEBUG,@"has_more:%@",[root leafForKey:@"has_more"]);
			//DoLog(DEBUG,@"has_more_client:%d",hasMoreDataClient);
			
			if([root leafForKey:@"has_more"] != nil && [[root leafForKey:@"has_more"] compare:@"Y"] == 0){
				hasMoreDataServer = YES;
			}else{
				hasMoreDataServer = NO;
			}
			
			//DoLog(DEBUG,@"con_s_rpl_count:%@",[root leafForKey:@"con_s_rpl_count"]);
			int rplCount = [[root leafForKey:@"con_s_rpl_count"] intValue];
			if(rplCount > 0){
				TreeNode *myServerResponse=[root objectForKey:@"con_s_rpl"];
				//response ADD part result
				//DoLog(DEBUG,@"con_s_rpl_add_count:%@",[myServerResponse leafForKey:@"con_s_rpl_add_count"]);
				int addCount = [[myServerResponse leafForKey:@"con_s_rpl_add_count"] intValue];
				if(addCount > 0){
					NSMutableArray *myAdd=[myServerResponse objectsForKey:@"con_s_rpl_add"];
					for(int i=0;i<[myAdd count];i++){
						DoLog(DEBUG,@"ADD reply %d -----------",i);
						DoLog(DEBUG,@"client_id:%@",[[myAdd objectAtIndex:i] leafForKey:@"client_id"]);
						DoLog(DEBUG,@"server_id:%@",[[myAdd objectAtIndex:i] leafForKey:@"server_id"]);
						DoLog(DEBUG,@"result:%@",[[myAdd objectAtIndex:i] leafForKey:@"result"]);
						//DBACTION
						if([[myAdd objectAtIndex:i] leafForKey:@"result"]!=nil){
							NSString *clientId = [[myAdd objectAtIndex:i] leafForKey:@"client_id"];
							NSString *serverId = [[myAdd objectAtIndex:i] leafForKey:@"server_id"];
							NSString *r = [[myAdd objectAtIndex:i] leafForKey:@"result"];
							if([r integerValue] == 0){
								[mySqlite updatePimCalendarSetSyncFlag:2 ServerId:serverId SyncId:[NSString stringWithFormat:@"%d",syncSeq] WhereCalendarId:clientId];
							}else if([r integerValue] == 1){
								//conflict
							}else if([r integerValue] == 2){
								offset++;
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_ADD_FAIL_2]);
							}else if([r integerValue] == 3){
								[mySqlite updatePimCalendarSetSyncFlag:2 ServerId:serverId SyncId:[NSString stringWithFormat:@"%d",syncSeq] WhereCalendarId:clientId];
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_ADD_FAIL_3]);
							}else{
								offset++;
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_ADD_FAIL_O]);
							}
						}
					}
				}
				//response UPDATE part result
				
				//DoLog(DEBUG,@"con_s_rpl_upd_count:%@",[myServerResponse leafForKey:@"con_s_rpl_upd_count"]);
				int updCount = [[myServerResponse leafForKey:@"con_s_rpl_upd_count"] intValue];
				if(updCount > 0){
					NSMutableArray *myUpd=[myServerResponse objectsForKey:@"con_s_rpl_upd"];
					for(int i=0;i<[myUpd count];i++){
						//DoLog(DEBUG,@"UPD reply %d -----------",i);
						//DoLog(DEBUG,@"server_id:%@",[[myUpd objectAtIndex:i] leafForKey:@"server_id"]);
						//DoLog(DEBUG,@"result:%@",[[myUpd objectAtIndex:i] leafForKey:@"result"]);
						//DBACTION
						if([[myUpd objectAtIndex:i] leafForKey:@"result"]!=nil){
							NSString *myServerId = [[myUpd objectAtIndex:i] leafForKey:@"server_id"];
							NSString *r = [[myUpd objectAtIndex:i] leafForKey:@"result"];
							if([r integerValue] == 0){
								[mySqlite updatePimCalendarSetSyncFlag:2 SyncId:[NSString stringWithFormat:@"%d",syncSeq] WhereServerId:myServerId];
							}else if([r integerValue] == 1){
								//conflict
							}else if([r integerValue] == 2){
								offset++;
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_UPD_FAIL_2]);
							}else if([r integerValue] == 3){
								[mySqlite updatePimCalendarSetSyncFlag:2 SyncId:[NSString stringWithFormat:@"%d",syncSeq] WhereServerId:myServerId];
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_UPD_FAIL_3]);
							}else{
								offset++;
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_UPD_FAIL_O]);
							}
						}
					}
				}
				
				//DoLog(DEBUG,@"con_s_rpl_del_count:%@",[myServerResponse leafForKey:@"con_s_rpl_del_count"]);
				int delCount = [[myServerResponse leafForKey:@"con_s_rpl_del_count"] intValue];
				if(delCount > 0){
					NSMutableArray *myDel=[myServerResponse objectsForKey:@"con_s_rpl_del"];
					for(int i=0;i<[myDel count];i++){
						//DoLog(DEBUG,@"DEL reply %d -----------",i);
						//DoLog(DEBUG,@"server_id:%@",[[myDel objectAtIndex:i] leafForKey:@"server_id"]);
						//DoLog(DEBUG,@"result:%@",[[myDel objectAtIndex:i] leafForKey:@"result"]);
						//DBACTION
						if([[myDel objectAtIndex:i] leafForKey:@"result"]!=nil){
							NSString *serverId = [[myDel objectAtIndex:i] leafForKey:@"server_id"];
							NSString *r = [[myDel objectAtIndex:i] leafForKey:@"result"];
							if([r integerValue] == 0){
								[mySqlite deleteFromPimCalendarWhereServerId:serverId];
							}else if([r integerValue] == 1){
								//conflict
							}else if([r integerValue] == 2){
								offset++;
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_DEL_FAIL_2]);
							}else if([r integerValue] == 3){
								[mySqlite updatePimCalendarSetSyncFlag:2 SyncId:[NSString stringWithFormat:@"%d",syncSeq] WhereServerId:serverId];
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_DEL_FAIL_3]);
							}else{
								offset++;
								resultFlag = (resultFlag | [self.errorFlag SYNC_RES_DEL_FAIL_O]);
							}
						}
					}
				}
			}
			
			
			//---5 do server request
			
			//reset respData
			respData = [NSMutableData data];
			
			//reset count
			rplyAddCount=0;
			rplyUpdCount=0;
			rplyDelCount=0;
			
			//DoLog(DEBUG,@"con_s_req_count:%@",[root leafForKey:@"con_s_req_count"]);
			int sReqCount = [[root leafForKey:@"con_s_req_count"] intValue];
			if(sReqCount > 0){
				TreeNode *myServerRequest=[root objectForKey:@"con_s_req"];
				NSMutableDictionary *myData ;
				
				//add part
				//DoLog(DEBUG,@"con_s_add_count:%@",[myServerRequest leafForKey:@"con_s_add_count"]);
				int sAddCount = [[myServerRequest leafForKey:@"con_s_add_count"] intValue];
				if(sAddCount > 0){
					NSMutableArray *myAddReq=[myServerRequest objectsForKey:@"con_s_add"];
					for(int i=0;i<[myAddReq count];i++){
						
						//DoLog(DEBUG,@"ADD req %d -----------",i);
						//DoLog(DEBUG,@"server_id:%@",[[myAddReq objectAtIndex:i] leafForKey:@"server_id"]);
						NSString *myServerId = [[myAddReq objectAtIndex:i] leafForKey:@"server_id"];
						myData=[[[myAddReq objectAtIndex:i] objectForKey:@"calendar_data"] dictionaryForChildren];
						
						//DoLog(DEBUG,@"folder_id:%@",[myData objectForKey:@"folder_id"]);
						//DoLog(DEBUG,@"create_time:%@",[myData objectForKey:@"create_time"]);
						//DoLog(DEBUG,@"all_day_event:%@",[myData objectForKey:@"all_day_event"]);
						//DoLog(DEBUG,@"time_zone:%@",[myData objectForKey:@"time_zone"]);
						//DoLog(DEBUG,@"busy_status:%@",[myData objectForKey:@"busy_status"]);
						//DoLog(DEBUG,@"organizer_name:%@",[myData objectForKey:@"organizer_name"]);
						//DoLog(DEBUG,@"organizer_email:%@",[myData objectForKey:@"organizer_email"]);
						//DoLog(DEBUG,@"end_time:%@",[myData objectForKey:@"end_time"]);
						//DoLog(DEBUG,@"location:%@",[myData objectForKey:@"location"]);
						//DoLog(DEBUG,@"reminder:%@",[myData objectForKey:@"reminder"]);
						//DoLog(DEBUG,@"sensitivity:%@",[myData objectForKey:@"sensitivity"]);
						//DoLog(DEBUG,@"subject:%@",[myData objectForKey:@"subject"]);
						//DoLog(DEBUG,@"start_time:%@",[myData objectForKey:@"start_time"]);
						//DoLog(DEBUG,@"uid:%@",[myData objectForKey:@"uid"]);
						//DoLog(DEBUG,@"disallow_newtime:%@",[myData objectForKey:@"disallow_newtime"]);
						//DoLog(DEBUG,@"response_requested:%@",[myData objectForKey:@"response_requested"]);
						//DoLog(DEBUG,@"appointment_replytime:%@",[myData objectForKey:@"appointment_replytime"]);
						//DoLog(DEBUG,@"response_type:%@",[myData objectForKey:@"response_type"]);
						//DoLog(DEBUG,@"cal_recurrence_id:%@",[myData objectForKey:@"cal_recurrence_id"]);
						//DoLog(DEBUG,@"is_exception:%@",[myData objectForKey:@"is_exception"]);
						//DoLog(DEBUG,@"note_id:%@",[myData objectForKey:@"note_id"]);
						//DoLog(DEBUG,@"event_desc:%@",[myData objectForKey:@"event_desc"]);
						//DoLog(DEBUG,@"memo:%@",[myData objectForKey:@"memo"]);
						//DoLog(DEBUG,@"reminder_dismiss:%@",[myData objectForKey:@"reminder_dismiss"]);
						//DoLog(DEBUG,@"reminder_start_time:%@",[myData objectForKey:@"reminder_start_time"]);
						//DoLog(DEBUG,@"attach_file_count:%@",[myData objectForKey:@"attach_file_count"]);
						
						//TreeNode *fileNode = [myData objectForKey:@"attach_file"];
						//DoLog(DEBUG,@"file_size:%@",[fileNode leafForKey:@"file_size"]);
						//DoLog(DEBUG,@"file_type:%@",[fileNode leafForKey:@"file_type"]);
						//DoLog(DEBUG,@"file_content:%@",[fileNode leafForKey:@"file_content"]);
						
						
						//DBACTION
						TodoEvent *todoEvent = [[TodoEvent alloc] init];
						TodoCategory *todoCategory = [[TodoCategory alloc] initWithCategoryServerId:[myData objectForKey:@"folder_id"] database:mySqlite.database];
						
						[todoEvent setUserId:@"777"];
						[todoEvent setFolderId:todoCategory.folderId];
						[todoEvent setLastWrite:[DateTimeUtil getTodayString]];
						[todoEvent setIsSynced:2];
						[todoEvent setStatus:1];
						[todoEvent setNeedSync:2];
						[todoEvent setTimeZone:[[myData objectForKey:@"time_zone"] integerValue]];
						[todoEvent setAllDayEvent:[[myData objectForKey:@"all_day_event"] integerValue]];
						[todoEvent setBusyStatus:[[myData objectForKey:@"busy_status"] integerValue]];
						[todoEvent setOrganizerName:[myData objectForKey:@"organizer_name"]];
						[todoEvent setOrganizerEmail:[myData objectForKey:@"organizer_email"]];
						[todoEvent setDtStamp:[myData objectForKey:@"create_time"]];
						[todoEvent setEndTime:[myData objectForKey:@"end_time"]];			
						[todoEvent setLocation:[myData objectForKey:@"location"]];
						[todoEvent setReminder:[[myData objectForKey:@"reminder"] integerValue]];
						[todoEvent setSensitivity:[[myData objectForKey:@"sensitivity"] integerValue]];
						[todoEvent setSubject:[myData objectForKey:@"subject"]];
						[todoEvent setEventDesc:[myData objectForKey:@"event_desc"]];
						[todoEvent setStartTime:[myData objectForKey:@"start_time"]];
						[todoEvent setUid:[myData objectForKey:@"uid"]];
						[todoEvent setMeetingStatus:0];
						[todoEvent setDisallowNewTimeProposal:[[myData objectForKey:@"disallow_newtime"] integerValue]];
						[todoEvent setResponseRequested:[[myData objectForKey:@"response_requested"] integerValue]];
						[todoEvent setAppointmentReplyTime:[myData objectForKey:@"appointment_replytime"]];
						[todoEvent setResponseType:[[myData objectForKey:@"response_type"] integerValue]];
						if([[myData objectForKey:@"cal_recurrence_id"] integerValue] > 0){
							TodoEvent *tempEvent = [[TodoEvent alloc] initWithServerId:[myData objectForKey:@"cal_recurrence_id"] database:mySqlite.database];
							[todoEvent setCalRecurrenceId:tempEvent.calendarId];
							[tempEvent release];
						}else{
							[todoEvent setCalRecurrenceId:[myData objectForKey:@"cal_recurrence_id"]];
						}
						[todoEvent setIsException:[[myData objectForKey:@"is_exception"] integerValue]];
						[todoEvent setDeleted:0];
						[todoEvent setPicturePath:@"PicturePath"];
						[todoEvent setVoicePath:@"VoicePath"];
						[todoEvent setNoteId:[myData objectForKey:@"note_id"]];
						[todoEvent setMemo:[myData objectForKey:@"memo"]];
						[todoEvent setReminderDismiss:[[myData objectForKey:@"reminder_dismiss"] integerValue]];
						[todoEvent setReminderStartTime:[myData objectForKey:@"reminder_start_time"]];
						[todoEvent setServerId:myServerId];
						[todoEvent setCalType:[[myData objectForKey:@"cal_type"]integerValue]];
						[todoEvent setSyncId:[NSString stringWithFormat:@"%d",syncSeq]];
						
						BOOL result = YES;
						if ([mySqlite checkExistOfServerId:myServerId] == NO){
							result = [todoEvent insTodoEventDatabase:mySqlite.database];
						}
						NSString *r = @"0";
						if(result == NO){
							r = @"2";
							resultFlag = (resultFlag | [self.errorFlag SYNC_REQ_ADD_FAIL]);
						}
						
						[respData appendData:[[NSString stringWithFormat:@"<con_c_rpl_add><server_id>%@</server_id><result>%@</result></con_c_rpl_add>",myServerId,r] dataUsingEncoding:NSUTF8StringEncoding]];
						rplyAddCount++;
						
						[todoEvent release];
						[todoCategory release];
					}
				}
				
				//DoLog(DEBUG,@"con_s_upd_count:%@",[myServerRequest leafForKey:@"con_s_upd_count"]);
				int sUpdCount = [[myServerRequest leafForKey:@"con_s_upd_count"] intValue];
				if(sUpdCount > 0){
					NSMutableArray *myUpdReq=[myServerRequest objectsForKey:@"con_s_upd"];
					for(int i=0;i<[myUpdReq count];i++){
						//DoLog(DEBUG,@"UPD req %d -----------",i);
						//DoLog(DEBUG,@"server_id:%@",[[myUpdReq objectAtIndex:i] leafForKey:@"server_id"]);
						NSString *myServerId = [[myUpdReq objectAtIndex:i] leafForKey:@"server_id"];
						myData=[[[myUpdReq objectAtIndex:i] objectForKey:@"calendar_data"] dictionaryForChildren];
						//DoLog(DEBUG,@"folder_id:%@",[myData objectForKey:@"folder_id"]);
						//DoLog(DEBUG,@"create_time:%@",[myData objectForKey:@"create_time"]);
						//DoLog(DEBUG,@"all_day_event:%@",[myData objectForKey:@"all_day_event"]);
						//DoLog(DEBUG,@"time_zone:%@",[myData objectForKey:@"time_zone"]);
						//DoLog(DEBUG,@"busy_status:%@",[myData objectForKey:@"busy_status"]);
						//DoLog(DEBUG,@"organizer_name:%@",[myData objectForKey:@"organizer_name"]);
						//DoLog(DEBUG,@"organizer_email:%@",[myData objectForKey:@"organizer_email"]);
						//DoLog(DEBUG,@"end_time:%@",[myData objectForKey:@"end_time"]);
						//DoLog(DEBUG,@"location:%@",[myData objectForKey:@"location"]);
						//DoLog(DEBUG,@"reminder:%@",[myData objectForKey:@"reminder"]);
						//DoLog(DEBUG,@"sensitivity:%@",[myData objectForKey:@"sensitivity"]);
						//DoLog(DEBUG,@"subject:%@",[myData objectForKey:@"subject"]);
						//DoLog(DEBUG,@"start_time:%@",[myData objectForKey:@"start_time"]);
						//DoLog(DEBUG,@"uid:%@",[myData objectForKey:@"uid"]);
						//DoLog(DEBUG,@"disallow_newtime:%@",[myData objectForKey:@"disallow_newtime"]);
						//DoLog(DEBUG,@"response_requested:%@",[myData objectForKey:@"response_requested"]);
						//DoLog(DEBUG,@"appointment_replytime:%@",[myData objectForKey:@"appointment_replytime"]);
						//DoLog(DEBUG,@"response_type:%@",[myData objectForKey:@"response_type"]);
						//DoLog(DEBUG,@"cal_recurrence_id:%@",[myData objectForKey:@"cal_recurrence_id"]);
						//DoLog(DEBUG,@"is_exception:%@",[myData objectForKey:@"is_exception"]);
						//DoLog(DEBUG,@"note_id:%@",[myData objectForKey:@"note_id"]);
						//DoLog(DEBUG,@"event_desc:%@",[myData objectForKey:@"event_desc"]);
						///DoLog(DEBUG,@"memo:%@",[myData objectForKey:@"memo"]);
						//DoLog(DEBUG,@"reminder_dismiss:%@",[myData objectForKey:@"reminder_dismiss"]);
						//DoLog(DEBUG,@"reminder_start_time:%@",[myData objectForKey:@"reminder_start_time"]);
						//DoLog(DEBUG,@"attach_file_count:%@",[myData objectForKey:@"attach_file_count"]);
						
						//TreeNode *fileNode = [myData objectForKey:@"attach_file"];
						//DoLog(DEBUG,@"file_size:%@",[fileNode leafForKey:@"file_size"]);
						//DoLog(DEBUG,@"file_type:%@",[fileNode leafForKey:@"file_type"]);
						//DoLog(DEBUG,@"file_content:%@",[fileNode leafForKey:@"file_content"]);
						
						
						//DBACTION
						NSString *r = @"0";
						if([collisionDictionary objectForKey:myServerId] == nil){
							
							TodoEvent *todoEvent = [[TodoEvent alloc] init];
							TodoCategory *todoCategory = [[TodoCategory alloc] initWithCategoryServerId:[myData objectForKey:@"folder_id"] database:mySqlite.database];
							DoLog(DEBUG,@"todoCategory:%@,serverId:%@",todoCategory.folderId,[myData objectForKey:@"folder_id"]);
							[todoEvent setUserId:@"777"];
							[todoEvent setFolderId:todoCategory.folderId];
							[todoEvent setLastWrite:[DateTimeUtil getTodayString]];
							[todoEvent setIsSynced:2];
							[todoEvent setStatus:1];
							[todoEvent setNeedSync:2];
							[todoEvent setTimeZone:[[myData objectForKey:@"time_zone"] integerValue]];
							[todoEvent setAllDayEvent:[[myData objectForKey:@"all_day_event"] integerValue]];
							[todoEvent setBusyStatus:[[myData objectForKey:@"busy_status"] integerValue]];
							[todoEvent setOrganizerName:[myData objectForKey:@"organizer_name"]];
							[todoEvent setOrganizerEmail:[myData objectForKey:@"organizer_email"]];
							[todoEvent setDtStamp:[myData objectForKey:@"create_time"]];
							[todoEvent setEndTime:[myData objectForKey:@"end_time"]];			
							[todoEvent setLocation:[myData objectForKey:@"location"]];
							[todoEvent setReminder:[[myData objectForKey:@"reminder"] integerValue]];
							[todoEvent setSensitivity:[[myData objectForKey:@"sensitivity"] integerValue]];
							[todoEvent setSubject:[myData objectForKey:@"subject"]];
							[todoEvent setEventDesc:[myData objectForKey:@"event_desc"]];
							[todoEvent setStartTime:[myData objectForKey:@"start_time"]];
							[todoEvent setUid:[myData objectForKey:@"uid"]];
							[todoEvent setMeetingStatus:0];
							[todoEvent setDisallowNewTimeProposal:[[myData objectForKey:@"disallow_newtime"] integerValue]];
							[todoEvent setResponseRequested:[[myData objectForKey:@"response_requested"] integerValue]];
							[todoEvent setAppointmentReplyTime:[myData objectForKey:@"appointment_replytime"]];
							[todoEvent setResponseType:[[myData objectForKey:@"response_type"] integerValue]];
							if([[myData objectForKey:@"cal_recurrence_id"] integerValue] > 0){
								TodoEvent *tempEvent = [[TodoEvent alloc] initWithServerId:[myData objectForKey:@"cal_recurrence_id"] database:mySqlite.database];
								[todoEvent setCalRecurrenceId:tempEvent.calendarId];
								[tempEvent release];
							}else{
								[todoEvent setCalRecurrenceId:[myData objectForKey:@"cal_recurrence_id"]];
							}
							[todoEvent setIsException:[[myData objectForKey:@"is_exception"] integerValue]];
							[todoEvent setDeleted:0];
							[todoEvent setPicturePath:@"PicturePath"];
							[todoEvent setVoicePath:@"VoicePath"];
							[todoEvent setNoteId:[myData objectForKey:@"note_id"]];
							[todoEvent setMemo:[myData objectForKey:@"memo"]];
							[todoEvent setReminderDismiss:[[myData objectForKey:@"reminder_dismiss"] integerValue]];
							[todoEvent setReminderStartTime:[myData objectForKey:@"reminder_start_time"]];
							[todoEvent setServerId:myServerId];
							[todoEvent setCalType:[[myData objectForKey:@"cal_type"]integerValue]];
							[todoEvent setSyncId:[NSString stringWithFormat:@"%d",syncSeq]];
							
							BOOL result = [todoEvent updTodoEventByServerId:myServerId Database:mySqlite.database];
							//DoLog(DEBUG,@"rrr:::%@",r);
							if(result == NO){
								r = @"2";
								resultFlag = (resultFlag | [self.errorFlag SYNC_REQ_UPD_FAIL]);
							}
							[todoEvent release];
							[todoCategory release];
						}else{
							//collision
							r = @"1";
						}
						
						[respData appendData:[[NSString stringWithFormat:@"<con_c_rpl_upd><server_id>%@</server_id><result>%@</result></con_c_rpl_upd>",myServerId,r] dataUsingEncoding:NSUTF8StringEncoding]];
						rplyUpdCount++;
					}
				}
				
				//DoLog(DEBUG,@"con_s_del_count:%@",[myServerRequest leafForKey:@"con_s_del_count"]);
				int sDelCount = [[myServerRequest leafForKey:@"con_s_del_count"] intValue];
				if(sDelCount > 0){
					NSMutableArray *myDelReq=[myServerRequest objectsForKey:@"con_s_del"];
					for(int i=0;i<[myDelReq count];i++){
						//DoLog(DEBUG,@"server_id:%@",[[myDelReq objectAtIndex:i] leafForKey:@"server_id"]);
						NSString *myServerId = [[myDelReq objectAtIndex:i] leafForKey:@"server_id"];
						
						//DBACTION
						NSString *r = @"0";
						if([collisionDictionary objectForKey:myServerId] == nil){
							//do delete
							BOOL dbResult = [mySqlite deleteFromPimCalendarWhereServerId:myServerId];
							if(dbResult == NO){
								r = @"2";
								resultFlag = (resultFlag | [self.errorFlag SYNC_REQ_DEL_FAIL]);
							}
						}else{
							//collision
							r = @"1";
						}
						[respData appendData:[[NSString stringWithFormat:@"<con_c_rpl_del><server_id>%@</server_id><result>%@</result></con_c_rpl_del>",myServerId,r] dataUsingEncoding:NSUTF8StringEncoding]];
						rplyDelCount++;
					}
				}
				[respData appendData:[[NSString stringWithFormat:@"<con_c_rpl_add_count>%d</con_c_rpl_add_count>", rplyAddCount] dataUsingEncoding:NSUTF8StringEncoding]];
				[respData appendData:[[NSString stringWithFormat:@"<con_c_rpl_del_count>%d</con_c_rpl_del_count>", rplyDelCount] dataUsingEncoding:NSUTF8StringEncoding]];
				[respData appendData:[[NSString stringWithFormat:@"<con_c_rpl_upd_count>%d</con_c_rpl_upd_count>", rplyUpdCount] dataUsingEncoding:NSUTF8StringEncoding]];
				
				
			}
			
			sessionSeq++;
			
			if([root leafForKey:@"ack"] != nil && [[root leafForKey:@"ack"] compare:@"Y"] == 0){
				//DoLog(DEBUG,@"ack:%@",[root leafForKey:@"ack"]);
				ack = YES;
				break;
			}else{
				ack = NO;
			}
			//check loop limit
			roopCount++;
			if(roopCount> roopLimit){
				resultFlag = (resultFlag | [self.errorFlag SYNC_ROOP_LIMIT]);
				break;
			}
			
			if(stopFlag==YES){
				resultFlag = (resultFlag | [self.errorFlag SYNC_USER_STOP]);
				break;
			}
		}
	}else{
		resultFlag = (resultFlag | [self.errorFlag SYNC_SYNCSEQ_FAIL]);
	}
	// #add
	// update sync_status to 0
	[mySqlite updatePimCalendarSetSyncStatus:0 WhereSyncStatus:1];
	
	if(resultFlag == 0){
		[self updSyncSeq:mySqlite.database syncRange:newSyncRange sequence:syncSeq session:sessionSeq result:1];
	}
	
	[collisionDictionary release];
	return resultFlag;
}

//#modify
- (NSData *) setContentRequest:(NSArray *) iPkArray setContentResponse:(NSMutableData *)iRespData respCount:(NSInteger)respCount syncSeq:(NSInteger)syncSeq sessionSeq:(NSInteger)sessionSeq hasMore:(BOOL)hasMoreDataClient newSyncRange:(NSString *)newSyncRange oldSyncRange:(NSString *)oldSyncRange database:(MySqlite *)mySqlite {
	
	NSMutableData *xmlData = [NSMutableData data];
	
	//NSString *serviceId=[[NSUserDefaults standardUserDefaults] stringForKey:SERVICEID];
	//NSString *authId=[[NSUserDefaults standardUserDefaults] stringForKey:AUTHID];
	NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
	NSString *authId=[ProfileUtil stringForKey:AUTHID];
	/*
	if(serviceId==nil || [serviceId length]<=0)
		serviceId=DEFAULTSID;
	if(authId==nil || [authId length]<=0)
		authId=DEFAULTMSISDN;
	 */
	//#define POLICY_SRV    "S"    /* 同步機制:衝突時以server為主 */
	//#define POLICY_CLI    "C"    /* 同步機制:衝突時以client為主 */
	//NSString *syncPolicy=[[NSUserDefaults standardUserDefaults] objectForKey:SYNCRULE];
	NSString *syncPolicy=[ProfileUtil stringForKey:SYNCRULE];
	if(syncPolicy==nil || [syncPolicy length]<=0)
		syncPolicy=@"C";
	/*
	//set sync range by setting
	NSDate *now = [NSDate date];
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *comp= [[NSDateComponents alloc] init];
	NSString *syncBeginDateTimeString =@"0";
	//NSString *tmpString=[[NSUserDefaults standardUserDefaults] stringForKey:KEEPRULE];
	NSString *tmpString=[ProfileUtil stringForKey:KEEPRULE];
	if(tmpString==nil)
		tmpString=@"9";
	if([tmpString integerValue] == 5){
		[comp setMonth:-24];
		now = [cal dateByAddingComponents:comp toDate:now options:0];
		syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
	}else if ([tmpString integerValue] == 4){
		[comp setMonth:-12];
		now = [cal dateByAddingComponents:comp toDate:now options:0];
		syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
	}else if ([tmpString integerValue] == 3){
		[comp setMonth:-6];
		now = [cal dateByAddingComponents:comp toDate:now options:0];
		syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
	}else if ([tmpString integerValue] == 2){
		[comp setMonth:-3];
		now = [cal dateByAddingComponents:comp toDate:now options:0];
		syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
	}else if ([tmpString integerValue] == 1){
		[comp setMonth:-1];
		now = [cal dateByAddingComponents:comp toDate:now options:0];
		syncBeginDateTimeString = [DateTimeUtil getStringFromDate:now forKind:0];
	}
	[comp release];
	NSRange range;
	range.location=0;
	range.length=8;
	if([syncBeginDateTimeString length]>8){
		syncBeginDateTimeString = [syncBeginDateTimeString substringWithRange:range];
	}
	DoLog(DEBUG,@"sync_range:%@", syncBeginDateTimeString);*/
	DoLog(DEBUG,@"AAA:::new_range:%@,old_range:%@", newSyncRange,oldSyncRange);
	
	
	int con_c_req_count = 0;
	int con_c_add_count = 0;
	int con_c_del_count = 0;
	int con_c_upd_count = 0;
	
	int con_c_rpl_count = 0;
	//int con_c_rpl_add_count = 0;
	//int con_c_rpl_del_count = 0;
	//int con_c_rpl_upd_count = 0;
	
	[xmlData appendData:[[NSString stringWithString:@"xml=<content_sync_req>"] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<auth_id>%@</auth_id>", authId] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<service_id>%@</service_id>", serviceId] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<sync_seq>%d</sync_seq>", syncSeq] dataUsingEncoding:NSUTF8StringEncoding]]; 
	[xmlData appendData:[[NSString stringWithFormat:@"<session_seq>%d</session_seq>", sessionSeq] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<sync_range>%@</sync_range>", newSyncRange] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<new_range>%@</new_range>", newSyncRange] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<old_range>%@</old_range>", oldSyncRange] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<sync_policy>%@</sync_policy>", syncPolicy] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	// con_c_req_count 的數目
	if ([iPkArray count] > 0)
		con_c_req_count = 1;
	
	[xmlData appendData:[[NSString stringWithFormat:@"<con_c_req_count>%d</con_c_req_count>", con_c_req_count] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	
	/*設定 con_c_req 的內容*/
	[xmlData appendData:[[NSString stringWithFormat:@"<con_c_req>"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	for(int i=0; i<[iPkArray count]; i++)
	{
		TodoEvent *todoEvent = [[TodoEvent alloc] initWithEventId:[iPkArray objectAtIndex:i] database:mySqlite.database];
		TodoCategory *todoCategory = [[TodoCategory alloc] initWithCategoryId:todoEvent.folderId database:mySqlite.database];
		
		// #add
		// update sync_status to 1
		[mySqlite updatePimCalendarSetSyncStatus:1 WhereCalendarId:todoEvent.calendarId];
		
		//DoLog(DEBUG,@"subject:%@",todoEvent.subject);
		//DoLog(DEBUG,@"status:%d",todoEvent.status);
		//DoLog(DEBUG,@"todoEvent:folderId:%@",todoEvent.folderId);
		//DoLog(DEBUG,@"todoCategory.serverId:%@",todoCategory.serverId);
		//DoLog(DEBUG,@"todoEvent.calRecurrenceId:%@",todoEvent.calRecurrenceId);
		if (todoEvent.status == 1)
		{
			[xmlData appendData:[[NSString stringWithFormat:@"<con_c_add>"] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<client_id>%@</client_id>", todoEvent.calendarId] dataUsingEncoding:NSUTF8StringEncoding]];
			//DoLog(DEBUG,@"bk1");
			[xmlData appendData:[[NSString stringWithFormat:@"<calendar_data>"] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<folder_id>%@</folder_id>", todoCategory.serverId] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<create_time>%@</create_time>", todoEvent.dtStamp] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<cal_type>%d</cal_type>", todoEvent.calType] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<all_day_event>%d</all_day_event>", todoEvent.allDayEvent] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<time_zone>%d</time_zone>", todoEvent.timeZone] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<busy_status>%d</busy_status>", todoEvent.busyStatus] dataUsingEncoding:NSUTF8StringEncoding]];
			//DoLog(DEBUG,@"bk2");
			[xmlData appendData:[[NSString stringWithFormat:@"<organizer_name>%@</organizer_name>", todoEvent.organizerName] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<organizer_email>%@</organizer_email>", todoEvent.organizerEmail] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<end_time>%@</end_time>", todoEvent.endTime] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<location>%@</location>", todoEvent.location] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<reminder>%d</reminder>", todoEvent.reminder] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<sensitivity>%d</sensitivity>", todoEvent.sensitivity] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<subject>%@</subject>", todoEvent.subject] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<start_time>%@</start_time>", todoEvent.startTime] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<uid>%@</uid>", todoEvent.uid] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<meeting_status>%d</meeting_status>", todoEvent.meetingStatus] dataUsingEncoding:NSUTF8StringEncoding]];
			//DoLog(DEBUG,@"bk3");
			[xmlData appendData:[[NSString stringWithFormat:@"<disallow_newtime>%d</disallow_newtime>", todoEvent.disallowNewTimeProposal] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<response_requested>%d</response_requested>", todoEvent.responseRequested] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<appointment_replytime>%@</appointment_replytime>", todoEvent.appointmentReplyTime] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<response_type>%d</response_type>", todoEvent.responseType] dataUsingEncoding:NSUTF8StringEncoding]];
			if([todoEvent.calRecurrenceId integerValue] > 0){
				TodoEvent *parentEvent = [[TodoEvent alloc] initWithEventId:todoEvent.calRecurrenceId database:mySqlite.database];
				[xmlData appendData:[[NSString stringWithFormat:@"<cal_recurrence_id>%@</cal_recurrence_id>", parentEvent.serverId] dataUsingEncoding:NSUTF8StringEncoding]];
				[parentEvent release];
			}else{
				[xmlData appendData:[[NSString stringWithFormat:@"<cal_recurrence_id>%@</cal_recurrence_id>", todoEvent.calRecurrenceId] dataUsingEncoding:NSUTF8StringEncoding]];
			}
			[xmlData appendData:[[NSString stringWithFormat:@"<is_exception>%d</is_exception>", todoEvent.isException] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<note_id>%@</note_id>", todoEvent.noteId] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<event_desc>%@</event_desc>", todoEvent.eventDesc] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<memo>%@</memo>", todoEvent.memo] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<reminder_dismiss>%d</reminder_dismiss>", todoEvent.reminderDismiss] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<reminder_start_time>%@</reminder_start_time>", todoEvent.reminderStartTime] dataUsingEncoding:NSUTF8StringEncoding]];
			//DoLog(DEBUG,@"bk4");
			[xmlData appendData:[[NSString stringWithFormat:@"<attach_file_count>%d</attach_file_count>", 0] dataUsingEncoding:NSUTF8StringEncoding]];
			/*[xmlData appendData:[[NSString stringWithFormat:@"attach_file"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"<file_size>%@</file_size>", @"file_size"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"<file_type>%@</file_type>", @"file_type"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"<file_content>%@</file_content>", @"file_content"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"</attach_file>", todoEvent.calendarId] dataUsingEncoding:NSUTF8StringEncoding]];*/
			
			[xmlData appendData:[[NSString stringWithFormat:@"</calendar_data>"] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"</con_c_add>"] dataUsingEncoding:NSUTF8StringEncoding]];
			
			con_c_add_count++;
		}
		/* calendar 為 del */
		else if (todoEvent.status == 3)
		{
			[xmlData appendData:[[NSString stringWithFormat:@"<con_c_del>"] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<server_id>%@</server_id>", todoEvent.serverId] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"</con_c_del>"] dataUsingEncoding:NSUTF8StringEncoding]];
			con_c_del_count++;
			
		}
		/* calendar 為 upd */
		else
		{
			[xmlData appendData:[[NSString stringWithFormat:@"<con_c_upd>"] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<server_id>%@</server_id>", todoEvent.serverId] dataUsingEncoding:NSUTF8StringEncoding]];
			
			[xmlData appendData:[[NSString stringWithFormat:@"<calendar_data>"] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<folder_id>%@</folder_id>", todoCategory.serverId] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<create_time>%@</create_time>", todoEvent.dtStamp] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<cal_type>%d</cal_type>", todoEvent.calType] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<all_day_event>%d</all_day_event>", todoEvent.allDayEvent] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<time_zone>%d</time_zone>", todoEvent.timeZone] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<busy_status>%d</busy_status>", todoEvent.busyStatus] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<organizer_name>%@</organizer_name>", todoEvent.organizerName] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<organizer_email>%@</organizer_email>", todoEvent.organizerEmail] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<end_time>%@</end_time>", todoEvent.endTime] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<location>%@</location>", todoEvent.location] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<reminder>%d</reminder>", todoEvent.reminder] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<sensitivity>%d</sensitivity>", todoEvent.sensitivity] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<subject>%@</subject>", todoEvent.subject] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<start_time>%@</start_time>", todoEvent.startTime] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<uid>%@</uid>", todoEvent.uid] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<meeting_status>%d</meeting_status>", todoEvent.meetingStatus] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<disallow_newtime>%d</disallow_newtime>", todoEvent.disallowNewTimeProposal] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<response_requested>%d</response_requested>", todoEvent.responseRequested] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<appointment_replytime>%@</appointment_replytime>", todoEvent.appointmentReplyTime] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<response_type>%d</response_type>", todoEvent.responseType] dataUsingEncoding:NSUTF8StringEncoding]];
			if([todoEvent.calRecurrenceId integerValue] > 0){
				TodoEvent *parentEvent = [[TodoEvent alloc] initWithEventId:todoEvent.calRecurrenceId database:mySqlite.database];
				[xmlData appendData:[[NSString stringWithFormat:@"<cal_recurrence_id>%@</cal_recurrence_id>", parentEvent.serverId] dataUsingEncoding:NSUTF8StringEncoding]];
				[parentEvent release];
			}else{
				[xmlData appendData:[[NSString stringWithFormat:@"<cal_recurrence_id>%@</cal_recurrence_id>", todoEvent.calRecurrenceId] dataUsingEncoding:NSUTF8StringEncoding]];
			}
			[xmlData appendData:[[NSString stringWithFormat:@"<is_exception>%d</is_exception>", todoEvent.isException] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<note_id>%@</note_id>", todoEvent.noteId] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<event_desc>%@</event_desc>", todoEvent.eventDesc] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<memo>%@</memo>", todoEvent.memo] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<reminder_dismiss>%d</reminder_dismiss>", todoEvent.reminderDismiss] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"<reminder_start_time>%@</reminder_start_time>", todoEvent.reminderStartTime] dataUsingEncoding:NSUTF8StringEncoding]];
			
			[xmlData appendData:[[NSString stringWithFormat:@"<attach_file_count>%d</attach_file_count>", 0] dataUsingEncoding:NSUTF8StringEncoding]];
			/*[xmlData appendData:[[NSString stringWithFormat:@"attach_file"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"<file_size>%@</file_size>", @"file_size"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"<file_type>%@</file_type>", @"file_type"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"<file_content>%@</file_content>", @"file_content"] dataUsingEncoding:NSUTF8StringEncoding]];
			 [xmlData appendData:[[NSString stringWithFormat:@"</attach_file>", todoEvent.calendarId] dataUsingEncoding:NSUTF8StringEncoding]];*/
			
			[xmlData appendData:[[NSString stringWithFormat:@"</calendar_data>"] dataUsingEncoding:NSUTF8StringEncoding]];
			[xmlData appendData:[[NSString stringWithFormat:@"</con_c_upd>"] dataUsingEncoding:NSUTF8StringEncoding]];
			
			
			con_c_upd_count++;
		}
		
		
		[todoEvent release];
		[todoCategory release];
	}
	// 設定 request 各數目
	[xmlData appendData:[[NSString stringWithFormat:@"<con_c_add_count>%d</con_c_add_count>", con_c_add_count] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<con_c_del_count>%d</con_c_del_count>", con_c_del_count] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"<con_c_upd_count>%d</con_c_upd_count>", con_c_upd_count] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:[[NSString stringWithFormat:@"</con_c_req>"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	/* con_c_rpl_count 的數目 */
	if (respCount > 0)
		con_c_rpl_count = 1;
	
	[xmlData appendData:[[NSString stringWithFormat:@"<con_c_rpl_count>%d</con_c_rpl_count>", con_c_rpl_count] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	/* 設定 con_c_rpl 的內容 */
	[xmlData appendData:[[NSString stringWithFormat:@"<con_c_rpl>"] dataUsingEncoding:NSUTF8StringEncoding]];
	[xmlData appendData:iRespData];	
	[xmlData appendData:[[NSString stringWithFormat:@"</con_c_rpl>"] dataUsingEncoding:NSUTF8StringEncoding]];
	if(hasMoreDataClient == YES){
		[xmlData appendData:[[NSString stringWithFormat:@"<has_more>%@</has_more>", @"Y"] dataUsingEncoding:NSUTF8StringEncoding]];
	}else{
		[xmlData appendData:[[NSString stringWithFormat:@"<has_more>%@</has_more>", @"N"] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	[xmlData appendData:[[NSString stringWithFormat:@"</content_sync_req>"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return xmlData;
	
}







@end