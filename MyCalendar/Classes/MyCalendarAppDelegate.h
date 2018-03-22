//
//  MyCalendarAppDelegate.h
//  MyCalendar
//
//  Created by yves ho on 2010/2/28.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "SyncOperation.h"
@class LoginViewController;

@interface MyCalendarAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UITabBarController *rootController;
	sqlite3 *database;
	SyncOperation *syncOperation;
	NSOperationQueue *operationQueue;
	NSTimer *syncTimer;
	//NSTimer *chkTimer;
	BOOL syncStatus;
	NSDate *syncDate;
	LoginViewController *loginController;
	NSDictionary *versionInfo;
	//NSInteger statusFlag;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *rootController;
@property (nonatomic) sqlite3 *database;
@property (retain) SyncOperation *syncOperation;
@property (retain) NSOperationQueue *operationQueue;
@property (retain) NSTimer *syncTimer;
//@property (retain) NSTimer *chkTimer;
@property BOOL syncStatus;
@property (retain) NSDate *syncDate;
@property (nonatomic, retain) IBOutlet LoginViewController *loginController;
@property (nonatomic, retain) NSDictionary *versionInfo;
//@property NSInteger statusFlag;

//+(BOOL) getSyncStatus;
//+(void) setSyncStatus:(BOOL)flag;
  
-(void) handleTimer1:(BOOL)flag;
//-(void) handleTimer2:(BOOL)flag;
-(void) chkBackupRestore;
-(void) doneSyncing:(NSString *)isStop;

-(void) initData:(UIApplication *)application;
-(void) doFeedback:(NSString *)calendarId;
-(void) sendDeviceToken:(NSString *)deviceToken;


@end

