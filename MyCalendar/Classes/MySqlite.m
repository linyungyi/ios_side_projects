//
//  MySqlite.m
//  MyCalendar
//
//  Created by yves ho on 2010/2/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MySqlite.h"
#import "TodoEvent.h"
#import "TodoCategory.h"
#import "DateTimeUtil.h"
#import "RuleArray.h"
#import "ListTodoEvent.h"
#import "MyCalendarAppDelegate.h"
#import "SyncOperation.h"
#import "ProfileUtil.h"

@implementation MySqlite

@synthesize myPaths;
@synthesize dbName;
@synthesize database;

//static sqlite3 *database;

- (id)init {
	if (self = [super init]) {
		 
		//self.dbName=@"userCalendar1.sqlite";
		self.dbName=PIMDATABASE;
		
		if([self checkDatabase]==YES){
			DoLog(DEBUG,@"%@",self.myPaths);
			MyCalendarAppDelegate *myApp=[[UIApplication sharedApplication] delegate];
			database=myApp.database;
			if(database==NULL){
				if(sqlite3_open([self.myPaths UTF8String], &database)!=SQLITE_OK) {
					sqlite3_close(database);
					NSAssert1(0, @"Fail to open database. error=%@",sqlite3_errmsg(database)); 
				}else
					DoLog(DEBUG,@"open database ok");
				myApp.database=database;
			}
		}
	}
	return self;
}

