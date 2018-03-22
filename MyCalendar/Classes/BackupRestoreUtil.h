//
//  BackupRestoreUtil.h
//  MyCalendar
//
//  Created by yves ho on 2010/4/1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BackupRestoreUtil : NSObject {
	
}

+(NSInteger) startBackup;
+(NSInteger) startRestore:(NSString *)bLog;
+(NSMutableDictionary *) getBackupResult:(NSString *)bId;
+(NSMutableDictionary *) getRestoreResult:(NSString *)rId;


@end
