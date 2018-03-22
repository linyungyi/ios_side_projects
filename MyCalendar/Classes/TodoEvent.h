//
//  TodoEvent.h
//  MyCalendar
//
//  Created by yves ho on 2010/2/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface TodoEvent : NSObject {
	//NSUInteger calendarId;
	NSString *calendarId;
	//NSUInteger userId;
	NSString *userId;
	//NSNumber folderId;
	NSString *folderId;
	//NSNumber lastWrite;
	NSString *lastWrite;
	NSInteger isSynced;
	NSInteger status;
	NSInteger needSync;
	NSInteger timeZone;
	NSInteger allDayEvent;
	NSInteger busyStatus;
	NSString *organizerName;
	NSString *organizerEmail;
	//NSNumber dtStamp;
	NSString *dtStamp;
	//NSNumber endTime;
	NSString *endTime;
	NSString *location;
	NSInteger reminder;
	NSInteger sensitivity;
	NSString *subject;
	NSString *eventDesc;
	//NSNumber startTime;
	NSString *startTime;
	NSString *uid;
	NSInteger meetingStatus;
	NSInteger disallowNewTimeProposal;
	NSInteger responseRequested;
	//NSNumber appointmentReplyTime;
	NSString *appointmentReplyTime;
	NSInteger responseType;
	//NSNumber calRecurrenceId;
	NSString *calRecurrenceId;
	NSInteger isException;
	NSInteger deleted;
	NSString *picturePath;
	NSString *voicePath;
	NSString *noteId;
	NSString *memo;
	NSInteger reminderDismiss;
	//NSNumber reminderStartTime;
	NSString *reminderStartTime;
	//NSNumber serverId;
	NSString *serverId;
	NSInteger calType;
	//NSNumber syncId;
	NSString *syncId;
	NSInteger syncStatus;
	NSString *eventIcon;
}

//@property (nonatomic) NSUInteger calendarId;
@property (nonatomic, retain) NSString *calendarId;
//@property (nonatomic) NSUInteger userId;
@property (nonatomic, retain) NSString *userId;
//@property (nonatomic) NSNumber folderId;
@property (nonatomic, retain) NSString *folderId;
//@property (nonatomic) NSNumber lastWrite;
@property (nonatomic, retain) NSString *lastWrite;
@property (nonatomic)NSInteger isSynced;
@property (nonatomic)NSInteger status;
@property (nonatomic)NSInteger needSync;
@property (nonatomic)NSInteger timeZone;
@property (nonatomic)NSInteger allDayEvent;
@property (nonatomic)NSInteger busyStatus;
@property (nonatomic, retain) NSString *organizerName;
@property (nonatomic, retain) NSString *organizerEmail;
//@property (nonatomic) NSNumber dtStamp;
@property (nonatomic, retain) NSString *dtStamp;
//@property (nonatomic) NSNumber endTime;
@property (nonatomic, retain) NSString *endTime;
@property (nonatomic, retain) NSString *location;
@property (nonatomic)NSInteger reminder;
@property (nonatomic)NSInteger sensitivity;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *eventDesc;
//@property (nonatomic) NSNumber startTime;
@property (nonatomic, retain) NSString *startTime;
@property (nonatomic, retain) NSString *uid;
@property (nonatomic)NSInteger meetingStatus;
@property (nonatomic)NSInteger disallowNewTimeProposal;
@property (nonatomic)NSInteger responseRequested;
//@property (nonatomic) NSNumber appointmentReplyTime;
@property (nonatomic, retain) NSString *appointmentReplyTime;
@property (nonatomic)NSInteger responseType;
//@property (nonatomic) NSNumber calRecurrenceId;
@property (nonatomic, retain) NSString *calRecurrenceId;
@property (nonatomic)NSInteger isException;
@property (nonatomic)NSInteger deleted;
@property (nonatomic, retain) NSString *picturePath;
@property (nonatomic, retain) NSString *voicePath;
@property (nonatomic, retain) NSString *noteId;
@property (nonatomic, retain) NSString *memo;
@property (nonatomic)NSInteger reminderDismiss;
//@property (nonatomic) NSNumber reminderStartTime;
@property (nonatomic, retain) NSString *reminderStartTime;
//@property (nonatomic) NSNumber serverId;
@property (nonatomic, retain) NSString *serverId;
@property (nonatomic) NSInteger calType;
//@property (nonatomic) NSNumber syncId;
@property (nonatomic, retain) NSString *syncId;
@property NSInteger syncStatus;
@property (nonatomic,retain) NSString *eventIcon;

- (id)initWithEventId:(NSString *)cId database:(sqlite3 *)db;
- (id)initWithServerId:(NSString *)sId database:(sqlite3 *)db;
- (BOOL) insTodoEventDatabase:(sqlite3 *)db;
- (BOOL) updTodoEventByServerId:(NSString *)iServerId Database:(sqlite3 *)db;
@end
