//
//  TodoCategory.h
//  MyCalendar
//
//  Created by Admin on 2010/3/2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface TodoCategory : NSObject {
	//NSUInteger folderId;
	NSString *folderId;
	NSString *folderName;
	NSInteger colorRgb;
	NSInteger displayFlag;
	NSInteger stateFlag;
	NSInteger syncFlag;
	//NSUInteger lastimeSync;
	NSString *lastimeSync;
	
	NSString *createdDatetime;
	NSString *modifiedDatetime;
	//NSUInteger createdDatetime;
	//NSUInteger modifiedDatetime;
	NSString *photoPath;
	NSString *memo;
	//NSNumber userId;
	NSString *userId;
	//NSNumber serverId;
	NSString *serverId;
	
	NSInteger folderType;
	NSInteger syncStatus;
}

//@property (nonatomic) NSUInteger folderId;
@property (nonatomic, retain) NSString *folderId;
@property (nonatomic, retain) NSString *folderName;
@property (nonatomic) NSInteger colorRgb;
@property (nonatomic) NSInteger displayFlag;
@property (nonatomic) NSInteger stateFlag;
@property (nonatomic) NSInteger syncFlag;
//@property (nonatomic) NSUInteger lastimeSync;
@property (nonatomic, retain) NSString *lastimeSync;

//@property (nonatomic) NSUInteger createdDatetime;
@property (nonatomic, retain) NSString *createdDatetime;
//@property (nonatomic) NSUInteger modifiedDatetime;
@property (nonatomic, retain) NSString *modifiedDatetime;
@property (nonatomic, retain) NSString *photoPath;
@property (nonatomic, retain) NSString *memo;
//@property (nonatomic) NSNumber userId;
@property (nonatomic, retain) NSString *userId;
//@property (nonatomic) NSNumber serverId;
@property (nonatomic, retain) NSString *serverId;

@property (nonatomic) NSInteger folderType;
@property NSInteger syncStatus;

- (id)initWithCategoryId:(NSString *)fId database:(sqlite3 *)db;
- (id)initWithCategoryServerId:(NSString *)sId database:(sqlite3 *)db;
@end