/*分類可用筆數*/
- (NSInteger) getTodoCategoryCount{
	static sqlite3_stmt *count_category = nil;
	
	if(count_category == nil){
		const char *count_category_sql = "SELECT count(*) FROM pim_cal_folder where state_flag!=2 and folder_id>0";
		
		if (sqlite3_prepare_v2(database, count_category_sql, -1, &count_category, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
		}
	}
	
	NSInteger count;
	if(sqlite3_step(count_category) == SQLITE_ROW) {
		count=sqlite3_column_int(count_category,0);
	}else
		count=0;
	sqlite3_reset(count_category);
	
	return count;
}

/*預設分類為第一筆分類*/
- (TodoCategory *) getDefaultCategory{
	TodoCategory *todoCategory=nil;
	static sqlite3_stmt *default_category = nil;
	
	if(default_category == nil){
		const char *default_category_sql = "SELECT folder_id FROM pim_cal_folder where state_flag!=2 and folder_id>0 order by folder_type desc,folder_id limit 1";
		
		if (sqlite3_prepare_v2(database, default_category_sql, -1, &default_category, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
		}
	}
	
	NSString *tmpString1;
	while(sqlite3_step(default_category) == SQLITE_ROW) {
		if((char *)sqlite3_column_text(default_category,0)!=NULL)
			tmpString1=[NSString stringWithUTF8String:(char*)sqlite3_column_text(default_category,0)];
		todoCategory = [[TodoCategory alloc]initWithCategoryId:tmpString1 database:database ];	 
		if([todoCategory.folderId length]>0)
			break;
	} 
	sqlite3_reset(default_category);
	
	return todoCategory;
}

/*所有可用分類*/
- (NSArray *) getTodoCategorys{
		NSMutableArray *result=[[NSMutableArray alloc]init];
	
		TodoCategory *todoCategory;
		static sqlite3_stmt *list_category = nil;
	 
		if(list_category == nil){
			const char *list_category_sql = "SELECT folder_id FROM pim_cal_folder where state_flag!=2 and folder_id>0";
	 
			if (sqlite3_prepare_v2(database, list_category_sql, -1, &list_category, NULL) != SQLITE_OK) {
				NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
			}else
				DoLog(DEBUG,@"prepare sql ok");
		}
	 
		NSMutableString *tmpString1;
		while(sqlite3_step(list_category) == SQLITE_ROW) {
			if((char *)sqlite3_column_text(list_category,0)!=NULL)
				tmpString1=[NSString stringWithUTF8String:(char*)sqlite3_column_text(list_category,0)];
			todoCategory = [[TodoCategory alloc]initWithCategoryId:tmpString1 database:database ];	 
			if([todoCategory.folderId length]>0)
				[result addObject:todoCategory];
			[todoCategory release];
			
		} 
		sqlite3_reset(list_category);
	 
		return result;
}

/*新增分類*/
- (BOOL) insTodoCategory:(TodoCategory *)myCategory{
		BOOL result;
	
		static sqlite3_stmt *insert_category = nil;
	 
		if (insert_category == nil) {
			//const char *sql = "insert into pim_cal_folder (folder_id,folder_name,color_rgb,display_flag,state_flag,sync_flag,lastime_sync,created_datetime,modified_datetime,photo_path,memo,user_id,server_id,folder_type) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
			const char *insert_category_sql = "insert into pim_cal_folder (folder_name,color_rgb,display_flag,state_flag,sync_flag,lastime_sync,created_datetime,modified_datetime,photo_path,memo,user_id,server_id,folder_type,sync_status) values (?,?,?,?,?,?,?,?,?,?,?,?,?,0)";
			if (sqlite3_prepare_v2(database, insert_category_sql, -1, &insert_category, NULL) != SQLITE_OK) {
				NSAssert1(0, @"prepare insert statement error='%s'.", sqlite3_errmsg(database));
				result=NO;
			}
		}
	 
	//if(myCategory.folderId != nil){
		int i=1;
		//sqlite3_bind_int(insert_category,i++,myCategory.folderId);
		//sqlite3_bind_text(insert_category,i++,[myCategory.folderId UTF8String],-1,SQLITE_TRANSIENT);
		sqlite3_bind_text(insert_category,i++,[myCategory.folderName UTF8String],-1,SQLITE_TRANSIENT);
		sqlite3_bind_int(insert_category,i++,myCategory.colorRgb);
		sqlite3_bind_int(insert_category,i++,myCategory.displayFlag);
		sqlite3_bind_int(insert_category,i++,myCategory.stateFlag);
		sqlite3_bind_int(insert_category,i++,myCategory.syncFlag);
	
		//sqlite3_bind_int(insert_category,i++,myCategory.lastimeSync);
		sqlite3_bind_text(insert_category,i++,[myCategory.lastimeSync UTF8String],-1,SQLITE_TRANSIENT);
	
		//sqlite3_bind_int(insert_category,i++,myCategory.createdDatetime);
		sqlite3_bind_text(insert_category,i++,[myCategory.createdDatetime UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(insert_category,i++,myCategory.modifiedDatetime);
		sqlite3_bind_text(insert_category,i++,[myCategory.modifiedDatetime UTF8String],-1,SQLITE_TRANSIENT);
		
		
		sqlite3_bind_text(insert_category,i++,[myCategory.photoPath UTF8String],-1,SQLITE_TRANSIENT);
		sqlite3_bind_text(insert_category,i++,[myCategory.memo UTF8String],-1,SQLITE_TRANSIENT);	
	
		//sqlite3_bind_int(insert_category,i++,myCategory.userId);
		sqlite3_bind_text(insert_category,i++,[myCategory.userId UTF8String],-1,SQLITE_TRANSIENT);
	
		//sqlite3_bind_int(insert_category,i++,myCategory.serverId);
		sqlite3_bind_text(insert_category,i++,[myCategory.serverId UTF8String],-1,SQLITE_TRANSIENT);
	
		sqlite3_bind_int(insert_category,i++,myCategory.folderType);
	
		if(SQLITE_DONE != sqlite3_step(insert_category)){
			DoLog(ERROR,@"Error insert data. '%s'", sqlite3_errmsg(database)); 
			result=NO;
		}else
			result=YES;
	
		NSString *keyString=[NSString stringWithFormat:@"%ld",sqlite3_last_insert_rowid(database)];
		myCategory.folderId=keyString;
		DoLog(DEBUG,@"new folder_id=%@ %@",keyString,[self getMaxSequence:@"pim_cal_folder" trans:NO]);
		
		sqlite3_reset(insert_category);
	//}else
	//	result=NO;
	
	return result;
}

/*更改分類,刪除已同步分類亦使用此方法*/
- (BOOL) updTodoCategory:(TodoCategory *)myCategory{
	BOOL result;
	
	static sqlite3_stmt *update_category = nil;
	
	if (update_category == nil) {
		//const char *update_category_sql = "update pim_cal_folder set folder_name=?,color_rgb=?,display_flag=?,state_flag=?,sync_flag=?,lastime_sync=?,created_datetime=?,modified_datetime=?,photo_path=?,memo=?,user_id=?,server_id=?,folder_type=? where folder_id=? and server_id=?";
		const char *update_category_sql = "update pim_cal_folder set folder_name=?,color_rgb=?,display_flag=?,state_flag=?,sync_flag=?,lastime_sync=?,created_datetime=?,modified_datetime=?,photo_path=?,memo=?,user_id=?,server_id=?,folder_type=? where folder_id=?";
		if (sqlite3_prepare_v2(database, update_category_sql, -1, &update_category, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	if(myCategory.stateFlag==2)//更新為刪除需刪除或更新相關事件
		flag=[self delRelationCategory:myCategory.folderId server:myCategory.serverId];
	else
		flag=YES;
	
	if(flag==YES){
		
		int i=1;
		sqlite3_bind_text(update_category,i++,[myCategory.folderName UTF8String],-1,SQLITE_TRANSIENT);
		sqlite3_bind_int(update_category,i++,myCategory.colorRgb);
		sqlite3_bind_int(update_category,i++,myCategory.displayFlag);
		sqlite3_bind_int(update_category,i++,myCategory.stateFlag);
		sqlite3_bind_int(update_category,i++,myCategory.syncFlag);
		DoLog(DEBUG,@"update %@ state=%d sync=%d",myCategory.folderId,myCategory.stateFlag,myCategory.syncFlag);
		
		//sqlite3_bind_int(update_category,i++,myCategory.lastimeSync);
		sqlite3_bind_text(update_category,i++,[myCategory.lastimeSync UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(update_category,i++,myCategory.createdDatetime);
		sqlite3_bind_text(update_category,i++,[myCategory.createdDatetime UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(update_category,i++,myCategory.modifiedDatetime);
		sqlite3_bind_text(update_category,i++,[myCategory.modifiedDatetime UTF8String],-1,SQLITE_TRANSIENT);
		
		sqlite3_bind_text(update_category,i++,[myCategory.photoPath UTF8String],-1,SQLITE_TRANSIENT);
		sqlite3_bind_text(update_category,i++,[myCategory.memo UTF8String],-1,SQLITE_TRANSIENT);	
		
		//sqlite3_bind_int(update_category,i++,myCategory.userId);
		sqlite3_bind_text(update_category,i++,[myCategory.userId UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(update_category,i++,myCategory.serverId);
		sqlite3_bind_text(update_category,i++,[myCategory.serverId UTF8String],-1,SQLITE_TRANSIENT);
		
		sqlite3_bind_int(update_category,i++,myCategory.folderType);

		
		
		
		//sqlite3_bind_int(update_category,i++,myCategory.folderId);
		sqlite3_bind_text(update_category,i++,[myCategory.folderId UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(update_category,i++,myCategory.serverId);
		//sqlite3_bind_text(update_category,i++,[myCategory.serverId UTF8String],-1,SQLITE_TRANSIENT);
		
		if(SQLITE_DONE != sqlite3_step(update_category)){
			DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
			flag=NO;
		}else
			flag=YES;
	}
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(update_category);
	
	return result;
}

/*直接刪除分類*/
- (BOOL) delTodoCategory:(TodoCategory *)myCategory{
	BOOL result;
	
	static sqlite3_stmt *delete_category = nil;
	
	if (delete_category == nil) {
		const char *delete_category_sql = "delete from pim_cal_folder where folder_id=? and sync_flag=0";
		if (sqlite3_prepare_v2(database, delete_category_sql, -1, &delete_category, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	
	/*需刪除未同步事件與更新已同步事件為刪除狀態*/
	flag=[self delRelationCategory:myCategory.folderId server:myCategory.serverId];
	
	if(flag==YES){
		sqlite3_bind_text(delete_category,1,[myCategory.folderId UTF8String],-1,SQLITE_TRANSIENT);
		if(SQLITE_DONE != sqlite3_step(delete_category)){
			DoLog(ERROR,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
			flag=NO;
		}else
			flag=YES;
	}
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK", 0, 0, 0);
		result=NO;
	}
	sqlite3_reset(delete_category);
	
	return result;
}

- (BOOL) delRelationCategory:(NSString *) folderId server:(NSString *) sId{
	BOOL result;
	
	static sqlite3_stmt *del_category = nil;
	static sqlite3_stmt *del_category1 = nil;
	static sqlite3_stmt *del_category2 = nil;
	
	if (del_category == nil) {/*刪除分類下未同步的重覆事件規則*/
		const char *del_category_sql = "delete from pim_cal_recurrence where calendar_id in (select calendar_id from pim_calendar where is_synced=0 and calendar_id=cal_recurrence_id and folder_id=?) and folder_id=?";
		if (sqlite3_prepare_v2(database, del_category_sql, -1, &del_category, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	if (del_category1 == nil) {/*刪除分類下未同步的事件*/
		const char *del_category1_sql = "delete from pim_calendar where is_synced=0 and folder_id=?";
		if (sqlite3_prepare_v2(database, del_category1_sql, -1, &del_category1, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	/*
	if (del_category2 == nil) {//更新為刪除狀態
		const char *del_category2_sql = "update pim_calendar set status=3,is_synced=1 where is_synced!=0 and folder_id=?";
		if (sqlite3_prepare_v2(database, del_category2_sql, -1, &del_category2, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	*/
	if (del_category2 == nil) {//分類不能更改,直接刪除相關事件不同步
		const char *del_category2_sql = "delete from pim_calendar where is_synced!=0 and folder_id=?";
		if (sqlite3_prepare_v2(database, del_category2_sql, -1, &del_category2, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	sqlite3_bind_text(del_category,1,[folderId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(del_category,2,[folderId UTF8String],-1,SQLITE_TRANSIENT);
	if(SQLITE_DONE != sqlite3_step(del_category)){
		DoLog(ERROR,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
		result=NO;
	}else
		result=YES;
	sqlite3_reset(del_category);
	
	if(result==YES){
		sqlite3_bind_text(del_category1,1,[folderId UTF8String],-1,SQLITE_TRANSIENT);
		if(SQLITE_DONE != sqlite3_step(del_category1)){
			DoLog(ERROR,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
			result=NO;
		}else
			result=YES;
		sqlite3_reset(del_category1);
	}
	
	if(result==YES){
		sqlite3_bind_text(del_category2,1,[folderId UTF8String],-1,SQLITE_TRANSIENT);
		if(SQLITE_DONE != sqlite3_step(del_category2)){
			DoLog(ERROR,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
			result=NO;
		}else
			result=YES;
		sqlite3_reset(del_category2);
	}
	
		
	return result;
}

- (NSString *) getMaxSequence:(NSString *)tableName trans:(BOOL)tflag{
	
	//NSUInteger max;
	NSString *max=nil;
	NSInteger count=0;
	
	static sqlite3_stmt *sel_calendar = nil;
	static sqlite3_stmt *sel_category = nil;
	
	if(sel_calendar == nil){
		const char *sql1 = "SELECT max(calendar_id),count(*) FROM pim_calendar";
		
		if (sqlite3_prepare_v2(database, sql1, -1, &sel_calendar, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare select statement error='%s'.", sqlite3_errmsg(database));
		}
	}
	
	if(sel_category == nil){
		const char *sql2 = "SELECT max(folder_id),count(*) FROM pim_cal_folder";
		
		if (sqlite3_prepare_v2(database, sql2, -1, &sel_category, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare select statement error='%s'.", sqlite3_errmsg(database));
		}
	}
	
	if([tableName isEqualToString:@"pim_calendar"]==YES){
		if(sqlite3_step(sel_calendar) == SQLITE_ROW) {
			//max=sqlite3_column_int(sel_calendar,0);
			if((char *)sqlite3_column_text(sel_calendar,0)!=NULL)
				max=[NSString stringWithUTF8String:(char*)sqlite3_column_text(sel_calendar,0)];
			
			count=sqlite3_column_int(sel_calendar,1);
		}else
			count=-1;
		sqlite3_reset(sel_calendar);
	}else if([tableName isEqualToString:@"pim_cal_folder"]==YES){
		if(sqlite3_step(sel_category) == SQLITE_ROW) {
			//max=sqlite3_column_int(sel_category,0);
			if((char *)sqlite3_column_text(sel_category,0)!=NULL)
				max=[NSString stringWithUTF8String:(char*)sqlite3_column_text(sel_category,0)];
			
			count=sqlite3_column_int(sel_category,1);
		}else
			count=-1;
		sqlite3_reset(sel_category);
	}
	
	if(count==-1)
		max=nil;
	else if(count==0)
		max=@"0";
	
	return max;
	
	/*
	//NSUInteger max;
	NSString *max;
	//NSNumber tmp;
	NSString *tmp;
	NSInteger count;
	
	static sqlite3_stmt *sel_sequence = nil;
	static sqlite3_stmt *upd_sequence = nil;
	static sqlite3_stmt *ins_sequence = nil;
	
	if(sel_sequence == nil){
		const char *sql1 = "SELECT seq_value,(seq_value+1),count(*) FROM pim_sequence WHERE table_name=?";
		
		if (sqlite3_prepare_v2(database, sql1, -1, &sel_sequence, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare select statement error='%s'.", sqlite3_errmsg(database));
		}
	}
	
	if(upd_sequence == nil){
		const char *sql2 = "UPDATE pim_sequence SET seq_value=? WHERE table_name=? and seq_value=?";
		//const char *sql2 = "UPDATE pim_sequence SET seq_value=? WHERE table_name=?";
		
		if (sqlite3_prepare_v2(database, sql2, -1, &upd_sequence, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
		}
	}
	
	if(ins_sequence == nil){
		const char *sql3 = "INSERT into pim_sequence (table_name,seq_value) values(?,?)";
		
		if (sqlite3_prepare_v2(database, sql3, -1, &ins_sequence, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare insert statement error='%s'.", sqlite3_errmsg(database));
		}
	}
		
	BOOL flag;
	if(tflag==NO){
		sqlite3_exec(database, "BEGIN", 0, 0, 0);
		DoLog(INFO,@"BEGIN");
	}
	
	sqlite3_bind_text(sel_sequence,1,[tableName UTF8String],-1,SQLITE_TRANSIENT);
	if(sqlite3_step(sel_sequence) == SQLITE_ROW) {
		//tmp=sqlite3_column_int(sel_sequence,0);
		if((char *)sqlite3_column_text(sel_sequence,0)!=NULL)
			tmp=[NSString stringWithUTF8String:(char*)sqlite3_column_text(sel_sequence,0)];
		//max=sqlite3_column_int(sel_sequence,1);
		if((char *)sqlite3_column_text(sel_sequence,1)!=NULL)
			max=[NSString stringWithUTF8String:(char*)sqlite3_column_text(sel_sequence,1)];
			
		count=sqlite3_column_int(sel_sequence,2);
		sqlite3_reset(sel_sequence);
	} 
	
	if(count==0){
		max=@"2";
		sqlite3_bind_text(ins_sequence,1,[tableName UTF8String],-1,SQLITE_TRANSIENT);
		sqlite3_bind_text(ins_sequence,2,[max UTF8String],-1,SQLITE_TRANSIENT);
		if(SQLITE_DONE != sqlite3_step(ins_sequence)){
			DoLog(ERROR,@"Error insert sequence data. '%s'", sqlite3_errmsg(database)); 
			flag=NO;
		}else
			flag=YES;
		sqlite3_reset(ins_sequence);
	}else{
		DoLog(DEBUG,@"max=%@,tmp=%@,tableName=%@",max,tmp,tableName);
		sqlite3_bind_text(upd_sequence,1,[max UTF8String],-1,SQLITE_TRANSIENT);
		sqlite3_bind_text(upd_sequence,2,[tableName UTF8String],-1,SQLITE_TRANSIENT);
		sqlite3_bind_text(upd_sequence,3,[tmp UTF8String],-1,SQLITE_TRANSIENT);
		if(SQLITE_DONE != sqlite3_step(upd_sequence)){			
			DoLog(ERROR,@"Error update sequence data. '%s'", sqlite3_errmsg(database));
			flag=NO;
		}else
			flag=YES;
		sqlite3_reset(upd_sequence);
	}
	
	if(flag==YES){
		if(tflag==NO){
			sqlite3_exec(database, "COMMIT",0,0,0);
			DoLog(INFO,@"COMMIT");
		}
		return max;
	}else{
		if(tflag==NO){
			sqlite3_exec(database, "ROLLBACK",0,0,0);
			DoLog(DEBUG,@"ROLLBACK");
		}
		return nil;
	}
	*/
}



- (void)dealloc {
	//DoLog(DEBUG,@"dealloc");
	//sqlite3_close(database);
	[myPaths release];
	[dbName release];
	[super dealloc];
}

/*已同步過刪除事件採更新狀態*/
- (BOOL) delUpdTodoEvent:(TodoEvent *) myEvent trans:(BOOL)tflag{
	BOOL result;
		
	static sqlite3_stmt *del_calendar1 = nil;
	static sqlite3_stmt *del_calendar2 = nil;
	//static sqlite3_stmt *del_recurrence = nil;
	
	if (del_calendar1 == nil) {//更新第一筆事件為刪除狀態且需同步
		const char *del_calendar1_sql = "update pim_calendar set status=3,is_synced=1,Deleted=? where calendar_id=? and server_id=?";
		//const char *del_calendar1_sql = "update pim_calendar set status=3,is_synced=1,Deleted=? where calendar_id=?";
		if (sqlite3_prepare_v2(database, del_calendar1_sql, -1, &del_calendar1, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement1 error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	if (del_calendar2 == nil) {//更新重覆事件為刪除狀態且需同步(已同步)
		const char *del_calendar2_sql = "update pim_calendar set status=3,is_synced=2 where cal_recurrence_id = ? ";
		if (sqlite3_prepare_v2(database, del_calendar2_sql, -1, &del_calendar2, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement2 error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	/*
	if (del_recurrence == nil) {//刪除重覆規則
		const char *sql3 = "delete from pim_cal_recurrence where calendar_id=?";
		if (sqlite3_prepare_v2(database, sql3, -1, &del_recurrence, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement3 error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	*/
	
	//if(myEvent.calType>0 && [myEvent.calRecurrenceId isEqualToString:myEvent.serverId]==YES){
	if(myEvent.calType==1){	/*重覆事件一系列*/
		BOOL flag;
		if(tflag==NO){
			sqlite3_exec(database, "BEGIN", 0, 0, 0);
			DoLog(INFO,@"BEGIN");
		}
		/*
		//sqlite3_bind_int(del_recurrence,1,[myEvent.serverId intValue]);
		sqlite3_bind_text(del_recurrence,1,[myEvent.serverId UTF8String],-1,SQLITE_TRANSIENT);
		if(SQLITE_DONE != sqlite3_step(del_recurrence)){
			DoLog(DEBUG,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
			flag=NO;
		}else
			flag=YES;
		*/
		
		flag=YES;
		if(flag==YES){//更新重覆事件為刪除狀態且需同步
			//sqlite3_bind_int(del_calendar2,1,[myEvent.serverId intValue]);
			sqlite3_bind_text(del_calendar2,1,[myEvent.calendarId UTF8String],-1,SQLITE_TRANSIENT);
			if(SQLITE_DONE != sqlite3_step(del_calendar2)){
				DoLog(ERROR,@"Error update delete child data. '%s'", sqlite3_errmsg(database)); 
				flag=NO;
			}else
				flag=YES;
		}
		
		if(flag==YES){//更新第一筆事件為刪除狀態且需同步
			//sqlite3_bind_int(del_calendar1,1,1);
			sqlite3_bind_int(del_calendar1,1,0);
			
			//sqlite3_bind_int(del_calendar1,2,[myEvent.calendarId intValue]);
			sqlite3_bind_text(del_calendar1,2,[myEvent.calendarId UTF8String],-1,SQLITE_TRANSIENT);
			
			//sqlite3_bind_int(del_calendar1,3,[myEvent.serverId intValue]);
			sqlite3_bind_text(del_calendar1,3,[myEvent.serverId UTF8String],-1,SQLITE_TRANSIENT);
			
			if(SQLITE_DONE != sqlite3_step(del_calendar1)){
				DoLog(ERROR,@"Error update delete master data. '%s'", sqlite3_errmsg(database)); 
				flag=NO;
			}else
				flag=YES;
		}
		
		if(flag==YES){
			if(tflag==NO){
				sqlite3_exec(database, "COMMIT",0,0,0);
				DoLog(INFO,@"COMMIT");
			}
			result=YES;
		}else{
			if(tflag==NO){
				sqlite3_exec(database, "ROLLBACK",0,0,0);
				DoLog(INFO,@"ROLLBACK");
			}
			result=NO;
		}
		//sqlite3_reset(del_recurrence);
		sqlite3_reset(del_calendar2);
		sqlite3_reset(del_calendar1);	
	}else{/*一般事件與例外事件*/
		
		sqlite3_bind_int(del_calendar1,1,0);
		
		//sqlite3_bind_int(del_calendar1,2,myEvent.calendarId);
		sqlite3_bind_text(del_calendar1,2,[myEvent.calendarId UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(del_calendar1,3,myEvent.serverId);
		sqlite3_bind_text(del_calendar1,3,[myEvent.serverId UTF8String],-1,SQLITE_TRANSIENT);
		
		if(SQLITE_DONE != sqlite3_step(del_calendar1)){
			DoLog(ERROR,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
			result=NO;
		}else
			result=YES;
		sqlite3_reset(del_calendar1);
	}

	
	return result;
}

/*未同步直接刪除事件*/
- (BOOL) delTodoEvent:(TodoEvent *) myEvent trans:(BOOL)tflag{
	BOOL result;
	
	static sqlite3_stmt *delete_calendar1 = nil;
	static sqlite3_stmt *delete_calendar2 = nil;
	static sqlite3_stmt *delete_recurrence = nil;
	
	if (delete_calendar1 == nil) {//刪除第一筆事件
		const char *delete_calendar1_sql = "delete from pim_calendar where calendar_id=? and is_synced=0";
		if (sqlite3_prepare_v2(database, delete_calendar1_sql, -1, &delete_calendar1, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement1 error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	if (delete_calendar2 == nil) {//刪除重覆事件
		const char *delete_calendar2_sql = "delete from pim_calendar where cal_recurrence_id = ? and is_synced=0";
		if (sqlite3_prepare_v2(database, delete_calendar2_sql, -1, &delete_calendar2, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement2 error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	if (delete_recurrence == nil) {//刪除重覆規則
		const char *delete_recurrence_sql = "delete from pim_cal_recurrence where calendar_id=?";
		if (sqlite3_prepare_v2(database, delete_recurrence_sql, -1, &delete_recurrence, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement3 error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	//if(myEvent.calType>0 && [myEvent.calRecurrenceId isEqualToString:myEvent.calendarId]==YES){
	if(myEvent.calType==1){/*一系列刪除*/
		BOOL flag;
		if(tflag==NO){
			sqlite3_exec(database, "BEGIN", 0, 0, 0);
			DoLog(INFO,@"BEGIN");
		}
		
		
		//sqlite3_bind_int(delete_recurrence,1,[myEvent.calendarId intValue]);
		sqlite3_bind_text(delete_recurrence,1,[myEvent.calendarId UTF8String],-1,SQLITE_TRANSIENT);
		if(SQLITE_DONE != sqlite3_step(delete_recurrence)){
			DoLog(ERROR,@"Error delete recurrence data. '%s'", sqlite3_errmsg(database)); 
			flag=NO;
		}else
			flag=YES;
				
		if(flag==YES){
			//sqlite3_bind_int(delete_calendar2,1,[myEvent.calendarId intValue]);
			sqlite3_bind_text(delete_calendar2,1,[myEvent.calendarId UTF8String],-1,SQLITE_TRANSIENT);
			if(SQLITE_DONE != sqlite3_step(delete_calendar2)){
				DoLog(ERROR,@"Error delete child data. '%s'", sqlite3_errmsg(database)); 
				flag=NO;
			}else
				flag=YES;
		}
			
		if(flag==YES){
			//sqlite3_bind_int(delete_calendar1,1,[myEvent.calendarId intValue]);
			sqlite3_bind_text(delete_calendar1,1,[myEvent.calendarId UTF8String],-1,SQLITE_TRANSIENT);
			if(SQLITE_DONE != sqlite3_step(delete_calendar1)){
				DoLog(ERROR,@"Error delete calendar data. '%s'", sqlite3_errmsg(database)); 
				flag=NO;
			}else
				flag=YES;
		}

		
		if(flag==YES){
			if(tflag==NO){
				sqlite3_exec(database, "COMMIT",0,0,0);
				DoLog(INFO,@"COMMIT");
			}
			result=YES;
		}else{
			if(tflag==NO){
				sqlite3_exec(database, "ROLLBACK",0,0,0);
				DoLog(INFO,@"ROLLBACK");
			}
			result=NO;
		}
		sqlite3_reset(delete_recurrence);
		sqlite3_reset(delete_calendar2);
		sqlite3_reset(delete_calendar1);
	}else{/*一般事件與例外事件刪除*/
		
		//sqlite3_bind_int(delete_calendar1,1,myEvent.calendarId);
		sqlite3_bind_text(delete_calendar1,1,[myEvent.calendarId UTF8String],-1,SQLITE_TRANSIENT);
		
		if(SQLITE_DONE != sqlite3_step(delete_calendar1)){
			DoLog(ERROR,@"Error delete calendar master data. '%s'", sqlite3_errmsg(database)); 
			result=NO;
		}else
			result=YES;
		sqlite3_reset(delete_calendar1);
	}
	
	
	return result;
}

/*更新事件*/
/*0 主題*/
/*1 地點*/
/*2 0起始 YYYYMMDDhhmmss#YYYY/MM/DD hh:mm:ss*/
/*2 1終止 YYYYMMDDhhmmss#YYYY/MM/DD hh:mm:ss/
 /*3 0重覆 value#description*/
/*3 1重覆結束時間 YYYYMMDDhhmmss#YYYY/MM/DD hh:mm:ss*/
/*4 通知 分#x天x時x分*/
/*5 分類 folderId#folderName*/
/*6 圖示*/
/*7 備註*/
- (BOOL) updTodoEvent:(NSString *)cId server:(NSString *)sId data:(NSArray *) myEvent{
	BOOL result;
	
	static sqlite3_stmt *update_calendar = nil;
	
	if (update_calendar == nil) {
		const char *update_calendar_sql = "update pim_calendar set subject=?,location=?,StartTime=?,EndTime=?,Reminder=?,folder_id=?,memo=?,reminder_start_time=?,last_write=?,status=?,is_synced=?,IsException=?,AllDayEvent=?,event_icon=? where calendar_id=? and server_id=? and status!=3";
		if (sqlite3_prepare_v2(database, update_calendar_sql, -1, &update_calendar, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	TodoEvent *todoEvent = [[TodoEvent alloc] initWithEventId:cId  database:database];
	
	NSArray *tmpArray=[[[myEvent objectAtIndex:3] objectAtIndex:0] componentsSeparatedByString:@"#"];
	NSInteger redoRule=[[tmpArray objectAtIndex:0] intValue];
	/*
	if( (todoEvent.calType>0 && ( (todoEvent.isSynced==0 && [todoEvent.calRecurrenceId isEqualToString:todoEvent.calendarId]==YES)
			|| (todoEvent.isSynced!=0 && [todoEvent.calRecurrenceId isEqualToString:todoEvent.serverId]==YES) )) ||
		(todoEvent.calType==0 && (redoRule!=-1)) ) {
	*/
	if(todoEvent.calType==1 || (redoRule!=-1 && [todoEvent.calRecurrenceId isEqualToString:@"0"]==YES) ){
		/*一系列修改或單一事件改為重覆事件*/
		sqlite3_exec(database, "BEGIN", 0, 0, 0);
		DoLog(INFO,@"BEGIN");
	
		if(todoEvent.isSynced==0){//未同步直接刪除
			DoLog(DEBUG,@"isSynced=0");
			flag=[self delTodoEvent:todoEvent trans:YES];
		}else{//已同步更新狀態為刪除且需同步
			DoLog(DEBUG,@"isSynced!=0");
			flag=[self delUpdTodoEvent:todoEvent trans:YES];
		}
		
		if(flag==YES){//刪除後新增事件
			flag=[self insTodoEvent:myEvent trans:YES];
		}
	
		if(flag==YES){
			DoLog(INFO,@"COMMIT");
			sqlite3_exec(database, "COMMIT", 0, 0, 0);
			result=YES;
		}else{
			DoLog(INFO,@"ROLLBACK");
			sqlite3_exec(database, "ROLLBACK", 0, 0, 0);
			result=NO;
		}
	}else{/*修改單一事件或例外事件*/
		NSString *startTime;
		NSString *endTime;
		NSInteger reminderMins;
		NSString *folderId;
		NSString *eventIcon;
		
		tmpArray=[[[myEvent objectAtIndex:2] objectAtIndex:0] componentsSeparatedByString:@"#"];
		startTime=[tmpArray objectAtIndex:0];
		tmpArray=[[[myEvent objectAtIndex:2] objectAtIndex:1] componentsSeparatedByString:@"#"];
		endTime=[tmpArray objectAtIndex:0];
		
		tmpArray=[[[myEvent objectAtIndex:4] objectAtIndex:0] componentsSeparatedByString:@"#"];
		reminderMins=[[tmpArray objectAtIndex:0] intValue];
		
		tmpArray=[[[myEvent objectAtIndex:5] objectAtIndex:0] componentsSeparatedByString:@"#"];
		folderId=[tmpArray objectAtIndex:0];		
		/*
		tmpArray=[[[myEvent objectAtIndex:6] objectAtIndex:0] componentsSeparatedByString:@"#"];
		eventIcon=[tmpArray objectAtIndex:0];
		 */
		eventIcon=[[myEvent objectAtIndex:6] objectAtIndex:0];
		
		int i=1;
		//DoLog(DEBUG,@"%@",[[myEvent objectAtIndex:0] objectAtIndex:0]);
		sqlite3_bind_text(update_calendar,i++,[[[myEvent objectAtIndex:0] objectAtIndex:0] UTF8String],-1,SQLITE_TRANSIENT);
		sqlite3_bind_text(update_calendar,i++,[[[myEvent objectAtIndex:1] objectAtIndex:0] UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(update_calendar,i++,[startTime intValue]);
		sqlite3_bind_text(update_calendar,i++,[startTime UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(update_calendar,i++,[endTime intValue]);
		sqlite3_bind_text(update_calendar,i++,[endTime UTF8String],-1,SQLITE_TRANSIENT);
		
		sqlite3_bind_int(update_calendar,i++,reminderMins);
		
		//sqlite3_bind_int(update_calendar,i++,[folderId intValue]);
		sqlite3_bind_text(update_calendar,i++,[folderId UTF8String],-1,SQLITE_TRANSIENT);
		
		//memo
		sqlite3_bind_text(update_calendar,i++,[[[myEvent objectAtIndex:7] objectAtIndex:0] UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(update_calendar,i++,[[DateTimeUtil getStringFromDate:[DateTimeUtil getDiffDate:[DateTimeUtil getDateFromString:startTime] mins:(-1*reminderMins)] forKind:0] intValue]);
		sqlite3_bind_text(update_calendar,i++,[[DateTimeUtil getStringFromDate:[DateTimeUtil getDiffDate:[DateTimeUtil getDateFromString:startTime] mins:(-1*reminderMins)] forKind:0] UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(update_calendar,i++,[[DateTimeUtil getTodayString] intValue]);
		sqlite3_bind_text(update_calendar,i++,[[DateTimeUtil getTodayString] UTF8String],-1,SQLITE_TRANSIENT);
		
		if(todoEvent.isSynced!=0){
			sqlite3_bind_int(update_calendar,i++,2);
			sqlite3_bind_int(update_calendar,i++,1);
		}else{
			sqlite3_bind_int(update_calendar,i++,todoEvent.status);
			sqlite3_bind_int(update_calendar,i++,0);
		}
		
		if(todoEvent.calType!=0)
			sqlite3_bind_int(update_calendar,i++,1);
		else
			sqlite3_bind_int(update_calendar,i++,0);
		
		sqlite3_bind_int(update_calendar, i++, [DateTimeUtil chkAllDay:startTime endDate:endTime]);
		
		sqlite3_bind_text(update_calendar,i++,[eventIcon UTF8String],-1,SQLITE_TRANSIENT);

		
		
		//condition
		sqlite3_bind_text(update_calendar,i++,[cId UTF8String],-1,SQLITE_TRANSIENT);
		sqlite3_bind_text(update_calendar,i++,[sId UTF8String],-1,SQLITE_TRANSIENT);

		
		if(SQLITE_DONE != sqlite3_step(update_calendar)){
			DoLog(ERROR,@"Error update single data.%d %d '%s'",SQLITE_DONE,sqlite3_errcode(database) , sqlite3_errmsg(database)); 
			result=NO;
		}else
			result=YES;
		sqlite3_reset(update_calendar);
	}
	[todoEvent release];
	return result;
}

/*新增事件*/
/*0 主題*/
/*1 地點*/
/*2 0起始 YYYYMMDDhhmmss#YYYY/MM/DD hh:mm:ss*/
/*2 1終止 YYYYMMDDhhmmss#YYYY/MM/DD hh:mm:ss/
/*3 0重覆 value#description*/
/*3 1重覆結束時間 YYYYMMDDhhmmss#YYYY/MM/DD hh:mm:ss*/
/*4 通知 分#x天x時x分*/
/*5 分類 folderId#folderName*/
/*6 圖示*/
/*7 備註*/
- (BOOL) insTodoEvent:(NSArray *) myEvent trans:(BOOL)tflag{
	BOOL result;
	
	static sqlite3_stmt *ins_calendar = nil;
	//static sqlite3_stmt *upd_calendar = nil;
	static sqlite3_stmt *ins_recurrence = nil;
	
	if (ins_calendar == nil) {//新增事件
		const char *ins_calendar_sql = "insert into pim_calendar (user_id,folder_id,last_write,is_synced,status,need_sync,TimeZone,AllDayEvent,BusyStatus,DtStamp,EndTime,Location,Reminder,Sensitivity,Subject,StartTime,DisallowNewTimeProposal,ResponseRequested,ResponseType,cal_recurrence_id,IsException,Deleted,memo,reminder_dismiss,reminder_start_time,cal_type,server_id,sync_status,event_icon) values (?,?,?,0,1,1,?,?,0,?,?,?,?,0,?,?,0,0,0,?,0,0,?,?,?,?,0,0,?)";
		if(sqlite3_prepare_v2(database, ins_calendar_sql, -1, &ins_calendar, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare insert calendar statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	if (ins_recurrence == nil) {//新增規則
		const char *ins_recurrence_sql = "insert into pim_cal_recurrence (calendar_id,Type,Occurrences,Interval,Until,Start,folder_id) values (?,?,?,?,?,?,?)";
		if (sqlite3_prepare_v2(database, ins_recurrence_sql, -1, &ins_recurrence, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare insert recurrence statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	/*
	if (upd_calendar == nil) {//更新重覆事件第一筆的cal_recurrence_id為自己
		const char *upd_calendar_sql = "update pim_calendar set cal_recurrence_id=? where calendar_id=?";
		if(sqlite3_prepare_v2(database, upd_calendar_sql, -1, &upd_calendar, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update calendar statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	*/
	int j=0;
	int i=1;
	BOOL flag=YES;
	NSArray *tmpArray;
	NSString *startTime;
	NSString *endTime;
	NSInteger redoRule;
	NSInteger redoRule1;
	NSString *redoTime;
	NSInteger redoCount;
	NSInteger reminderMins;
	NSString *folderId;
	NSString *keyString;
	NSString *calendarId;
	NSString *eventIcon;
	
	tmpArray=[[[myEvent objectAtIndex:2] objectAtIndex:0] componentsSeparatedByString:@"#"];
	startTime=[tmpArray objectAtIndex:0];
	tmpArray=[[[myEvent objectAtIndex:2] objectAtIndex:1] componentsSeparatedByString:@"#"];
	endTime=[tmpArray objectAtIndex:0];
	
	//DoLog(DEBUG,@"1 %@,%@",startTime,endTime);

	tmpArray=[[[myEvent objectAtIndex:3] objectAtIndex:0] componentsSeparatedByString:@"#"];
	redoRule=[[tmpArray objectAtIndex:0] intValue];
	
	RuleArray *ruleArray=[[RuleArray alloc]init];
	redoRule1=[[[ruleArray redoRule3] objectAtIndex:[ruleArray getRedoRowNo:redoRule]]intValue];
	[ruleArray release];
	
	if([[myEvent objectAtIndex:3] count]==2){
		tmpArray=[[[myEvent objectAtIndex:3] objectAtIndex:1] componentsSeparatedByString:@"#"];
		redoTime=[tmpArray objectAtIndex:0];
	}else
		redoTime=endTime;
	
	//DoLog(DEBUG,@"2 %d,%d,%@",redoRule,redoRule1,redoTime);
	
	tmpArray=[[[myEvent objectAtIndex:4] objectAtIndex:0] componentsSeparatedByString:@"#"];
	reminderMins=[[tmpArray objectAtIndex:0] intValue];
	
	tmpArray=[[[myEvent objectAtIndex:5] objectAtIndex:0] componentsSeparatedByString:@"#"];
	folderId=[tmpArray objectAtIndex:0];
	
	/*
	tmpArray=[[[myEvent objectAtIndex:6] objectAtIndex:0] componentsSeparatedByString:@"#"];
	eventIcon=[tmpArray objectAtIndex:0];
	*/
	eventIcon=[[myEvent objectAtIndex:6] objectAtIndex:0];
	
	//DoLog(DEBUG,@"3 %d,%@",reminderMins,folderId);
	
	if(tflag==NO){
		sqlite3_exec(database, "BEGIN", 0, 0, 0);
		DoLog(INFO,@"BEGIN");
	}
				
	//keyString=[self getMaxSequence:@"pim_calendar" trans:YES];
	//if(keyString!=nil){
	
	/*新增事件次數*/
	if(redoRule!=-1){
		redoCount=([DateTimeUtil getCountFromDate:[DateTimeUtil getDateFromString:startTime] endDate:[DateTimeUtil getDateFromString:redoTime] days:redoRule1 ]+1);
		DoLog(DEBUG,@"redoCount=%d",redoCount);
	}else
		redoCount=0;
	
	NSDate *now=[NSDate date];
	NSDate *date1=[DateTimeUtil getDateFromString:startTime];
	NSDate *date2=[DateTimeUtil getDateFromString:endTime];
	
	
	for(j=0;j<=redoCount;j++){
		//DoLog(DEBUG,@"%@,%@",[date1 description],[date2 description]);

		i=1;
		
		/*
		if(j==0)
			calendarId=keyString;
		else
			calendarId=[self getMaxSequence:@"pim_calendar" trans:YES];
		if(calendarId==nil){
			flag=NO;
			break;
		}
		*/
		
		//sqlite3_bind_int(ins_calendar,i++,[calendarId intValue]);
		//sqlite3_bind_text(ins_calendar,i++,[calendarId UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(ins_calendar,i++,0);
		sqlite3_bind_text(ins_calendar,i++,[[NSString stringWithFormat:@"0"] UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(ins_calendar,i++,[folderId intValue]);
		sqlite3_bind_text(ins_calendar,i++,[folderId UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(ins_calendar,i++,[[DateTimeUtil getTodayString] intValue]);
		sqlite3_bind_text(ins_calendar,i++,[[DateTimeUtil getTodayString] UTF8String],-1,SQLITE_TRANSIENT);
		
		sqlite3_bind_int(ins_calendar, i++, [DateTimeUtil getDiffTimeZoneFromTaipei]);
		
		sqlite3_bind_int(ins_calendar, i++, [DateTimeUtil chkAllDay:[DateTimeUtil getStringFromDate:date1 forKind:0] endDate:[DateTimeUtil getStringFromDate:date2 forKind:0]]);
		
		//sqlite3_bind_int(ins_calendar,i++,[[DateTimeUtil getTodayString] intValue]);
		sqlite3_bind_text(ins_calendar,i++,[[DateTimeUtil getTodayString] UTF8String],-1,SQLITE_TRANSIENT);
		
		//DoLog(DEBUG,@"%@,%@",[DateTimeUtil getStringFromDate:date2 forKind:0],[DateTimeUtil getStringFromDate:date1 forKind:0]);
		//sqlite3_bind_int(ins_calendar,i++,[[DateTimeUtil getStringFromDate:date2 forKind:0] intValue]);
		sqlite3_bind_text(ins_calendar,i++,[[DateTimeUtil getStringFromDate:date2 forKind:0] UTF8String],-1,SQLITE_TRANSIENT);
		
		sqlite3_bind_text(ins_calendar,i++,[[[myEvent objectAtIndex:1] objectAtIndex:0] UTF8String],-1,SQLITE_TRANSIENT);
		
		sqlite3_bind_int(ins_calendar,i++,reminderMins);
		
		sqlite3_bind_text(ins_calendar,i++,[[[myEvent objectAtIndex:0] objectAtIndex:0] UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(ins_calendar,i++,[[DateTimeUtil getStringFromDate:date1 forKind:0] intValue]);
		sqlite3_bind_text(ins_calendar,i++,[[DateTimeUtil getStringFromDate:date1 forKind:0] UTF8String],-1,SQLITE_TRANSIENT);
		
		if(redoRule==-1)/*非重覆事件*/
			sqlite3_bind_int(ins_calendar,i++,0);
		else{
			if(j!=0)/*重覆事件N筆*/
				sqlite3_bind_text(ins_calendar,i++,[keyString UTF8String],-1,SQLITE_TRANSIENT);
			else
				sqlite3_bind_int(ins_calendar,i++,0);
		}
		//memo
		sqlite3_bind_text(ins_calendar,i++,[[[myEvent objectAtIndex:7] objectAtIndex:0] UTF8String],-1,SQLITE_TRANSIENT);
		
		/*起始時間已過不通知*/
		if(j==0 && redoRule!=-1){
			//DoLog(INFO,@"0");
			sqlite3_bind_int(ins_calendar,i++,0);//重覆第一筆
		}else if([now compare:date1]!=NSOrderedAscending){
			//DoLog(INFO,@"1");
			sqlite3_bind_int(ins_calendar,i++,1);
		}else{
			//DoLog(INFO,@"0");
			sqlite3_bind_int(ins_calendar,i++,0);
		}
		
		//sqlite3_bind_int(ins_calendar,i++,[[DateTimeUtil getStringFromDate:[DateTimeUtil getDiffDate:date1 mins:(-1*reminderMins)] forKind:0] intValue]);
		sqlite3_bind_text(ins_calendar,i++,[[DateTimeUtil getStringFromDate:[DateTimeUtil getDiffDate:date1 mins:(-1*reminderMins)] forKind:0] UTF8String],-1,SQLITE_TRANSIENT);
		/*
		if(redoRule==-1)
			sqlite3_bind_int(ins_calendar,i++,0);
		else if(j==0)
			sqlite3_bind_int(ins_calendar,i++,1);
		else
			sqlite3_bind_int(ins_calendar,i++,2);
		*/
		if(redoRule==-1)
			sqlite3_bind_int(ins_calendar,i++,0);
		else if(j==0)
			sqlite3_bind_int(ins_calendar,i++,1);
		else
			sqlite3_bind_int(ins_calendar,i++,0);
		
		sqlite3_bind_text(ins_calendar,i++,[eventIcon UTF8String],-1,SQLITE_TRANSIENT);
		
		
		if(SQLITE_DONE != sqlite3_step(ins_calendar)){
			DoLog(ERROR,@"Error insert calendar data. '%s'", sqlite3_errmsg(database)); 
			flag=NO;
			sqlite3_reset(ins_calendar);
			break;
		}else{
			flag=YES;
			//DoLog(DEBUG,@"insert calendar %d",j);
			calendarId=[NSString stringWithFormat:@"%ld",sqlite3_last_insert_rowid(database)];
			if([calendarId isEqualToString:@"0"]==YES){
				calendarId=[self getMaxSequence:@"pim_calendar" trans:NO];
				DoLog(DEBUG,@"select max value");
			}
			DoLog(DEBUG,@"new calendar_id=%@",calendarId);
			sqlite3_reset(ins_calendar);
		}
		
		if(j!=0){/*重覆事件計算起訖時間*/
			now=[NSDate date];
			date1=[DateTimeUtil getNewDate:date1 days:redoRule1];
			date2=[DateTimeUtil getNewDate:date2 days:redoRule1];
			//DoLog(DEBUG,@"%@,%@",[date1 description],[date2 description]);
		}else{/*第一筆事件*/
			keyString=calendarId;
			
			if(redoRule!=-1){/*重覆事件*/
				//insert
				i=1;
				//sqlite3_bind_int(ins_recurrence,i++,[keyString intValue]);
				sqlite3_bind_text(ins_recurrence,i++,[keyString UTF8String],-1,SQLITE_TRANSIENT);
			
				sqlite3_bind_int(ins_recurrence,i++,redoRule);
			
				sqlite3_bind_int(ins_recurrence,i++,redoCount);
			
				sqlite3_bind_int(ins_recurrence,i++,1);
			
				//sqlite3_bind_int(ins_recurrence,i++,[redoTime intValue]);
				sqlite3_bind_text(ins_recurrence,i++,[redoTime UTF8String],-1,SQLITE_TRANSIENT);
			
				//sqlite3_bind_int(ins_recurrence,i++,[startTime intValue]);
				sqlite3_bind_text(ins_recurrence,i++,[startTime UTF8String],-1,SQLITE_TRANSIENT);
			
				//sqlite3_bind_int(ins_recurrence,i++,[folderId intValue]);
				sqlite3_bind_text(ins_recurrence,i++,[folderId UTF8String],-1,SQLITE_TRANSIENT);
			
				if(SQLITE_DONE != sqlite3_step(ins_recurrence)){
					DoLog(ERROR,@"Error insert recurrence data. '%s'", sqlite3_errmsg(database)); 
					sqlite3_reset(ins_recurrence);
					flag=NO;
					break;
				}else{
					DoLog(DEBUG,@"insert recurrence okay.%@",keyString);
					flag=YES;
					sqlite3_reset(ins_recurrence);
				}
				
				/*
				//update
				i=1;
				//sqlite3_bind_int(upd_calendar,i++,[keyString intValue]);
				sqlite3_bind_text(upd_calendar,i++,[keyString UTF8String],-1,SQLITE_TRANSIENT);
				//sqlite3_bind_int(upd_calendar,i++,[keyString intValue]);
				sqlite3_bind_text(upd_calendar,i++,[keyString UTF8String],-1,SQLITE_TRANSIENT);
				
				if(SQLITE_DONE != sqlite3_step(upd_calendar)){
					DoLog(ERROR,@"Error update calendar data. '%s'", sqlite3_errmsg(database)); 
					sqlite3_reset(upd_calendar);
					flag=NO;
					break;
				}else{
					DoLog(DEBUG,@"update calendar okay.%@",keyString);
					flag=YES;
					sqlite3_reset(upd_calendar);
				}				
				*/
			}
		}
		
	}
	
	if(flag==YES){
		if(tflag==NO){
			sqlite3_exec(database, "COMMIT", 0, 0, 0);
			DoLog(INFO,@"COMMIT");
		}
		result=YES;
	}else{
		if(tflag==NO){
			sqlite3_exec(database, "ROLLBACK", 0, 0, 0);
			DoLog(INFO,@"ROLLBACK");
		}
		result=NO;
	}
	//}else
	//	result=NO;
	return result;
}


//get event by range
- (NSArray *) getListTodoEventFrom:(NSString *) from to:(NSString *) to{
	NSMutableArray *result=[[NSMutableArray alloc]init];
	
	ListTodoEvent *listTodoEvent;
	
	static sqlite3_stmt *init_statement = nil;
	
	if(init_statement == nil){
		const char *sql = 
		"SELECT "\
		"c.calendar_id, "\
		"c.user_id, "\
		"c.folder_id, "\
		"c.is_synced, "\
		"c.status, "\
		"c.AllDayEvent, "\
		"c.DtStamp, "\
		"c.EndTime, "\
		"c.Location, "\
		"c.Reminder, "\
		"c.Subject, "\
		"c.event_desc, "\
		"c.starttime, "\
		"c.UID, "\
		"c.cal_recurrence_id, "\
		"c.IsException, "\
		"c.Deleted, "\
		"c.memo, "\
		"c.server_id, "\
		"c.event_icon, "\
		"f.folder_name, "\
		"f.color_rgb, "\
		"f.display_flag "\
		"FROM pim_calendar c, pim_cal_folder f "\
		"where c.folder_id = f.folder_id "\
		"and c.StartTime >=? "\
		"and c.StartTime <=? "\
		"and c.status != 3 "\
		"and c.cal_type !=1 "\
		"and f.display_flag =1 "\
		"order by c.starttime";
		
		if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	int i=1;
	
	
	sqlite3_bind_text(init_statement,1,[from UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(init_statement,2,[to UTF8String],-1,SQLITE_TRANSIENT);
	//DoLog(DEBUG,@"fromto:%@,%@,%d,%d,%d",from,to,sqlite3_step(init_statement),a,b);
	
	NSMutableString *tmpString;
	while(sqlite3_step(init_statement) == SQLITE_ROW) {
		
		//DoLog(DEBUG,@"count");
		listTodoEvent = [[ListTodoEvent alloc]init];
		
		i=0;//0
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setCalendarId:tmpString];
		}
		i++;//1
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setUserId:tmpString];
		}
		i++;//2
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setFolderId:tmpString];
		}
		i++;//3
		[listTodoEvent setIsSynced:sqlite3_column_int(init_statement,i)];
		i++;//4
		[listTodoEvent setStatus:sqlite3_column_int(init_statement,i)];
		i++;//5
		[listTodoEvent setAllDayEvent:sqlite3_column_int(init_statement,i)];
		i++;//6
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setDtStamp:tmpString];
		}
		i++;//7
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setEndTime:tmpString];
		}
		i++;//8
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setLocation:tmpString];
		}
		i++;//9
		[listTodoEvent setReminder:sqlite3_column_int(init_statement,i)];
		i++;//10
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setSubject:tmpString];
		}
		i++;//11
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setEventDesc:tmpString];
		}
		i++;//12
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setStartTime:tmpString];
		}
		i++;//13
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setUid:tmpString];
		}
		i++;//14
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setCalRecurrenceId:tmpString];
		}
		i++;//15
		[listTodoEvent setIsException:sqlite3_column_int(init_statement,i)];
		i++;//16
		[listTodoEvent setDeleted:sqlite3_column_int(init_statement,i)];
		i++;//17
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setMemo:tmpString];
		}
		i++;//18
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setServerId:tmpString];
		}
		i++;//19
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setEventIcon:tmpString];
		}
		i++;//20
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setFolderName:tmpString];
		}
		i++;//21
		[listTodoEvent setColorRgb:sqlite3_column_int(init_statement,i)];
		i++;//22
		[listTodoEvent setDisplayFlag:sqlite3_column_int(init_statement,i)];
		
		/*if((char *)sqlite3_column_text(init_statement,0)!=NULL){
		 tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,0)];
		 todoCategory = [[TodoCategory alloc]initWithCategoryId:tmpString database:database ];	 
		 [result addObject:todoCategory];
		 [todoCategory release];
		 }*/
		[result addObject:listTodoEvent];
		[listTodoEvent release];
		
	} 
	sqlite3_reset(init_statement);
	//DoLog(DEBUG,@"sqlite ok");
	return result;
}

//get TodoEventStartTime by range
- (NSArray *) getTodoEventStartTimeFrom:(NSString *) from to:(NSString *) to{
	NSMutableArray *result=[[NSMutableArray alloc]init];
	
	//ListTodoEvent *listTodoEvent;
	
	static sqlite3_stmt *init_statement = nil;
	
	if(init_statement == nil){
		const char *sql = 
		"SELECT "\
		"c.starttime "\
		"FROM pim_calendar c, pim_cal_folder f "\
		"where c.folder_id = f.folder_id "\
		"and c.StartTime >=? "\
		"and c.StartTime <=? "\
		"and c.status != 3 "\
		"and c.cal_type !=1 "\
		"and f.display_flag =1 "\
		"order by starttime";
		
		if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	int i=1;
	
	
	sqlite3_bind_text(init_statement,1,[from UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(init_statement,2,[to UTF8String],-1,SQLITE_TRANSIENT);
	//DoLog(DEBUG,@"fromto:%@,%@,%d,%d,%d",from,to,sqlite3_step(init_statement),a,b);
	
	//NSMutableString *tmpString;
	while(sqlite3_step(init_statement) == SQLITE_ROW) {
		
		//DoLog(DEBUG,@"count");
		NSMutableString *tmpString;
		i=0;//0
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
		}
		[result addObject:tmpString];
		
	} 
	sqlite3_reset(init_statement);
	//DoLog(DEBUG,@"sqlite ok");
	return result;
}
// #add 0413
//update pim_calendar set sync_status = ? where server_id =?;
- (BOOL) updatePimCalendarSetSyncStatus:(NSInteger)syncStatus WhereServerId:(NSString *)serverId{
	BOOL result;
	
	static sqlite3_stmt *update_statement = nil;
	
	if (update_statement == nil) {
		const char *update_sql = "update pim_calendar set sync_status = ? where server_id = ?";
		if (sqlite3_prepare_v2(database, update_sql, -1, &update_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	int i=1;
	sqlite3_bind_int(update_statement,i++,syncStatus);
	sqlite3_bind_text(update_statement,i++,[serverId UTF8String],-1,SQLITE_TRANSIENT);
	if(SQLITE_DONE != sqlite3_step(update_statement)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		flag=NO;
	}else
		flag=YES;
	
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(update_statement);
	
	return result;
}


// #add 0413
//update pim_calendar set sync_status = ? where calendar_id =?;
- (BOOL) updatePimCalendarSetSyncStatus:(NSInteger)syncStatus WhereCalendarId:(NSString *)calendarId{
	BOOL result;
	
	static sqlite3_stmt *update_statement = nil;
	
	if (update_statement == nil) {
		const char *update_sql = "update pim_calendar set sync_status = ? where calendar_id = ?";
		if (sqlite3_prepare_v2(database, update_sql, -1, &update_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	int i=1;
	sqlite3_bind_int(update_statement,i++,syncStatus);
	sqlite3_bind_text(update_statement,i++,[calendarId UTF8String],-1,SQLITE_TRANSIENT);
	if(SQLITE_DONE != sqlite3_step(update_statement)){
		DoLog(DEBUG,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		flag=NO;
	}else
		flag=YES;
	
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(update_statement);
	
	return result;
}

// #add 0413
//update pim_calendar set sync_status = ? where sync_status =?;
- (BOOL) updatePimCalendarSetSyncStatus:(NSInteger)syncStatus WhereSyncStatus:(NSInteger)syncStatus2{
	BOOL result;
	
	static sqlite3_stmt *update_statement = nil;
	
	if (update_statement == nil) {
		const char *update_sql = "update pim_calendar set sync_status = ? where sync_status = ?";
		if (sqlite3_prepare_v2(database, update_sql, -1, &update_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	int i=1;
	sqlite3_bind_int(update_statement,i++,syncStatus);
	sqlite3_bind_int(update_statement,i++,syncStatus2);
	if(SQLITE_DONE != sqlite3_step(update_statement)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		flag=NO;
	}else
		flag=YES;
	
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(update_statement);
	
	return result;
}



// delete pim_calendar pim_cal_folder pim_cal_recurrence   

- (BOOL) deletePimCalendarFolderRecurrence{
	BOOL result;
	
	static sqlite3_stmt *delete_statement1 = nil;
	static sqlite3_stmt *delete_statement2 = nil;
	static sqlite3_stmt *delete_statement3 = nil;
	static sqlite3_stmt *delete_statement4 = nil;
	
	if (delete_statement1 == nil) {
		const char *update_sql = "delete from pim_cal_recurrence ";
		if (sqlite3_prepare_v2(database, update_sql, -1, &delete_statement1, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	if (delete_statement2 == nil) {
		const char *update_sql = "delete from pim_calendar ";
		if (sqlite3_prepare_v2(database, update_sql, -1, &delete_statement2, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	if (delete_statement3 == nil) {
		const char *update_sql = "delete from pim_cal_folder ";
		if (sqlite3_prepare_v2(database, update_sql, -1, &delete_statement3, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	if (delete_statement4 == nil) {
		const char *update_sql = "delete from restore_log where restore_result = 1 ";
		if (sqlite3_prepare_v2(database, update_sql, -1, &delete_statement4, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	
	if(SQLITE_DONE != sqlite3_step(delete_statement1)){
		DoLog(ERROR,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
		flag=NO;
	}else{
		if(SQLITE_DONE != sqlite3_step(delete_statement2)){
			DoLog(ERROR,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
			flag=NO;
		}else{
			if(SQLITE_DONE != sqlite3_step(delete_statement3)){
				DoLog(ERROR,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
				flag=NO;
			}else{
				if(SQLITE_DONE != sqlite3_step(delete_statement4)){
					DoLog(DEBUG,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
					flag=NO;
				}else{
					flag=YES;
				}
			}
		}
	}
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(delete_statement1);
	sqlite3_reset(delete_statement2);
	sqlite3_reset(delete_statement3);
	sqlite3_reset(delete_statement4);
	
	return result;
}


// check exist of server_id   
- (BOOL) checkExistOfServerId:(NSString *) serverId{
	BOOL result = NO;
	NSInteger count = 0;
	
	//ListTodoEvent *listTodoEvent;
	
	static sqlite3_stmt *count_statement = nil;
	
	if(count_statement == nil){
		const char *sql = "SELECT count(*) FROM pim_calendar WHERE server_id = ? ";
		
		if (sqlite3_prepare_v2(database, sql, -1, &count_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	sqlite3_bind_text(count_statement,1,[serverId UTF8String],-1,SQLITE_TRANSIENT);
	

	if(sqlite3_step(count_statement) == SQLITE_ROW) {
		count = sqlite3_column_int(count_statement,0);
	}else{
		count = 0;
	}
	sqlite3_reset(count_statement);
	if(count == 0){
		result = NO;
	}else{
		result = YES;
	}
	return result;
}


// content sync and resurrence sync
- (BOOL) updatePimCalendarSetSyncFlag:(NSInteger)syncFlag SyncId:(NSString*) syncId WhereCalRecurrenceId:(NSString *)calendarId{
	BOOL result;
	
	static sqlite3_stmt *update_statement = nil;
	
	if (update_statement == nil) {
		const char *update_sql = "update pim_calendar set is_synced = ?, sync_id = ? where cal_recurrence_id = ?";
		if (sqlite3_prepare_v2(database, update_sql, -1, &update_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	int i=1;
	sqlite3_bind_int(update_statement,i++,syncFlag);
	sqlite3_bind_text(update_statement,i++,[syncId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement,i++,[calendarId UTF8String],-1,SQLITE_TRANSIENT);
	if(SQLITE_DONE != sqlite3_step(update_statement)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		flag=NO;
	}else
		flag=YES;
	
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(update_statement);
	
	return result;
}
// #modify 0413
- (BOOL) insToEvent:(TodoEvent *)todoEvent EventRecurrence:(EventRecurrence *)eventRecurrence Database:(sqlite3 *)db{
	BOOL result = NO;
	
	static sqlite3_stmt *ins_statement1 = nil;
	static sqlite3_stmt *ins_statement2 = nil;
	static sqlite3_stmt *sel_statement = nil;
	
	if (ins_statement1 == nil) {
		const char *sql = 
		"INSERT INTO pim_calendar ("\
		"user_id, "\
		"folder_id, "\
		"last_write, "\
		"is_synced, "\
		"status, "\
		"need_sync, "\
		"TimeZone, "\
		"AllDayEvent, "\
		"BusyStatus, "\
		"OrganizerName, "\
		"OrganizerEmail, "\
		"DtStamp, "\
		"EndTime, "\
		"Location, "\
		"Reminder, "\
		"Sensitivity, "\
		"Subject, "\
		"event_desc, "\
		"StartTime, "\
		"UID, "\
		"MeetingStatus, "\
		"DisallowNewTimeProposal, "\
		"ResponseRequested, "\
		"AppointmentReplyTime, "\
		"ResponseType, "\
		"cal_recurrence_id, "\
		"IsException, "\
		"Deleted, "\
		"PicturePath, "\
		"VoicePath, "\
		"NoteId, "\
		"memo, "\
		"reminder_dismiss, "\
		"reminder_start_time, "\
		"server_id, "\
		"cal_type,"\
		"sync_id, "\
		"sync_status "\
		") values ("\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"? "\
		")";
		if (sqlite3_prepare_v2(db, sql, -1, &ins_statement1, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(db));
		}
	}
	
	if(sel_statement == nil){
		char *sql = "SELECT "\
		"calendar_id "\
		"FROM pim_calendar "\
		"where server_id = ? ";
		
		//DoLog(DEBUG,@"sql:%s",sql);
		if (sqlite3_prepare_v2(database, sql, -1, &sel_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	if (ins_statement2 == nil) {
		const char *sql = 
		"INSERT INTO pim_cal_recurrence ("\
		"calendar_id, "\
		"Type, "\
		"Occurrences, "\
		"Interval, "\
		"WeekOfMonth, "\
		"DayOfWeek, "\
		"MonthOfYear, "\
		"Until, "\
		"DayOfMonth, "\
		"Start, "\
		"folder_id "\
		") values ("\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"?, "\
		"? "\
		")";
		if (sqlite3_prepare_v2(db, sql, -1, &ins_statement2, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(db));
		}
	}
	
	
	int i=1;
	//sqlite3_bind_text(ins_statement1,i++,[todoEvent.calendarId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.userId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.folderId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.lastWrite UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.isSynced);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.status);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.needSync);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.timeZone);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.allDayEvent);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.busyStatus);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.organizerName UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.organizerEmail UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.dtStamp UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.endTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.location UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.reminder);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.sensitivity);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.subject UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.eventDesc UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.startTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.uid UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.meetingStatus);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.disallowNewTimeProposal);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.responseRequested);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.appointmentReplyTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.responseType);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.calRecurrenceId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.isException);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.deleted);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.picturePath UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.voicePath UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.noteId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.memo UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.reminderDismiss);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.reminderStartTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.serverId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.calType);
	sqlite3_bind_text(ins_statement1,i++,[todoEvent.syncId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement1,i++,todoEvent.syncStatus);
	
	i=1;
	sqlite3_bind_text(sel_statement,i++,[todoEvent.serverId UTF8String],-1,SQLITE_TRANSIENT);
	
	i=2;//skip calendarId add it when get calendarId
	//sqlite3_bind_text(ins_statement2,i++,[eventRecurrence.calendarId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement2,i++,eventRecurrence.type);
	sqlite3_bind_int(ins_statement2,i++,eventRecurrence.occurrences);
	sqlite3_bind_int(ins_statement2,i++,eventRecurrence.interval);
	sqlite3_bind_int(ins_statement2,i++,eventRecurrence.weekOfMonth);
	sqlite3_bind_int(ins_statement2,i++,eventRecurrence.dayOfWeek);
	sqlite3_bind_int(ins_statement2,i++,eventRecurrence.monthOfYear);
	sqlite3_bind_text(ins_statement2,i++,[eventRecurrence.until UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement2,i++,eventRecurrence.dayOfMonth);
	sqlite3_bind_text(ins_statement2,i++,[eventRecurrence.start UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement2,i++,[eventRecurrence.folderId UTF8String],-1,SQLITE_TRANSIENT);
	
	
	BOOL flag;
	sqlite3_exec(db, "BEGIN", 0, 0, 0);
	
	if(SQLITE_DONE != sqlite3_step(ins_statement1)){
		DoLog(ERROR,@"Error insert data. '%s'", sqlite3_errmsg(db)); 
		flag=NO;
	}else{
		if(sqlite3_step(sel_statement) == SQLITE_ROW)
		{
			if((char*)sqlite3_column_text(sel_statement,0)!=NULL)
			{
				NSMutableString *cId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(sel_statement,0)];
				sqlite3_bind_text(ins_statement2,1,[cId UTF8String],-1,SQLITE_TRANSIENT);
				//DoLog(DEBUG,@"cId%@",cId);
				if(SQLITE_DONE != sqlite3_step(ins_statement2))
				{
					DoLog(ERROR,@"Error insert data. '%s'", sqlite3_errmsg(db)); 
					flag=NO;
				}
				else
				{
					flag=YES;
				}
			}
			else
			{
				flag=NO;
			}
		}
		else
		{
			flag=NO;
		}
		
	}
	
	if(flag==YES){
		sqlite3_exec(db, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(db, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(ins_statement1);
	sqlite3_reset(ins_statement2);
	sqlite3_reset(sel_statement);
	
	return result;
}




//delete from pim_calendar where cal_recurrence_id = pim_calendar.calendar_id(get by serverId);
//delete from pim_cal_recurrence where calendar_id = pim_calendar.calendar_id(get by serverId);
//delete from pim_calendar where calendar_id = ?;

- (BOOL) deleteRecurrenceEventByCalendarId:(NSString *)calendarId{
	BOOL result;
	
	static sqlite3_stmt *delete_statement1 = nil;
	static sqlite3_stmt *delete_statement2 = nil;
	
	if (delete_statement1 == nil) {
		const char *update_sql = "delete from pim_cal_recurrence where calendar_id = ?";
		if (sqlite3_prepare_v2(database, update_sql, -1, &delete_statement1, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	if (delete_statement2 == nil) {
		const char *update_sql = "delete from pim_calendar where cal_recurrence_id = ? or calendar_id = ?";
		if (sqlite3_prepare_v2(database, update_sql, -1, &delete_statement2, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	int i=1;
	sqlite3_bind_text(delete_statement1,i++,[calendarId UTF8String],-1,SQLITE_TRANSIENT);
	i=1;
	sqlite3_bind_text(delete_statement2,i++,[calendarId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(delete_statement2,i++,[calendarId UTF8String],-1,SQLITE_TRANSIENT);
	
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	
	if(SQLITE_DONE != sqlite3_step(delete_statement1)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		flag=NO;
	}else{
		if(SQLITE_DONE != sqlite3_step(delete_statement2)){
			DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
			flag=NO;
		}else{
			flag=YES;
		}
	}
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(delete_statement1);
	sqlite3_reset(delete_statement2);
	
	return result;
}

- (NSArray *) getRecurrenceSyncServerId{
    NSMutableArray *result=[[NSMutableArray alloc]init];
	
	static sqlite3_stmt *init_statement = nil;
	
	if(init_statement == nil){
		char *sql = "SELECT "\
		"server_id "\
		"FROM pim_calendar "\
		"where is_synced != 2 and cal_type = 1 "\
		"ORDER BY last_write ";
		
		//DoLog(DEBUG,@"sql:%s",sql);
		if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	/*
	 int i=1;
	 
	 sqlite3_bind_int(init_statement,i++,limit);
	 sqlite3_bind_int(init_statement,i++,offset);*/
	
	while(sqlite3_step(init_statement) == SQLITE_ROW) {
		NSMutableString *tmpString;
		int i=0;
		if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
		else
			tmpString=[[NSMutableString alloc] initWithString:@""];
		[result addObject:tmpString];
		//DoLog(DEBUG,@"tmpString: %@",tmpString);
		[tmpString release];
		
	} 
	sqlite3_reset(init_statement);
	
	return result;
}
- (NSArray *) getRecurrenceSyncCalendarIdByStartTime:(NSString *)startTime LastWrite:(NSString *)lastWrite Limit:(NSInteger) limit offset:(NSInteger) offset{
    NSMutableArray *result=[[NSMutableArray alloc]init];
	
	static sqlite3_stmt *init_statement = nil;
	
	if(init_statement == nil){
		char *sql = "SELECT "\
		"calendar_id "\
		"FROM pim_calendar "\
		"where is_synced != 2 and cal_type = 1 "\
		"and StartTime >= ? "\
		"and last_write <= ? "\
		"ORDER BY last_write "\
		"LIMIT ? "\
		"OFFSET ? ";
		
		//DoLog(DEBUG,@"sql:%s",sql);
		if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	int i=1;
	sqlite3_bind_text(init_statement,i++,[startTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(init_statement,i++,[lastWrite UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(init_statement,i++,limit);
	sqlite3_bind_int(init_statement,i++,offset);
	
	while(sqlite3_step(init_statement) == SQLITE_ROW) {
		NSMutableString *tmpString;
		int i=0;
		if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
		else
			tmpString=[[NSMutableString alloc]initWithString:@""];
		[result addObject:tmpString];
		//DoLog(DEBUG,@"tmpString: %@",tmpString);
		[tmpString release];
		
	} 
	sqlite3_reset(init_statement);
	
	return result;
}


//getTodoEventSyncServerId
- (NSArray *) getTodoEventSyncServerId{
    NSMutableArray *result=[[NSMutableArray alloc]init];
	
	static sqlite3_stmt *init_statement = nil;
	
	if(init_statement == nil){
		char *sql = "SELECT "\
		"server_id "\
		"FROM pim_calendar "\
		"where is_synced != 2 and cal_type != 1 "\
		"ORDER BY last_write ";
		
		//DoLog(DEBUG,@"sql:%s",sql);
		if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	/*
	 int i=1;
	 
	 sqlite3_bind_int(init_statement,i++,limit);
	 sqlite3_bind_int(init_statement,i++,offset);*/
	
	while(sqlite3_step(init_statement) == SQLITE_ROW) {
		NSMutableString *tmpString;
		int i=0;
		if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
		else
			tmpString=[[NSMutableString alloc]initWithString:@""];
		[result addObject:tmpString];
		//DoLog(DEBUG,@"tmpString: %@",tmpString);
		[tmpString release];
		
	} 
	sqlite3_reset(init_statement);
	
	return result;
}

- (NSArray *) getTodoEventSyncCalendarIdByStartTime:(NSString *)startTime LastWrite:(NSString *)lastWrite Limit:(NSInteger) limit offset:(NSInteger) offset{
    NSMutableArray *result=[[NSMutableArray alloc]init];
	
	static sqlite3_stmt *init_statement = nil;
	
	if(init_statement == nil){
		char *sql = "SELECT "\
		"calendar_id "\
		"FROM pim_calendar "\
		"where is_synced != 2 and cal_type != 1 "\
		"and StartTime >= ? "\
		"and last_write <= ? "\
		"ORDER BY last_write "\
		"LIMIT ? "\
		"OFFSET ? ";
		
		//DoLog(DEBUG,@"sql:%s",sql);
		if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	int i=1;
	sqlite3_bind_text(init_statement,i++,[startTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(init_statement,i++,[lastWrite UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(init_statement,i++,limit);
	sqlite3_bind_int(init_statement,i++,offset);
	
	while(sqlite3_step(init_statement) == SQLITE_ROW) {
		NSMutableString *tmpString;
		int i=0;
		if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
		else
			tmpString=[[NSMutableString alloc] initWithString:@""];
		[result addObject:tmpString];
		//DoLog(DEBUG,@"tmpString: %@",tmpString);
		[tmpString release];
		
	} 
	sqlite3_reset(init_statement);
	
	return result;
}

//update pim_calendar set sync_flag = ?, server_id = server_id,  sync_id = sync_seq where calendar_id = client_id;
- (BOOL) updatePimCalendarSetSyncFlag:(NSInteger)syncFlag ServerId:(NSString *)ServerId SyncId:(NSString*) syncId WhereCalendarId:(NSString *)clientId{
	BOOL result; 
	
	static sqlite3_stmt *update_statement = nil;
	
	if (update_statement == nil) {
		const char *update_sql = "update pim_calendar set is_synced = ?, server_id = ?,  sync_id = ? where calendar_id = ?";
		if (sqlite3_prepare_v2(database, update_sql, -1, &update_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	int i=1;
	sqlite3_bind_int(update_statement,i++,syncFlag);
	sqlite3_bind_text(update_statement,i++,[ServerId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement,i++,[syncId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement,i++,[clientId UTF8String],-1,SQLITE_TRANSIENT);
	if(SQLITE_DONE != sqlite3_step(update_statement)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		flag=NO;
	}else
		flag=YES;
	
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(update_statement);
	
	return result;
}

//update pim_calendar set cal_recurrence_id = server_id where cal_recurrence_id = client_id;

- (BOOL) updatePimCalendarSetCalRecurrenceId:(NSString *)ServerId WhereCalRecurrenceId:(NSString *) clientId{
	BOOL result;
	
	static sqlite3_stmt *update_statement = nil;
	
	if (update_statement == nil) {
		const char *update_sql = "update pim_calendar set cal_recurrence_id = ? where cal_recurrence_id = ?";
		if (sqlite3_prepare_v2(database, update_sql, -1, &update_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	int i=1;
	sqlite3_bind_text(update_statement,i++,[ServerId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement,i++,[clientId UTF8String],-1,SQLITE_TRANSIENT);
	if(SQLITE_DONE != sqlite3_step(update_statement)){
		DoLog(DEBUG,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		flag=NO;
	}else
		flag=YES;
	
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(update_statement);
	
	return result;
}


//update pim_cal_recurrence set calendar_id = server_id where calendar_id = client_id;
- (BOOL) updatePimCalRecurrenceSetCalendarId:(NSString *)ServerId WhereCalendarId: (NSString *) clientId{
	BOOL result;
	
	static sqlite3_stmt *update_statement = nil;
	
	if (update_statement == nil) {
		const char *update_sql = "update pim_cal_recurrence set calendar_id = ? where calendar_id = ?";
		if (sqlite3_prepare_v2(database, update_sql, -1, &update_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	int i=1;
	sqlite3_bind_text(update_statement,i++,[ServerId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement,i++,[clientId UTF8String],-1,SQLITE_TRANSIENT);
	if(SQLITE_DONE != sqlite3_step(update_statement)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		flag=NO;
	}else
		flag=YES;
	
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(update_statement);
	
	return result;
}

//update pim_calendar set sync_flag = ? and sync_id=? where server_id = server_id;
- (BOOL) updatePimCalendarSetSyncFlag:(NSInteger)syncFlag SyncId:(NSString*) syncId WhereServerId:(NSString *)serverId{
	BOOL result;
	
	static sqlite3_stmt *update_statement = nil;
	
	if (update_statement == nil) {
		const char *update_sql = "update pim_calendar set is_synced = ?, sync_id = ? where server_id = ?";
		if (sqlite3_prepare_v2(database, update_sql, -1, &update_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	int i=1;
	sqlite3_bind_int(update_statement,i++,syncFlag);
	sqlite3_bind_text(update_statement,i++,[syncId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(update_statement,i++,[serverId UTF8String],-1,SQLITE_TRANSIENT);
	if(SQLITE_DONE != sqlite3_step(update_statement)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		flag=NO;
	}else
		flag=YES;
	
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(update_statement);
	
	return result;
}

//delete from pim_calendar where server_id = server_id;
- (BOOL) deleteFromPimCalendarWhereServerId:(NSString *)serverId{
	BOOL result;
	
	static sqlite3_stmt *delete_statement = nil;
	
	if (delete_statement == nil) {
		const char *update_sql = "delete from pim_calendar where server_id = ?";
		if (sqlite3_prepare_v2(database, update_sql, -1, &delete_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	BOOL flag;
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	int i=1;
	sqlite3_bind_text(delete_statement,i++,[serverId UTF8String],-1,SQLITE_TRANSIENT);
	if(SQLITE_DONE != sqlite3_step(delete_statement)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		flag=NO;
	}else
		flag=YES;
	
	
	if(flag==YES){
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(database, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(delete_statement);
	
	return result;
}



//backup and restore



-(NSMutableDictionary *) getLastBackupLog:(NSInteger) state{
	NSMutableDictionary *result=nil;
	static sqlite3_stmt *backup_log = nil;
	
	if(backup_log == nil){
		const char *backup_log_sql = "SELECT log_id,backup_id,backup_bgn_time,backup_end_time,backup_result FROM backup_log WHERE backup_result=? order by backup_bgn_time desc limit 1";
		
		if (sqlite3_prepare_v2(database, backup_log_sql, -1, &backup_log, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare statement error='%s'.", sqlite3_errmsg(database));
			return nil;
		}
	}
	
	result=[[NSMutableDictionary alloc]init];
	sqlite3_bind_int(backup_log,1,state);
	
	if(sqlite3_step(backup_log) == SQLITE_ROW) {
		if((char *)sqlite3_column_text(backup_log,0)!=NULL)
			[result setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(backup_log,0)] forKey:@"logId"];
		if((char *)sqlite3_column_text(backup_log,1)!=NULL)
			[result setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(backup_log,1)] forKey:@"backupId"];
		if((char *)sqlite3_column_text(backup_log,2)!=NULL)
			[result setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(backup_log,2)] forKey:@"backupBgnTime"];
		if((char *)sqlite3_column_text(backup_log,3)!=NULL)
			[result setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(backup_log,3)] forKey:@"backupEndTime"];
		if((char *)sqlite3_column_text(backup_log,4)!=NULL)
			[result setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(backup_log,4)] forKey:@"backupResult"];
	} 
	sqlite3_reset(backup_log);
	return result;
}
-(NSMutableDictionary *) getLastRestoreLog:(NSInteger)state{
	NSMutableDictionary *result=nil;
	static sqlite3_stmt *restore_log = nil;
	
	if(restore_log == nil){
		const char *restore_log_sql = "SELECT log_id,restore_id,restore_bgn_time,restore_end_time,restore_result FROM restore_log WHERE restore_result=? order by restore_bgn_time desc limit 1";
		
		if (sqlite3_prepare_v2(database, restore_log_sql, -1, &restore_log, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare statement error='%s'.", sqlite3_errmsg(database));
			return nil;
		}
	}
	
	result=[[NSMutableDictionary alloc]init];
	sqlite3_bind_int(restore_log,1,state);
	
	if(sqlite3_step(restore_log) == SQLITE_ROW) {
		if((char *)sqlite3_column_text(restore_log,0)!=NULL)
			[result setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(restore_log,0)] forKey:@"logId"];
		if((char *)sqlite3_column_text(restore_log,1)!=NULL)
			[result setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(restore_log,1)] forKey:@"restoreId"];
		if((char *)sqlite3_column_text(restore_log,2)!=NULL)
			[result setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(restore_log,2)] forKey:@"restoreBgnTime"];
		if((char *)sqlite3_column_text(restore_log,3)!=NULL)
			[result setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(restore_log,3)] forKey:@"restoreEndTime"];
		if((char *)sqlite3_column_text(restore_log,4)!=NULL)
			[result setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(restore_log,4)] forKey:@"restoreResult"];
	} 
	sqlite3_reset(restore_log);
	return result;	
}
-(BOOL) updBackupLog:(NSMutableDictionary *)bLog{
	BOOL result;
	
	static sqlite3_stmt *update_backup = nil;
	
	if (update_backup == nil) {
		const char *update_backup_sql = "update backup_log set backup_bgn_time=?,backup_end_time=?,backup_result=? where backup_id=?";
		if (sqlite3_prepare_v2(database, update_backup_sql, -1, &update_backup, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	int i=1;
	sqlite3_bind_text(update_backup,i++,[[bLog objectForKey:@"backupBgnTime"] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(update_backup,i++,[[bLog objectForKey:@"backupEndTime"] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(update_backup,i++,[[bLog objectForKey:@"backupResult"]intValue]);
	sqlite3_bind_text(update_backup,i++,[[bLog objectForKey:@"backupId"] UTF8String],-1,SQLITE_TRANSIENT);
	
	if(SQLITE_DONE != sqlite3_step(update_backup)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		result=NO;
	}else
		result=YES;
	sqlite3_reset(update_backup);
	
	return result;
}
-(BOOL) updRestoreLog:(NSMutableDictionary *)rLog{
	BOOL result;
	
	static sqlite3_stmt *update_restore = nil;
	
	if (update_restore == nil) {
		const char *update_restore_sql = "update restore_log set restore_bgn_time=?,restore_end_time=?,restore_result=? where restore_id=?";
		if (sqlite3_prepare_v2(database, update_restore_sql, -1, &update_restore, NULL) != SQLITE_OK) {
			DoLog(DEBUG,@"prepare update statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	int i=1;
	sqlite3_bind_text(update_restore,i++,[[rLog objectForKey:@"restoreBgnTime"] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(update_restore,i++,[[rLog objectForKey:@"restoreEndTime"] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(update_restore,i++,[[rLog objectForKey:@"restoreResult"]intValue]);
	sqlite3_bind_text(update_restore,i++,[[rLog objectForKey:@"restoreId"] UTF8String],-1,SQLITE_TRANSIENT);
	
	if(SQLITE_DONE != sqlite3_step(update_restore)){
		DoLog(ERROR,@"Error update data. '%s'", sqlite3_errmsg(database)); 
		result=NO;
	}else
		result=YES;
	sqlite3_reset(update_restore);
	
	return result;
}

-(BOOL) insBackupLog:(NSMutableDictionary *) bLog{
	BOOL result;
	
	static sqlite3_stmt *insert_backup = nil;
	
	if (insert_backup == nil) {
		const char *insert_backup_sql = "insert into backup_log (backup_id,backup_bgn_time,backup_end_time,backup_result) values(?,?,?,?) ";
		if (sqlite3_prepare_v2(database, insert_backup_sql, -1, &insert_backup, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare insert statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	int i=1;
	sqlite3_bind_text(insert_backup,i++,[[bLog objectForKey:@"backupId"] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_backup,i++,[[bLog objectForKey:@"backupBgnTime"] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_backup,i++,[[bLog objectForKey:@"backupEndTime"] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(insert_backup,i++,0);
	
	
	if(SQLITE_DONE != sqlite3_step(insert_backup)){
		DoLog(ERROR,@"Error insert data. '%s'", sqlite3_errmsg(database)); 
		result=NO;
	}else
		result=YES;
	sqlite3_reset(insert_backup);
	
	return result;
}
-(BOOL) insRestoreLog:(NSMutableDictionary *) rLog{
	BOOL result;
	
	static sqlite3_stmt *insert_restore = nil;
	
	if (insert_restore == nil) {
		const char *insert_restore_sql = "insert into restore_log (restore_id,restore_bgn_time,restore_end_time,restore_result) values(?,?,?,?) ";
		if (sqlite3_prepare_v2(database, insert_restore_sql, -1, &insert_restore, NULL) != SQLITE_OK) {
			DoLog(DEBUG,@"prepare insert statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	int i=1;
	sqlite3_bind_text(insert_restore,i++,[[rLog objectForKey:@"restoreId"] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_restore,i++,[[rLog objectForKey:@"restoreBgnTime"] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_restore,i++,[[rLog objectForKey:@"restoreEndTime"] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(insert_restore,i++,0);
	
	
	if(SQLITE_DONE != sqlite3_step(insert_restore)){
		DoLog(ERROR,@"Error insert data. '%s'", sqlite3_errmsg(database)); 
		result=NO;
	}else
		result=YES;
	sqlite3_reset(insert_restore);
	
	return result;
}

-(BOOL) delBackupLog:(NSString *)bId{
	BOOL result;
	
	static sqlite3_stmt *delete_backup = nil;
	
	if (delete_backup == nil) {
		const char *delete_backup_sql = "delete from backup_log where backup_id=?";
		if (sqlite3_prepare_v2(database, delete_backup_sql, -1, &delete_backup, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	
	sqlite3_bind_text(delete_backup,1,[bId UTF8String],-1,SQLITE_TRANSIENT);
	if(SQLITE_DONE != sqlite3_step(delete_backup)){
			DoLog(ERROR,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
			result=NO;
	}else
		result=YES;
	
	sqlite3_reset(delete_backup);
	
	return result;
}

-(BOOL) delRestoreLog:(NSString *)rId{
	BOOL result;
	
	static sqlite3_stmt *delete_restore = nil;
	
	if (delete_restore == nil) {
		const char *delete_restore_sql = "delete from restore_log where restore_id=?";
		if (sqlite3_prepare_v2(database, delete_restore_sql, -1, &delete_restore, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare delete statement error='%s'.", sqlite3_errmsg(database));
			result=NO;
		}
	}
	
	
	sqlite3_bind_text(delete_restore,1,[rId UTF8String],-1,SQLITE_TRANSIENT);
	if(SQLITE_DONE != sqlite3_step(delete_restore)){
		DoLog(DEBUG,@"Error delete data. '%s'", sqlite3_errmsg(database)); 
		result=NO;
	}else
		result=YES;
	
	sqlite3_reset(delete_restore);
	
	return result;
}


-(BOOL)releaseSyncStatus{
	BOOL result=YES;
	
	static sqlite3_stmt *release_calendar = nil;
	static sqlite3_stmt *release_category = nil;
	
	if(release_calendar == nil){
		const char *release_calendar_sql = "UPDATE pim_calendar set sync_status=0 where sync_status=1";
		if (sqlite3_prepare_v2(database, release_calendar_sql, -1, &release_calendar, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare statement error='%s'.", sqlite3_errmsg(database));
			return 1;
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	if(release_category == nil){
		const char *release_category_sql = "UPDATE pim_cal_folder set sync_status=0 where sync_status=1";
		if (sqlite3_prepare_v2(database, release_category_sql, -1, &release_category, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare statement error='%s'.", sqlite3_errmsg(database));
			return 1;
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	if(SQLITE_DONE != sqlite3_step(release_calendar)){
		DoLog(ERROR,@"Error update data for lock. '%s'", sqlite3_errmsg(database)); 
		result=NO;
	}
	sqlite3_reset(release_calendar);
	
	if(SQLITE_DONE != sqlite3_step(release_category)){
		DoLog(ERROR,@"Error update data for lock. '%s'", sqlite3_errmsg(database)); 
		result=NO;
	}
	sqlite3_reset(release_category);
	
	return result;
}

- (NSArray *) getAgendaEventsFrom:(NSString *) from to:(NSString *) to limit:(NSInteger) limit offset:(NSInteger) offset{
	
	NSMutableArray *result=[[NSMutableArray alloc]init];
	
	ListTodoEvent *listTodoEvent;
	
	static sqlite3_stmt *init_statement = nil;
	
	if(init_statement == nil){
		const char *sql = 
		"SELECT "\
		"c.calendar_id, "\
		"c.user_id, "\
		"c.folder_id, "\
		"c.is_synced, "\
		"c.status, "\
		"c.AllDayEvent, "\
		"c.DtStamp, "\
		"c.EndTime, "\
		"c.Location, "\
		"c.Reminder, "\
		"c.Subject, "\
		"c.event_desc, "\
		"c.starttime, "\
		"c.UID, "\
		"c.cal_recurrence_id, "\
		"c.IsException, "\
		"c.Deleted, "\
		"c.memo, "\
		"c.server_id, "\
		"c.event_icon, "\
		"f.folder_name, "\
		"f.color_rgb, "\
		"f.display_flag "\
		"FROM pim_calendar c, pim_cal_folder f "\
		"where c.folder_id = f.folder_id "\
		"and c.status != 3 "\
		"and c.cal_type !=1 "\
		"and c.reminder_dismiss != 1 "\
		"and c.reminder_dismiss != 1 "\
		"and c.StartTime >=? "\
		"and c.StartTime <=? "\
		"order by c.starttime limit ? offset ? ";
		
		if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	int i=1;
	
	//sqlite3_bind_text(init_statement,i++,[[DateTimeUtil getTodayString] UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(init_statement,i++,[from UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(init_statement,i++,[to UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(init_statement,i++,limit);
	sqlite3_bind_int(init_statement,i++,offset);
	
	NSMutableString *tmpString;
	while(sqlite3_step(init_statement) == SQLITE_ROW) {
		
		listTodoEvent = [[ListTodoEvent alloc]init];
		
		i=0;//0
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setCalendarId:tmpString];
		}
		i++;//1
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setUserId:tmpString];
		}
		i++;//2
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setFolderId:tmpString];
		}
		i++;//3
		[listTodoEvent setIsSynced:sqlite3_column_int(init_statement,i)];
		i++;//4
		[listTodoEvent setStatus:sqlite3_column_int(init_statement,i)];
		i++;//5
		[listTodoEvent setAllDayEvent:sqlite3_column_int(init_statement,i)];
		i++;//6
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setDtStamp:tmpString];
		}
		i++;//7
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setEndTime:tmpString];
		}
		i++;//8
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setLocation:tmpString];
		}
		i++;//9
		[listTodoEvent setReminder:sqlite3_column_int(init_statement,i)];
		i++;//10
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setSubject:tmpString];
		}
		i++;//11
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setEventDesc:tmpString];
		}
		i++;//12
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setStartTime:tmpString];
		}
		i++;//13
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setUid:tmpString];
		}
		i++;//14
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setCalRecurrenceId:tmpString];
		}
		i++;//15
		[listTodoEvent setIsException:sqlite3_column_int(init_statement,i)];
		i++;//16
		[listTodoEvent setDeleted:sqlite3_column_int(init_statement,i)];
		i++;//17
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setMemo:tmpString];
		}
		i++;//18
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setServerId:tmpString];
		}
		i++;//19
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setEventIcon:tmpString];
		}
		i++;//20
		if((char *)sqlite3_column_text(init_statement,i)!=NULL){
			tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
			[listTodoEvent setFolderName:tmpString];
		}
		i++;//21
		[listTodoEvent setColorRgb:sqlite3_column_int(init_statement,i)];
		i++;//22
		[listTodoEvent setDisplayFlag:sqlite3_column_int(init_statement,i)];
		
		
		[result addObject:listTodoEvent];
		[listTodoEvent release];
		
	} 
	sqlite3_reset(init_statement);
	
	return result;
}



- (NSArray *) getAgendaEvents:(NSInteger) limit offset:(NSInteger) offset{

		NSMutableArray *result=[[NSMutableArray alloc]init];
		
		ListTodoEvent *listTodoEvent;
		
		static sqlite3_stmt *init_statement = nil;
		
		if(init_statement == nil){
			const char *sql = 
			"SELECT "\
			"c.calendar_id, "\
			"c.user_id, "\
			"c.folder_id, "\
			"c.is_synced, "\
			"c.status, "\
			"c.AllDayEvent, "\
			"c.DtStamp, "\
			"c.EndTime, "\
			"c.Location, "\
			"c.Reminder, "\
			"c.Subject, "\
			"c.event_desc, "\
			"c.starttime, "\
			"c.UID, "\
			"c.cal_recurrence_id, "\
			"c.IsException, "\
			"c.Deleted, "\
			"c.memo, "\
			"c.server_id, "\
			"c.event_icon, "\
			"f.folder_name, "\
			"f.color_rgb, "\
			"f.display_flag "\
			"FROM pim_calendar c, pim_cal_folder f "\
			"where c.folder_id = f.folder_id "\
			"and c.status != 3 "\
			"and c.cal_type !=1 "\
			"and c.reminder_dismiss != 1 "\
			"order by c.starttime desc limit ? offset ? ";
			
			if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
				NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(database));
			}else
				DoLog(DEBUG,@"prepare sql ok");
		}
		
		int i=1;
		
		//sqlite3_bind_text(init_statement,i++,[[DateTimeUtil getTodayString] UTF8String],-1,SQLITE_TRANSIENT);
		sqlite3_bind_int(init_statement,i++,limit);
		sqlite3_bind_int(init_statement,i++,offset);
		
		NSMutableString *tmpString;
		while(sqlite3_step(init_statement) == SQLITE_ROW) {
			
			listTodoEvent = [[ListTodoEvent alloc]init];
			
			i=0;//0
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setCalendarId:tmpString];
			}
			i++;//1
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setUserId:tmpString];
			}
			i++;//2
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setFolderId:tmpString];
			}
			i++;//3
			[listTodoEvent setIsSynced:sqlite3_column_int(init_statement,i)];
			i++;//4
			[listTodoEvent setStatus:sqlite3_column_int(init_statement,i)];
			i++;//5
			[listTodoEvent setAllDayEvent:sqlite3_column_int(init_statement,i)];
			i++;//6
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setDtStamp:tmpString];
			}
			i++;//7
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setEndTime:tmpString];
			}
			i++;//8
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setLocation:tmpString];
			}
			i++;//9
			[listTodoEvent setReminder:sqlite3_column_int(init_statement,i)];
			i++;//10
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setSubject:tmpString];
			}
			i++;//11
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setEventDesc:tmpString];
			}
			i++;//12
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setStartTime:tmpString];
			}
			i++;//13
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setUid:tmpString];
			}
			i++;//14
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setCalRecurrenceId:tmpString];
			}
			i++;//15
			[listTodoEvent setIsException:sqlite3_column_int(init_statement,i)];
			i++;//16
			[listTodoEvent setDeleted:sqlite3_column_int(init_statement,i)];
			i++;//17
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setMemo:tmpString];
			}
			i++;//18
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setServerId:tmpString];
			}
			i++;//19
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setEventIcon:tmpString];
			}
			i++;//20
			if((char *)sqlite3_column_text(init_statement,i)!=NULL){
				tmpString=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,i)];
				[listTodoEvent setFolderName:tmpString];
			}
			i++;//21
			[listTodoEvent setColorRgb:sqlite3_column_int(init_statement,i)];
			i++;//22
			[listTodoEvent setDisplayFlag:sqlite3_column_int(init_statement,i)];
			
			
			[result addObject:listTodoEvent];
			[listTodoEvent release];
			
		} 
		sqlite3_reset(init_statement);
		
		return result;
}

- (NSInteger) getAgendaEventCount{
	static sqlite3_stmt *count_agenda = nil;
	
	if(count_agenda == nil){
		const char *count_agenda_sql = "SELECT count(*) FROM pim_calendar where cal_type!=1 and status!=3 and reminder_dismiss!=1";
		
		if (sqlite3_prepare_v2(database, count_agenda_sql, -1, &count_agenda, NULL) != SQLITE_OK) {
			DoLog(ERROR, @"prepare statement error='%s'.", sqlite3_errmsg(database));
			return -1;
		}
	}
	
	NSInteger count;
	if(sqlite3_step(count_agenda) == SQLITE_ROW) {
		count=sqlite3_column_int(count_agenda,0);
	}else
		count=0;
	sqlite3_reset(count_agenda);
	
	return count;
}

- (BOOL) updAgendaEvent:(NSString *)cId server:(NSString *) sId{
	BOOL result=YES;
	
	static sqlite3_stmt *update_agenda1 = nil;
	static sqlite3_stmt *update_agenda2 = nil;
	
	if(update_agenda1 == nil){
		const char *update_agenda1_sql = "UPDATE pim_calendar set reminder_dismiss=1 where calendar_id=?";
		if (sqlite3_prepare_v2(database, update_agenda1_sql, -1, &update_agenda1, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare statement error='%s'.", sqlite3_errmsg(database));
			return NO;
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	if(update_agenda2 == nil){
		const char *update_agenda2_sql = "UPDATE pim_calendar set reminder_dismiss=1 where server_id=?";
		if (sqlite3_prepare_v2(database, update_agenda2_sql, -1, &update_agenda2, NULL) != SQLITE_OK) {
			DoLog(ERROR,@"prepare statement error='%s'.", sqlite3_errmsg(database));
			return NO;
		}else
			DoLog(DEBUG,@"prepare sql ok");
	}
	
	if(cId!=nil && [cId length]>0){
		sqlite3_bind_text(update_agenda1,1,[cId UTF8String],-1,SQLITE_TRANSIENT);
		
		if(SQLITE_DONE != sqlite3_step(update_agenda1)){
			DoLog(ERROR,@"Error update data for agenda by calendar_id. '%s'", sqlite3_errmsg(database)); 
			result=NO;
		}
		sqlite3_reset(update_agenda1);
	}else if(sId!=nil && [sId length]>0){
		sqlite3_bind_text(update_agenda2,1,[sId UTF8String],-1,SQLITE_TRANSIENT);
		
		if(SQLITE_DONE != sqlite3_step(update_agenda2)){
			DoLog(ERROR,@"Error update data for agendar by server_id. '%s'", sqlite3_errmsg(database)); 
			result=NO;
		}
		sqlite3_reset(update_agenda2);
	}else{
		result=NO;
	}

	return result;
}


-(BOOL) insDefaultCategory{
	BOOL result=NO;
	
	NSMutableString *createSql=[[NSMutableString alloc]init];
	[createSql setString:@"INSERT INTO pim_cal_folder (folder_id,folder_name,color_rgb,"];
	[createSql appendString:@"display_flag,state_flag,sync_flag,created_datetime,modified_datetime,server_id,folder_type,sync_status) values"];
	[createSql appendString:@"(1,'我的行事曆',1,1,0,0,"];
	[createSql appendString:[DateTimeUtil getTodayString]];
	[createSql appendString:@","];
	[createSql appendString:[DateTimeUtil getTodayString]];
	[createSql appendString:@",0,1,0);"];
	
	if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
		DoLog(ERROR,@"insert table error=%@",sqlite3_errmsg(database));
	else
		result= YES;

	[createSql release];
	return result;
}

-(BOOL) delEverything{
	BOOL result=YES;
	
	NSMutableString *createSql=[[NSMutableString alloc]init];
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	
	[createSql setString:@"delete from pim_cal_recurrence"];
	if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
		DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
		result= NO;
	}
		
	if(result==YES){
		[createSql setString:@"delete from pim_calendar"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES){
		[createSql setString:@"delete from pim_cal_folder"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES){
		[createSql setString:@"delete from pim_profile"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES){
		[createSql setString:@"delete from sync_log"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES){
		[createSql setString:@"delete from backup_log"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES){
		[createSql setString:@"delete from restore_log"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES)
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
	else 
		sqlite3_exec(database, "ROLLBACK", 0, 0, 0);
	

	[createSql release];
	return result;
}

-(BOOL) resetEverything{
	BOOL result=YES;
	
	NSMutableString *createSql=[[NSMutableString alloc]init];
	
	sqlite3_exec(database, "BEGIN", 0, 0, 0);
	
	[createSql setString:@"delete from pim_calendar where status=3"];
	if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
		DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
		result= NO;
	}
	
	if(result==YES){
		[createSql setString:@"delete from pim_cal_folder where state_flag=2"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES){
		[createSql setString:@"update pim_cal_folder set state_flag=0,sync_flag=0,server_id=0"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES){
		[createSql setString:@"update pim_calendar is_synced=0,status=1,need_sync=1,server_id=0"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES){
		[createSql setString:@"delete from pim_profile"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES){
		[createSql setString:@"delete from sync_log"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES){
		[createSql setString:@"delete from backup_log"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES){
		[createSql setString:@"delete from restore_log"];
		if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK){
			DoLog(ERROR,@"delete table error=%@",sqlite3_errmsg(database));
			result= NO;
		}
	}
	
	if(result==YES)
		sqlite3_exec(database, "COMMIT", 0, 0, 0);
	else 
		sqlite3_exec(database, "ROLLBACK", 0, 0, 0);
	
	
	[createSql release];
	return result;
}

- (BOOL)checkDatabase
{
    BOOL success;
	
    NSError *error;
	NSArray *myPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [myPath objectAtIndex:0];
    NSString *userDBPath = [documentsDirectory stringByAppendingPathComponent:dbName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:userDBPath];
    if (success==NO){
		
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:userDBPath error:&error];
		if (success==NO) {
			//DoLog(ERROR,@"error=%@",[error description]);
			
			success=[fileManager createFileAtPath:userDBPath contents:nil attributes:nil];
			if(success==YES){
				if(sqlite3_open([userDBPath UTF8String], &database)!=SQLITE_OK) {
					sqlite3_close(database);
					DoLog(ERROR,@"Fail to open database.error=%@",sqlite3_errmsg(database)); 
					return NO;
				}else{
					
					NSMutableString *createSql=[[NSMutableString alloc]init];
					[createSql setString:@"CREATE TABLE IF NOT EXISTS pim_calendar("];
					[createSql appendString:@"calendar_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
					//[createSql appendString:@"calendar_id INTEGER NOT NULL,"];
					[createSql appendString:@"user_id INTEGER(20) NOT NULL,"];
					[createSql appendString:@"folder_id INTEGER(20) NOT NULL,"];
					[createSql appendString:@"last_write INTEGER(14) NOT NULL,"];
					[createSql appendString:@"is_synced INTEGER(2) NOT NULL,"];
					[createSql appendString:@"status INTEGER(2) NOT NULL,"];
					[createSql appendString:@"need_sync INTEGER(2) NOT NULL,"];
					[createSql appendString:@"TimeZone INTEGER(10),"];
					[createSql appendString:@"AllDayEvent INTEGER(1) NOT NULL,"];
					[createSql appendString:@"BusyStatus INTEGER(1) NOT NULL,"];
					[createSql appendString:@"OrganizerName VARCHAR(255),"];
					[createSql appendString:@"OrganizerEmail VARCHAR(255),"];
					[createSql appendString:@"DtStamp INTEGER(14) NOT NULL,"];
					[createSql appendString:@"EndTime INTEGER(14) NOT NULL,"];
					[createSql appendString:@"Location VARCHAR(255),"];
					[createSql appendString:@"Reminder INTEGER(10) NOT NULL,"];
					[createSql appendString:@"Sensitivity INTEGER(1) NOT NULL,"];
					[createSql appendString:@"Subject VARCHAR(255) NOT NULL,"];
					[createSql appendString:@"event_desc VARCHAR(255),"];
					[createSql appendString:@"StartTime INTEGER(14),"];
					[createSql appendString:@"UID VARCHAR(300),"];
					[createSql appendString:@"MeetingStatus INTEGER(1),"];
					[createSql appendString:@"DisallowNewTimeProposal INTEGER(1) NOT NULL,"];
					[createSql appendString:@"ResponseRequested INTEGER(1) NOT NULL,"];
					[createSql appendString:@"AppointmentReplyTime INTEGER(14),"];
					[createSql appendString:@"ResponseType INTEGER(1) NOT NULL,"];
					[createSql appendString:@"cal_recurrence_id INTEGER(20) NOT NULL,"];
					[createSql appendString:@"IsException INTEGER(1) NOT NULL,"];
					[createSql appendString:@"Deleted INTEGER(1) NOT NULL,"];
					[createSql appendString:@"PicturePath VARCHAR(255),"];
					[createSql appendString:@"VoicePath VARCHAR(255),"];
					[createSql appendString:@"NoteId VARCHAR(255),"];
					[createSql appendString:@"memo VARCHAR(1000),"];
					[createSql appendString:@"reminder_dismiss INTEGER(1) NOT NULL,"];
					[createSql appendString:@"reminder_start_time INTEGER(14),"];
					[createSql appendString:@"server_id INTEGER(20),"];
					[createSql appendString:@"cal_type INTEGER(1),"];
					[createSql appendString:@"sync_id INTEGER(20),"];
					[createSql appendString:@"sync_status INTEGER(1),"];
					[createSql appendString:@"event_icon VARCHAR(20));"];
					//[createSql appendString:@"PRIMARY KEY(calendar_id, server_id));"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					/*
					[createSql setString:@"CREATE INDEX IF NOT EXISTS inx_pim_calendar "];
					[createSql appendString:@"on pim_calendar (calendar_id);"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					*/
					[createSql setString:@"CREATE TABLE IF NOT EXISTS pim_cal_recurrence("];
					[createSql appendString:@"calendar_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
					[createSql appendString:@"Type INTEGER(1) NOT NULL,"];
					[createSql appendString:@"Occurrences INTEGER(10),"];
					[createSql appendString:@"Interval INTEGER NOT NULL,"];
					[createSql appendString:@"WeekOfMonth INTEGER(1),"];
					[createSql appendString:@"DayOfWeek INTEGER(3),"];
					[createSql appendString:@"MonthOfYear INTEGER(2),"];
					[createSql appendString:@"Until INTEGER(14),"];
					[createSql appendString:@"DayOfMonth INTEGER(3),"];
					[createSql appendString:@"Start INTEGER(14),"];
					[createSql appendString:@"folder_id INTEGER(20) NOT NULL);"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					
					[createSql setString:@"CREATE TABLE IF NOT EXISTS pim_cal_folder("];
					[createSql appendString:@"folder_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
					//[createSql appendString:@"folder_id INTEGER NOT NULL,"];
					[createSql appendString:@"folder_name VARCHAR(30) NOT NULL,"];
					[createSql appendString:@"color_rgb INTEGER(10) NOT NULL,"];
					[createSql appendString:@"display_flag INTEGER(1) NOT NULL,"];
					[createSql appendString:@"state_flag INTEGER(1) NOT NULL,"];
					[createSql appendString:@"sync_flag INTEGER(1) NOT NULL,"];
					[createSql appendString:@"lastime_sync INTEGER(14),"];
					[createSql appendString:@"created_datetime INTEGER(14) NOT NULL,"];
					[createSql appendString:@"modified_datetime INTEGER(14),"];
					[createSql appendString:@"photo_path VARCHAR(255),"];
					[createSql appendString:@"memo VARCHAR(200),"];
					[createSql appendString:@"user_id INTEGER(20),"];
					[createSql appendString:@"server_id INTEGER(20),"];
					[createSql appendString:@"folder_type INTEGER(1),"];
					[createSql appendString:@"sync_status INTEGER(1));"];
					//[createSql appendString:@"PRIMARY KEY(folder_id, server_id));"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					/*
					[createSql setString:@"CREATE INDEX IF NOT EXISTS inx_pim_cal_folder "];
					[createSql appendString:@"on pim_cal_folder (folder_id);"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					*/
					
					[createSql setString:@"CREATE TABLE IF NOT EXISTS pim_user("];
					[createSql appendString:@"user_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
					[createSql appendString:@"name VARCHAR(255) NOT NULL,"];
					[createSql appendString:@"account VARCHAR(255) NOT NULL,"];
					[createSql appendString:@"pwd VARCHAR(255) NOT NULL,"];
					[createSql appendString:@"as_domain VARCHAR(20) NOT NULL,"];
					[createSql appendString:@"mobile VARCHAR(20),"];
					[createSql appendString:@"srv_type INTEGER(3) NOT NULL);"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					
					[createSql setString:@"CREATE TABLE IF NOT EXISTS pim_cal_category("];
					[createSql appendString:@"cal_category_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
					[createSql appendString:@"user_id INTEGER(20) NOT NULL,"];
					[createSql appendString:@"Category VARCHAR(255) NOT NULL);"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					
					[createSql setString:@"CREATE TABLE IF NOT EXISTS pim_calendar_category("];
					[createSql appendString:@"cal_category_id INTEGER NOT NULL,"];
					[createSql appendString:@"calendar_id INTEGER NOT NULL,"];
					[createSql appendString:@"folder_id INTEGER(20) NOT NULL,"];
					[createSql appendString:@"PRIMARY KEY(cal_category_id, calendar_id));"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					
					[createSql setString:@"CREATE TABLE IF NOT EXISTS pim_cal_attendee("];
					[createSql appendString:@"cal_attendee_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
					[createSql appendString:@"Email VARCHAR(255) NOT NULL,"];
					[createSql appendString:@"Name VARCHAR(255) NOT NULL,"];
					[createSql appendString:@"AttendeeStatus INTEGER(1) NOT NULL,"];
					[createSql appendString:@"AttendeeType INTEGER(1) NOT NULL);"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					
					[createSql setString:@"CREATE TABLE IF NOT EXISTS pim_calendar_attendee("];
					[createSql appendString:@"cal_attendee_id INTEGER NOT NULL,"];
					[createSql appendString:@"calendar_id INTEGER NOT NULL,"];
					[createSql appendString:@"folder_id INTEGER(20) NOT NULL,"];
					[createSql appendString:@"PRIMARY KEY(cal_attendee_id, calendar_id));"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					
					[createSql setString:@"CREATE TABLE IF NOT EXISTS pim_sequence("];
					[createSql appendString:@"seq_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
					[createSql appendString:@"table_name VARCHAR(30),"];
					[createSql appendString:@"seq_value INTEGER(20));"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					
					[createSql setString:@"CREATE TABLE IF NOT EXISTS sync_log("];
					[createSql appendString:@"log_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
					[createSql appendString:@"sync_seq INTEGER,"];
					[createSql appendString:@"session_seq INTEGER,"];
					[createSql appendString:@"result INTEGER,"];
					[createSql appendString:@"start_time INTEGER(14),"];
					[createSql appendString:@"end_time INTEGER(14),"];
					[createSql appendString:@"sync_range INTEGER(14));"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));					
					
					[createSql setString:@"CREATE TABLE IF NOT EXISTS backup_log("];
					[createSql appendString:@"log_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
					[createSql appendString:@"backup_id INTEGER,"];
					[createSql appendString:@"backup_bgn_time INTEGER(14),"];
					[createSql appendString:@"backup_end_time INTEGER(14),"];
					[createSql appendString:@"backup_result INTEGER);"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					
					[createSql setString:@"CREATE TABLE IF NOT EXISTS restore_log("];
					[createSql appendString:@"log_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
					[createSql appendString:@"restore_id INTEGER,"];
					[createSql appendString:@"restore_bgn_time INTEGER(14),"];
					[createSql appendString:@"restore_end_time INTEGER(14),"];
					[createSql appendString:@"restore_result INTEGER);"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));					
					
					[createSql setString:@"CREATE TABLE IF NOT EXISTS pim_profile("];
					[createSql appendString:@"key_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"];
					[createSql appendString:@"key_name VARCHAR(50),"];
					[createSql appendString:@"key_value VARCHAR(100));"];
					if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
						DoLog(ERROR,@"create table error=%@",sqlite3_errmsg(database));
					
					[createSql release];
					
					[self insDefaultCategory];
					DoLog(DEBUG,@"create database okay");
				}
			}else{
				DoLog(ERROR,@"Fail to create database. error=%@",[error localizedDescription]);
				return NO;
			}
		}else
			DoLog(DEBUG,@"copy database ok");
	}/*else{
		//[ProfileUtil setString:userDBPath forKey:PIMSQLITE];
		//[[NSUserDefaults standardUserDefaults] setObject:userDBPath forKey:PIMSQLITE];
		DoLog(DEBUG,@"database is exist");
	}*/
	
	self.myPaths=userDBPath;
	return YES;
}


-(BOOL) alterDatabase{
	BOOL result=NO;
	
	NSMutableString *createSql=[[NSMutableString alloc]init];
	[createSql setString:@"alter table pim_sequence add column test integer"];
	
	if(sqlite3_exec(database, [createSql UTF8String], NULL, NULL, NULL)!=SQLITE_OK)
		DoLog(ERROR,@"insert table error=%@",sqlite3_errmsg(database));
	else
		result= YES;
	
	[createSql release];
	return result;
}


@end
