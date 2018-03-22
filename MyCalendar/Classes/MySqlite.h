//
//  MySqlite.h
//  MyCalendar
//
//  Created by yves ho on 2010/2/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "TodoCategory.h"
#import "TodoEvent.h"
#import "EventRecurrence.h"

@interface MySqlite : NSObject {
	NSString *myPaths;
	NSString *dbName;
	sqlite3 *database;
}

@property (nonatomic,retain) NSString *myPaths;
@property (nonatomic,retain) NSString *dbName;
@property (nonatomic) sqlite3 *database;

- (BOOL) checkDatabase;

- (NSArray *) getTodoCategorys;
- (NSInteger) getTodoCategoryCount;
- (TodoCategory *) getDefaultCategory;
- (BOOL) insTodoCategory:(TodoCategory *) myCategory;
- (BOOL) updTodoCategory:(TodoCategory *) myCategory;
- (BOOL) delTodoCategory:(TodoCategory *) myCategory;
- (BOOL) delRelationCategory:(NSString *) folderId server:(NSString *)sId;

- (BOOL) insTodoEvent:(NSArray *) myEvent trans:(BOOL)tflag;
- (BOOL) delTodoEvent:(TodoEvent *) myEvent trans:(BOOL)tflag;
- (BOOL) delUpdTodoEvent:(TodoEvent *) myEvent trans:(BOOL)tflag;
- (BOOL) updTodoEvent:(NSString *)cId server:(NSString *)sId data:(NSArray *) myEvent;

- (NSString *) getMaxSequence:(NSString *)tableName trans:(BOOL) tflag;
- (NSArray *) getListTodoEventFrom:(NSString *) from to:(NSString *) to;
- (NSArray *) getTodoEventStartTimeFrom:(NSString *) from to:(NSString *) to;

- (NSArray *) getAgendaEvents:(NSInteger) limit offset:(NSInteger) offset;
- (NSArray *) getAgendaEventsFrom:(NSString *) from to:(NSString *) to limit:(NSInteger) limit offset:(NSInteger) offset;
- (NSInteger) getAgendaEventCount;
- (BOOL) updAgendaEvent:(NSString *)cId server:(NSString *) sId;

//content sync and recurrence sync
- (NSArray *) getTodoEventSyncServerId;
- (NSArray *) getTodoEventSyncCalendarIdByStartTime:(NSString *)startTime LastWrite:(NSString *)lastWrite Limit:(NSInteger) limit offset:(NSInteger) offset;
- (NSArray *) getRecurrenceSyncServerId;
- (NSArray *) getRecurrenceSyncCalendarIdByStartTime:(NSString *)startTime LastWrite:(NSString *)lastWrite Limit:(NSInteger) limit offset:(NSInteger) offset;
- (BOOL) updatePimCalendarSetSyncFlag:(NSInteger)syncFlag ServerId:(NSString *)serviceId SyncId:(NSString*) syncId WhereCalendarId:(NSString *)clientId;
- (BOOL) updatePimCalendarSetCalRecurrenceId:(NSString *)ServerId WhereCalRecurrenceId:(NSString *) clientId;
- (BOOL) updatePimCalRecurrenceSetCalendarId:(NSString *)ServerId WhereCalendarId: (NSString *) clientId;
- (BOOL) updatePimCalendarSetSyncFlag:(NSInteger)syncFlag SyncId:(NSString*) syncId WhereServerId:(NSString *)serverId;
- (BOOL) deleteFromPimCalendarWhereServerId:(NSString *)serverId;
- (BOOL) deleteRecurrenceEventByCalendarId:(NSString *)calendarId;
- (BOOL) insToEvent:(TodoEvent *)todoEvent EventRecurrence:(EventRecurrence *)eventRecurrence Database:(sqlite3 *)db;
- (BOOL) updatePimCalendarSetSyncFlag:(NSInteger)syncFlag SyncId:(NSString*) syncId WhereCalRecurrenceId:(NSString *)calendarId;
- (BOOL) checkExistOfServerId:(NSString *) serverId;
- (BOOL) deletePimCalendarFolderRecurrence;
- (BOOL) updatePimCalendarSetSyncStatus:(NSInteger)syncStatus WhereServerId:(NSString *)serverId;//#add
- (BOOL) updatePimCalendarSetSyncStatus:(NSInteger)syncStatus WhereCalendarId:(NSString *)calendarId;//#add
- (BOOL) updatePimCalendarSetSyncStatus:(NSInteger)syncStatus WhereSyncStatus:(NSInteger)syncStatus2;//#add

- (BOOL) releaseSyncStatus;


//backup and restore
-(NSMutableDictionary *) getLastBackupLog:(NSInteger) state;
-(NSMutableDictionary *) getLastRestoreLog:(NSInteger) state;
-(BOOL) updBackupLog:(NSMutableDictionary *)bLog;
-(BOOL) updRestoreLog:(NSMutableDictionary *)rLog;
-(BOOL) insBackupLog:(NSMutableDictionary *) bLog;
-(BOOL) insRestoreLog:(NSMutableDictionary *) rLog;
-(BOOL) delBackupLog:(NSString *)bId;
-(BOOL) delRestoreLog:(NSString *)rId;

-(BOOL) delEverything;
-(BOOL) resetEverything;
-(BOOL) insDefaultCategory;
-(BOOL) alterDatabase;



@end
