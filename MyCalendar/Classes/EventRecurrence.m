//
//  EventRecurrence.m
//  MyCalendar
//
//  Created by Admin on 2010/3/2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventRecurrence.h"


static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *ins_statement = nil;

@implementation EventRecurrence

@synthesize calendarId,type,occurrences,interval,weekOfMonth,dayOfWeek,monthOfYear;
@synthesize until,dayOfMonth,start,folderId;

- (id)initWithId:(NSString *)cId database:(sqlite3 *)db {
	
	if (self = [super init]) {
		if (init_statement == nil) {
            const char *sql = "Select calendar_id,Type,Occurrences,Interval,WeekOfMonth,DayOfWeek,MonthOfYear,Until,DayOfMonth,Start FROM pim_cal_recurrence WHERE calendar_id=?";
            if (sqlite3_prepare_v2(db, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(db));
            }
        }
        
		int i=1;
        //sqlite3_bind_int(init_statement, i++, cId);
		sqlite3_bind_text(init_statement,i++,[cId UTF8String],-1,SQLITE_TRANSIENT);
		
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
			int i=0;
			
			//self.calendarId=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.calendarId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			else
				self.calendarId=@"";
			
			self.type=sqlite3_column_int(init_statement,i++);
			self.occurrences=sqlite3_column_int(init_statement,i++);
			self.interval=sqlite3_column_int(init_statement,i++);
			self.weekOfMonth=sqlite3_column_int(init_statement,i++);
			self.dayOfWeek=sqlite3_column_int(init_statement,i++);
			self.monthOfYear=sqlite3_column_int(init_statement,i++);
			
			//self.until=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.until=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			
			self.dayOfMonth=sqlite3_column_int(init_statement,i++);
			
			//self.start=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.start=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
			
			//self.folderId=sqlite3_column_int(init_statement,i++);
			if((char*)sqlite3_column_text(init_statement,i++)!=NULL)
				self.folderId=[NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement,(i-1))];
		} else {
			self.calendarId=@"";
			self.type=-1;
        }
		sqlite3_reset(init_statement);
    }
    return self;
}

- (BOOL) insEventRecurrenceDatabase:(sqlite3 *)db{
	BOOL result = NO;
	
	if (ins_statement == nil) {
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
		if (sqlite3_prepare_v2(db, sql, -1, &ins_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"prepare statement error='%s'.", sqlite3_errmsg(db));
		}
	}
	
	int i=1;
	sqlite3_bind_text(ins_statement,i++,[self.calendarId UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement,i++,self.type);
	sqlite3_bind_int(ins_statement,i++,self.occurrences);
	sqlite3_bind_int(ins_statement,i++,self.interval);
	sqlite3_bind_int(ins_statement,i++,self.weekOfMonth);
	sqlite3_bind_int(ins_statement,i++,self.dayOfWeek);
	sqlite3_bind_int(ins_statement,i++,self.monthOfYear);
	sqlite3_bind_text(ins_statement,i++,[self.until UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_int(ins_statement,i++,self.dayOfMonth);
	sqlite3_bind_text(ins_statement,i++,[self.start UTF8String],-1,SQLITE_TRANSIENT);
	sqlite3_bind_text(ins_statement,i++,[self.folderId UTF8String],-1,SQLITE_TRANSIENT);
	
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

- (void)dealloc {
	[folderId release];
	[calendarId release];
	[until release];
	[start release];
	[super dealloc];
}

@end