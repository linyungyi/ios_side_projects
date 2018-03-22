//
//  TodoCategory.m
//  MyCalendar
//
//  Created by Admin on 2010/3/2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TodoCategory.h"


static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *init_statement2 = nil;

@implementation TodoCategory

@synthesize folderId,folderName,colorRgb,displayFlag,stateFlag,syncFlag,lastimeSync;
@synthesize createdDatetime,modifiedDatetime,photoPath,memo,userId,serverId;

@synthesize folderType,syncStatus;

- (id)initWithCategoryId:(NSString *)fId database:(sqlite3 *)db {
	
	if (self = [super init]) {
		if (init_statement == nil) {
            const char *sql = "Select folder_id,folder_name,color_rgb,display_flag,state_flag,sync_flag,lastime_sync,created_datetime,modified_datetime,photo_path,memo,user_id,server_id,folder_type,sync_status FROM pim_cal_folder WHERE folder_id=? ";
            if (sqlite3_prepare_v2(db, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(db));
            }
        }
        
		int i=1;
        //sqlite3_bind_int(init_statement, i++, fId);
		sqlite3_bind_text(init_statement,i++,[fId UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(init_statement, i++, sId);
		//sqlite3_bind_text(init_statement,i++,[sId UTF8String],-1,SQLITE_TRANSIENT);
		
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			int i=0;
			
			//self.folderId=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.folderId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.folderId=@"";
			
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.folderName=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.folderName=@"";
			
			self.colorRgb=sqlite3_column_int(init_statement,i++);
			self.displayFlag=sqlite3_column_int(init_statement,i++);
			self.stateFlag=sqlite3_column_int(init_statement,i++);
			self.syncFlag=sqlite3_column_int(init_statement,i++);
			//DoLog(DEBUG,@"state=%d sync=%d",stateFlag,syncFlag);
			
			//self.lastimeSync=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.lastimeSync=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			
			//self.createdDatetime=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.createdDatetime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			
			//self.modifiedDatetime=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.modifiedDatetime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.photoPath=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.memo=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			
			//self.userId=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.userId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			
			//self.serverId=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.serverId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			
			self.folderType=sqlite3_column_int(init_statement,i++);
			self.syncStatus=sqlite3_column_int(init_statement,i++);
			
		} else {
			self.folderId=@"";
			self.folderType=0;
        }
		sqlite3_reset(init_statement);
    }
    return self;
}

- (id)initWithCategoryServerId:(NSString *)sId database:(sqlite3 *)db {
	
	if (self = [super init]) {
		if (init_statement2 == nil) {
            const char *sql = "Select folder_id,folder_name,color_rgb,display_flag,state_flag,sync_flag,lastime_sync,created_datetime,modified_datetime,photo_path,memo,user_id,server_id,folder_type,sync_status FROM pim_cal_folder WHERE server_id=? ";
            DoLog(DEBUG,@"sql:%s",sql);
			if (sqlite3_prepare_v2(db, sql, -1, &init_statement2, NULL) != SQLITE_OK) {
                NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(db));
            }
        }
        
		int i=1;
        //sqlite3_bind_int(init_statement2, i++, fId);
		sqlite3_bind_text(init_statement2,i++,[sId UTF8String],-1,SQLITE_TRANSIENT);
		
		//sqlite3_bind_int(init_statement2, i++, sId);
		//sqlite3_bind_text(init_statement2,i++,[sId UTF8String],-1,SQLITE_TRANSIENT);
		
        if (sqlite3_step(init_statement2) == SQLITE_ROW) {
			int i=0;
			
			//self.folderId=sqlite3_column_int(init_statement2,i++);
			if((char*)sqlite3_column_text(init_statement2,i++)!=NULL)
				self.folderId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement2,(i-1))];
			else
				self.folderId=@"";
			
			if((char*)sqlite3_column_text(init_statement2,i++)!=NULL)
				self.folderName=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement2,(i-1))];
			else
				self.folderName=@"";
			
			self.colorRgb=sqlite3_column_int(init_statement2,i++);
			self.displayFlag=sqlite3_column_int(init_statement2,i++);
			self.stateFlag=sqlite3_column_int(init_statement2,i++);
			self.syncFlag=sqlite3_column_int(init_statement2,i++);
			
			//self.lastimeSync=sqlite3_column_int(init_statement2,i++);
			if((char*)sqlite3_column_text(init_statement2,i++)!=NULL)
				self.lastimeSync=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement2,(i-1))];
			
			//self.createdDatetime=sqlite3_column_int(init_statement2,i++);
			if((char*)sqlite3_column_text(init_statement2,i++)!=NULL)
				self.createdDatetime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement2,(i-1))];
			
			//self.modifiedDatetime=sqlite3_column_int(init_statement2,i++);
			if((char*)sqlite3_column_text(init_statement2,i++)!=NULL)
				self.modifiedDatetime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement2,(i-1))];
			
			if((char*)sqlite3_column_text(init_statement2,i++)!=NULL)
				self.photoPath=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement2,(i-1))];
			if((char*)sqlite3_column_text(init_statement2,i++)!=NULL)
				self.memo=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement2,(i-1))];
			
			//self.userId=sqlite3_column_int(init_statement2,i++);
			if((char*)sqlite3_column_text(init_statement2,i++)!=NULL)
				self.userId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement2,(i-1))];
			
			//self.serverId=sqlite3_column_int(init_statement2,i++);
			if((char*)sqlite3_column_text(init_statement2,i++)!=NULL)
				self.serverId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement2,(i-1))];
			
			self.folderType=sqlite3_column_int(init_statement2,i++);
			self.syncStatus=sqlite3_column_int(init_statement2,i++);
		} else {
			self.folderId=@"";
			self.folderType=0;
        }
		sqlite3_reset(init_statement2);
    }
    return self;
}

- (void)dealloc {
	[folderId release];
	[folderName release];
	[lastimeSync release];
	[createdDatetime release];
	[modifiedDatetime release];
	[photoPath release];
	[memo release];
	[userId release];
	[serverId release];
	[super dealloc];
}

@end