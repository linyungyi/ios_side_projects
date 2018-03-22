//
//  TodoEvent.m
//  MyCalendar
//
//  Created by yves ho on 2010/2/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TodoEvent.h"

static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *init_statement1 = nil;
static sqlite3_stmt *upd_statement = nil;
static sqlite3_stmt *ins_statement = nil;


@implementation TodoEvent

@synthesize calendarId,userId,folderId,lastWrite,isSynced;
@synthesize status,needSync,timeZone,allDayEvent,busyStatus;
@synthesize organizerName,organizerEmail,dtStamp;
@synthesize endTime,location,reminder,sensitivity;
@synthesize subject,eventDesc,startTime,uid,meetingStatus;
@synthesize disallowNewTimeProposal,responseRequested,appointmentReplyTime;
@synthesize responseType,calRecurrenceId,isException,deleted,picturePath;
@synthesize voicePath,noteId,memo,reminderDismiss,reminderStartTime,serverId;
@synthesize calType,syncId,syncStatus,eventIcon;

- (id)initWithEventId:(NSString *)cId  database:(sqlite3 *)db {
	
	if (self = [super init]) {
		if (init_statement == nil) {
            const char *sql = "Select calendar_id,user_id,folder_id,last_write,is_synced,status,need_sync,TimeZone,AllDayEvent,BusyStatus,OrganizerName,OrganizerEmail,DtStamp,EndTime,Location,Reminder,Sensitivity,Subject,event_desc,StartTime,UID,MeetingStatus,DisallowNewTimeProposal,ResponseRequested,AppointmentReplyTime,ResponseType,cal_recurrence_id,IsException,Deleted,PicturePath,VoicePath,NoteId,memo,reminder_dismiss,reminder_start_time,server_id,cal_type,sync_id,sync_status,event_icon from pim_calendar Where calendar_id=?;";
            if (sqlite3_prepare_v2(db, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(db));
            }
        }
        
		int i=1;
        //sqlite3_bind_int(init_statement, i++, cId);
		sqlite3_bind_text(init_statement,i++,[cId UTF8String],-1,SQLITE_TRANSIENT);
		//sqlite3_bind_int(init_statement, i++, sId);
		//sqlite3_bind_text(init_statement,i++,[sId UTF8String],-1,SQLITE_TRANSIENT);
		
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			int i=0;
			
			//self.calendarId=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.calendarId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.calendarId=@"";
			
			//self.userId=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.userId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.userId=@"";	
			
			//self.folderId=sqlite3_column_int(init_statement,i++);	
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.folderId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.folderId=@"";	
			
			//self.lastWrite=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.lastWrite=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.lastWrite=@"";	
			
			self.isSynced=sqlite3_column_int(init_statement,i++);
			self.status=sqlite3_column_int(init_statement,i++);
			self.needSync=sqlite3_column_int(init_statement,i++);
			self.timeZone=sqlite3_column_int(init_statement,i++);
			self.allDayEvent=sqlite3_column_int(init_statement,i++);
			self.busyStatus=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.organizerName=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.organizerName=@"";	
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.organizerEmail=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.organizerEmail=@"";
			
			//self.dtStamp=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.dtStamp=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.dtStamp=@"";	
			
			//self.endTime=sqlite3_column_int(init_statement,i++);	
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.endTime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.endTime=@"";
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.location=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.location=@"";
			self.reminder=sqlite3_column_int(init_statement,i++);
			self.sensitivity=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.subject=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.subject=@"";
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.eventDesc=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.eventDesc=@"";
			
			//self.startTime=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.startTime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.startTime=@"";
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.uid=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.uid=@"";
			self.meetingStatus=sqlite3_column_int(init_statement,i++);
			self.disallowNewTimeProposal=sqlite3_column_int(init_statement,i++);
			self.responseRequested=sqlite3_column_int(init_statement,i++);
			
			//self.appointmentReplyTime=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.appointmentReplyTime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.appointmentReplyTime=@"";
			
			self.responseType=sqlite3_column_int(init_statement,i++);
			
			//self.calRecurrenceId=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.calRecurrenceId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.calRecurrenceId=@"";
			
			self.isException=sqlite3_column_int(init_statement,i++);	
			self.deleted=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.picturePath=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.picturePath=@"";
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.voicePath=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.voicePath=@"";	
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.noteId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.noteId=@"";
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.memo=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.memo=@"";	
			self.reminderDismiss=sqlite3_column_int(init_statement,i++);	
			
			//self.reminderStartTime=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.reminderStartTime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.reminderStartTime=@"";	
			
			//self.serverId=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.serverId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.serverId=@"";
			
			self.calType=sqlite3_column_int(init_statement,i++);
			
			//self.syncId=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.syncId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.syncId=@"";
			
			self.syncStatus=sqlite3_column_int(init_statement, i++);
			
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.eventIcon=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.eventIcon=@"";
        } else {
            self.calendarId = @"";
			self.serverId = @"";
        }
		sqlite3_reset(init_statement);
    }
    return self;
}

