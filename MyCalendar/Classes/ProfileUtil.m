//
//  ProfileUtil.m
//  MyCalendar
//
//  Created by yves ho on 2010/4/4.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>
#import "ProfileUtil.h"
#import "MySqlite.h"


@implementation ProfileUtil

+(BOOL) setBool:(BOOL)value forKey:(NSString *) key{
	NSString *tmpString=[NSString stringWithFormat:@"%d",value];
	
	return [ProfileUtil setKeyPair:key value:tmpString];
}
+(BOOL) setInteger:(NSInteger)value forKey:(NSString *) key{
	NSString *tmpString=[NSString stringWithFormat:@"%d",value];
	
	return [ProfileUtil setKeyPair:key value:tmpString];
}
+(BOOL) setString:(NSString *)value forKey:(NSString *) key{
	
	return [ProfileUtil setKeyPair:key value:value];
}
+(BOOL) setKeyPair:(NSString *) key value:(NSString *)value{
	BOOL result;
	NSInteger count=-1;
	static sqlite3_stmt *sel_profile = nil;
	static sqlite3_stmt *upd_profile = nil;
	static sqlite3_stmt *ins_profile = nil;
	MySqlite *mySqlite=[[MySqlite alloc]init]; 
	if(sel_profile == nil){
		 const char *sql1 = "SELECT count(*) FROM pim_profile WHERE key_name=?";
	 
		 if (sqlite3_prepare_v2(mySqlite.database, sql1, -1, &sel_profile, NULL) != SQLITE_OK) {
			 DoLog(ERROR,@"prepare select statement error='%s'.", sqlite3_errmsg(mySqlite.database));
			 [mySqlite release];
			 return FALSE;
		 }
	}
	 
	if(upd_profile == nil){
		 const char *sql2 = "UPDATE pim_profile SET key_value=? WHERE key_name=?";
	 
		 if (sqlite3_prepare_v2(mySqlite.database, sql2, -1, &upd_profile, NULL) != SQLITE_OK) {
			 DoLog(ERROR,@"prepare update statement error='%s'.", sqlite3_errmsg(mySqlite.database));
			 [mySqlite release];
			 return FALSE;
		 }
	}
	 
	if(ins_profile == nil){
		 const char *sql3 = "INSERT INTO pim_profile (key_name,key_value) VALUES(?,?)";
	 
		 if (sqlite3_prepare_v2(mySqlite.database, sql3, -1, &ins_profile, NULL) != SQLITE_OK) {
			 DoLog(ERROR,@"prepare insert statement error='%s'.", sqlite3_errmsg(mySqlite.database));
			 [mySqlite release];
			 return FALSE;
		 }
	}
	
	sqlite3_bind_text(sel_profile,1,[key UTF8String],-1,SQLITE_TRANSIENT);
	if(sqlite3_step(sel_profile) == SQLITE_ROW) {
		 
		 count=sqlite3_column_int(sel_profile,0);
	}
	sqlite3_reset(sel_profile);
	  
	 
	if(count<=0){
		 sqlite3_bind_text(ins_profile,1,[key UTF8String],-1,SQLITE_TRANSIENT);
		 sqlite3_bind_text(ins_profile,2,[value UTF8String],-1,SQLITE_TRANSIENT);
		 if(SQLITE_DONE != sqlite3_step(ins_profile)){
			 DoLog(ERROR,@"Error insert profile data. '%s'", sqlite3_errmsg(mySqlite.database)); 
			 result=NO;
		 }else
			 result=YES;
		 sqlite3_reset(ins_profile);
	}else{
		 sqlite3_bind_text(upd_profile,1,[value UTF8String],-1,SQLITE_TRANSIENT);
		 sqlite3_bind_text(upd_profile,2,[key UTF8String],-1,SQLITE_TRANSIENT);
		 if(SQLITE_DONE != sqlite3_step(upd_profile)){			
			 DoLog(DEBUG,@"Error update profile data. '%s'", sqlite3_errmsg(mySqlite.database));
			 result=NO;
		 }else
			 result=YES;
		 sqlite3_reset(upd_profile);
	}
	[mySqlite release];
	 
	return result;
}


+(BOOL) boolForKey:(NSString *) key{
	BOOL result=FALSE;
	
	NSString *tmp=[ProfileUtil getKeyPair:key];
	
	if(tmp!=nil && [tmp length]>0 && ([tmp intValue]==0 || [tmp intValue]==1) )
		result = [tmp boolValue];
	
	return result;
}

+(NSInteger) integerForKey:(NSString *) key{
	NSInteger result=-1;
	
	NSString *tmp=[ProfileUtil getKeyPair:key];
	
	if(tmp!=nil && [tmp length]>0)
		result = [tmp intValue];
	
	return result;
}

+(NSString *) stringForKey:(NSString *) key{
	return [ProfileUtil getKeyPair:key];
}

+(NSString *) getKeyPair:(NSString *) key{
	 NSString *result=nil;
	
	 static sqlite3_stmt *select_profile = nil;
	 MySqlite *mySqlite=[[MySqlite alloc]init];
	 if(select_profile == nil){
		 const char *select_profile_sql = "SELECT key_value FROM pim_profile WHERE key_name=?";
	 
		 if (sqlite3_prepare_v2(mySqlite.database, select_profile_sql, -1, &select_profile, NULL) != SQLITE_OK) {
			 DoLog(ERROR,@"prepare select statement error='%s'.", sqlite3_errmsg(mySqlite.database));
			 [mySqlite release];
			 return nil;
		 }
	 }
	 
	 sqlite3_bind_text(select_profile,1,[key UTF8String],-1,SQLITE_TRANSIENT);
	 if(sqlite3_step(select_profile) == SQLITE_ROW) {
		 if((char *)sqlite3_column_text(select_profile,0)!=NULL)
			 result=[NSString stringWithUTF8String:(char*)sqlite3_column_text(select_profile,0)];
	 }
	 sqlite3_reset(select_profile);
	 [mySqlite release];
	 
	 return result;
}



@end
