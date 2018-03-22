//
//  EventRecurrence.h
//  MyCalendar
//
//  Created by Admin on 2010/3/2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface EventRecurrence : NSObject {
	//NSUInteger calendarId;
	NSString *calendarId;
	NSInteger type;
	NSInteger occurrences;
	NSInteger interval;
	NSInteger weekOfMonth;
	NSInteger dayOfWeek;
	NSInteger monthOfYear;
	//NSNumber until;
	NSString *until;
	NSInteger dayOfMonth;
	//NSNumber start;
	NSString *start;
	//NSNumber folderId;
	NSString *folderId;
}

//@property (nonatomic) NSUInteger calendarId;
@property (nonatomic, retain) NSString *calendarId;
@property (nonatomic) NSInteger type;
@property (nonatomic) NSInteger occurrences;
@property (nonatomic) NSInteger interval;
@property (nonatomic) NSInteger weekOfMonth;
@property (nonatomic) NSInteger dayOfWeek;
@property (nonatomic) NSInteger monthOfYear;
//@property (nonatomic) NSNumber until;
@property (nonatomic, retain) NSString *until;
@property (nonatomic) NSInteger dayOfMonth;
//@property (nonatomic) NSNumber start;
@property (nonatomic, retain) NSString *start;
//@property (nonatomic) NSNumber folderId;
@property (nonatomic, retain) NSString *folderId;

- (id)initWithId:(NSString *)cId database:(sqlite3 *)db;
- (BOOL) insEventRecurrenceDatabase:(sqlite3 *)db;

@end