- (void) dealloc{
	[calendarId release];
	[userId release];
	[folderId release];
	[lastWrite release];
	[organizerName release];
	[organizerEmail release];
	[dtStamp release];
	[endTime release];
	[location release];
	[subject release];
	[eventDesc release];
	[startTime release];
	[uid release];
	[appointmentReplyTime release];
	[calRecurrenceId release];
	[picturePath release];
	[voicePath release];
	[noteId release];
	[memo release];
	[reminderStartTime release];
	[serverId release];
	[syncId release];
	[eventIcon release];
	[super dealloc];
}


- (id)initWithServerId:(NSString *)sId  database:(sqlite3 *)db {
	
	if (self = [super init]) {
		if (init_statement1 == nil) {
            const char *sql = "Select calendar_id,user_id,folder_id,last_write,is_synced,status,need_sync,TimeZone,AllDayEvent,BusyStatus,OrganizerName,OrganizerEmail,DtStamp,EndTime,Location,Reminder,Sensitivity,Subject,event_desc,StartTime,UID,MeetingStatus,DisallowNewTimeProposal,ResponseRequested,AppointmentReplyTime,ResponseType,cal_recurrence_id,IsException,Deleted,PicturePath,VoicePath,NoteId,memo,reminder_dismiss,reminder_start_time,server_id,cal_type,sync_id,sync_status,event_icon from pim_calendar Where server_id=?;";
            if (sqlite3_prepare_v2(db, sql, -1, &init_statement1, NULL) != SQLITE_OK) {
                NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(db));
            }
        }
        
		int i=1;
		sqlite3_bind_text(init_statement1,i++,[sId UTF8String],-1,SQLITE_TRANSIENT);
		
        if (sqlite3_step(init_statement1) == SQLITE_ROW) {
			int i=0;
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.calendarId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.calendarId=@"";
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.userId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.userId=@"";	
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.folderId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.folderId=@"";	
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.lastWrite=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.lastWrite=@"";	
			
			self.isSynced=sqlite3_column_int(init_statement1,i++);
			self.status=sqlite3_column_int(init_statement1,i++);
			self.needSync=sqlite3_column_int(init_statement1,i++);
			self.timeZone=sqlite3_column_int(init_statement1,i++);
			self.allDayEvent=sqlite3_column_int(init_statement1,i++);
			self.busyStatus=sqlite3_column_int(init_statement1,i++);
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.organizerName=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.organizerName=@"";	
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.organizerEmail=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.organizerEmail=@"";
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.dtStamp=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.dtStamp=@"";	
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.endTime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.endTime=@"";
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.location=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.location=@"";
			self.reminder=sqlite3_column_int(init_statement1,i++);
			self.sensitivity=sqlite3_column_int(init_statement1,i++);
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.subject=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.subject=@"";
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.eventDesc=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.eventDesc=@"";
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.startTime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.startTime=@"";
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.uid=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.uid=@"";
			self.meetingStatus=sqlite3_column_int(init_statement1,i++);
			self.disallowNewTimeProposal=sqlite3_column_int(init_statement1,i++);
			self.responseRequested=sqlite3_column_int(init_statement1,i++);
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.appointmentReplyTime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.appointmentReplyTime=@"";
			
			self.responseType=sqlite3_column_int(init_statement1,i++);
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.calRecurrenceId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.calRecurrenceId=@"";
			
			self.isException=sqlite3_column_int(init_statement1,i++);	
			self.deleted=sqlite3_column_int(init_statement1,i++);
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.picturePath=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.picturePath=@"";
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.voicePath=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.voicePath=@"";	
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.noteId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.noteId=@"";
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.memo=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.memo=@"";	
			self.reminderDismiss=sqlite3_column_int(init_statement1,i++);	
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.reminderStartTime=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.reminderStartTime=@"";	
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.serverId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.serverId=@"";
			
			self.calType=sqlite3_column_int(init_statement1,i++);
			
			if((char*)sqlite3_column_text(init_statement1,i++)!=NULL)
				self.syncId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement1,(i-1))];
			else
				self.syncId=@"";
			
			self.syncStatus=sqlite3_column_int(init_statement1,i++);
			
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.eventIcon=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.eventIcon=@"";
        } else {
            self.calendarId = @"";
			self.serverId = @"";
        }
		sqlite3_reset(init_statement1);
    }
    return self;
}

- (BOOL) insTodoEventDatabase:(sqlite3 *)db{
	BOOL result = NO;
	
	if (ins_statement == nil) {
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
		"sync_id,"\
		"sync_status,"\
		"event_icon "\
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
		"?, "\
		"? "\
		")";
		if (sqlite3_prepare_v2(db, sql, -1, &ins_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(db));
		}
	}
	
	int i=1;
	//sqlite3_bind_text(ins_statement,i++,[self.calendarId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.userId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.folderId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.lastWrite UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement,i++,self.isSynced);
	sqlite3_bind_int(ins_statement,i++,self.status);
	sqlite3_bind_int(ins_statement,i++,self.needSync);
	sqlite3_bind_int(ins_statement,i++,self.timeZone);
	sqlite3_bind_int(ins_statement,i++,self.allDayEvent);
	sqlite3_bind_int(ins_statement,i++,self.busyStatus);
	sqlite3_bind_text(ins_statement,i++,[self.organizerName UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.organizerEmail UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.dtStamp UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.endTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.location UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement,i++,self.reminder);
	sqlite3_bind_int(ins_statement,i++,self.sensitivity);
	sqlite3_bind_text(ins_statement,i++,[self.subject UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.eventDesc UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.startTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.uid UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement,i++,self.meetingStatus);
	sqlite3_bind_int(ins_statement,i++,self.disallowNewTimeProposal);
	sqlite3_bind_int(ins_statement,i++,self.responseRequested);
	sqlite3_bind_text(ins_statement,i++,[self.appointmentReplyTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement,i++,self.responseType);
	sqlite3_bind_text(ins_statement,i++,[self.calRecurrenceId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement,i++,self.isException);
	sqlite3_bind_int(ins_statement,i++,self.deleted);
	sqlite3_bind_text(ins_statement,i++,[self.picturePath UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.voicePath UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.noteId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.memo UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement,i++,self.reminderDismiss);
	sqlite3_bind_text(ins_statement,i++,[self.reminderStartTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.serverId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement,i++,self.calType);
	sqlite3_bind_text(ins_statement,i++,[self.syncId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement,i++,self.syncStatus);
	sqlite3_bind_text(ins_statement,i++,[self.eventIcon UTF8String],-1,SQLITE_TRANSIENT);
	
	BOOL flag;
	sqlite3_exec(db, "BEGIN", 0, 0, 0);
	if(SQLITE_DONE != sqlite3_step(ins_statement)){
		DoLog(ERROR,@"Error insert data. '%s'", sqlite3_errmsg(db)); 
		flag=NO;
	}else
		flag=YES;
	
	
	if(flag==YES){
		sqlite3_exec(db, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(db, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(ins_statement);
	
	return result;
}

- (BOOL) updTodoEventByServerId:(NSString *)iServerId Database:(sqlite3 *)db{
	BOOL result = NO;
	
	if (upd_statement == nil) {
		const char *sql = 
		"update pim_calendar set "\
		"user_id = ? , "\
		"folder_id = ? , "\
		"last_write = ? , "\
		"is_synced = ? , "\
		"status = ? , "\
		"need_sync = ? , "\
		"TimeZone = ? , "\
		"AllDayEvent = ? , "\
		"BusyStatus = ? , "\
		"OrganizerName = ? , "\
		"OrganizerEmail = ? , "\
		"DtStamp = ? , "\
		"EndTime = ? , "\
		"Location = ? , "\
		"Reminder = ? , "\
		"Sensitivity = ? , "\
		"Subject = ? , "\
		"event_desc = ? , "\
		"StartTime = ? , "\
		"UID = ? , "\
		"MeetingStatus = ? , "\
		"DisallowNewTimeProposal = ? , "\
		"ResponseRequested = ? , "\
		"AppointmentReplyTime = ? , "\
		"ResponseType = ? , "\
		"cal_recurrence_id = ? , "\
		"IsException = ? , "\
		"Deleted = ? , "\
		"PicturePath = ? , "\
		"VoicePath = ? , "\
		"NoteId = ? , "\
		"memo = ? , "\
		"reminder_dismiss = ? , "\
		"reminder_start_time = ? , "\
		"server_id = ? , "\
		"cal_type = ? , "\
		"sync_id = ? ,"\
		"event_icon = ? "\
		"where server_id =? ";
		if (sqlite3_prepare_v2(db, sql, -1, &upd_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(db));
		}
	}
	
	int i=1;
	//sqlite3_bind_text(upd_statement,i++,[self.calendarId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.userId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.folderId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.lastWrite UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(upd_statement,i++,self.isSynced);
	sqlite3_bind_int(upd_statement,i++,self.status);
	sqlite3_bind_int(upd_statement,i++,self.needSync);
	sqlite3_bind_int(upd_statement,i++,self.timeZone);
	sqlite3_bind_int(upd_statement,i++,self.allDayEvent);
	sqlite3_bind_int(upd_statement,i++,self.busyStatus);
	sqlite3_bind_text(upd_statement,i++,[self.organizerName UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.organizerEmail UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.dtStamp UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.endTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.location UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(upd_statement,i++,self.reminder);
	sqlite3_bind_int(upd_statement,i++,self.sensitivity);
	sqlite3_bind_text(upd_statement,i++,[self.subject UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.eventDesc UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.startTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.uid UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(upd_statement,i++,self.meetingStatus);
	sqlite3_bind_int(upd_statement,i++,self.disallowNewTimeProposal);
	sqlite3_bind_int(upd_statement,i++,self.responseRequested);
	sqlite3_bind_text(upd_statement,i++,[self.appointmentReplyTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(upd_statement,i++,self.responseType);
	sqlite3_bind_text(upd_statement,i++,[self.calRecurrenceId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(upd_statement,i++,self.isException);
	sqlite3_bind_int(upd_statement,i++,self.deleted);
	sqlite3_bind_text(upd_statement,i++,[self.picturePath UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.voicePath UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.noteId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.memo UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(upd_statement,i++,self.reminderDismiss);
	sqlite3_bind_text(upd_statement,i++,[self.reminderStartTime UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.serverId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(upd_statement,i++,self.calType);
	sqlite3_bind_text(upd_statement,i++,[self.syncId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(upd_statement,i++,[self.eventIcon UTF8String],-1,SQLITE_TRANSIENT);
	
	//condiction
	sqlite3_bind_text(upd_statement,i++,[iServerId UTF8String],-1,SQLITE_TRANSIENT);
	
	
	BOOL flag;
	sqlite3_exec(db, "BEGIN", 0, 0, 0);
	if(SQLITE_DONE != sqlite3_step(upd_statement)){
		DoLog(ERROR,@"Error insert data. '%s'", sqlite3_errmsg(db)); 
		flag=NO;
	}else
		flag=YES;
	
	
	if(flag==YES){
		sqlite3_exec(db, "COMMIT", 0, 0, 0);
		result=YES;
	}else{
		sqlite3_exec(db, "ROLLBACK",0,0,0);
		result=NO;
	}
	sqlite3_reset(upd_statement);
	
	return result;
}
@end
