//
//  SyncViewController.h
//  MyCalendar
//
//  Created by yves ho on 2010/2/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncOperation.h"
#import "ServiceUtil.h"

@interface SyncViewController : UIViewController <SyncOperationDelegate,UIActionSheetDelegate>{
	UILabel *contentLabel;
	UIView *defaultView;
	UIView *contentView;
	UIActivityIndicatorView *myActivityIndicatorView;
	NSInteger syncFlag;
	SyncOperation *syncOperation;
	NSMutableString *backupStatus;//0:未起動 1:執行中 2:取消
	NSMutableString *restoreStatus;//0:未起動 1:執行中 2:取消
	//BOOL enableBackup;
	//BOOL enableRestore;
	NSTimer *chkSyncTimer;
	NSMutableArray *backupLogs;
	UIProgressView *myProgressView;
	
	//UINavigationBar *defaultBar;
	//UINavigationBar *contentBar;
	
	ServiceUtil *serviceUtil;
}

@property (nonatomic,retain) IBOutlet UILabel *contentLabel;
@property (nonatomic,retain) IBOutlet UIView *defaultView;
@property (nonatomic,retain) IBOutlet UIView *contentView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *myActivityIndicatorView;
@property NSInteger syncFlag;
@property (retain) NSMutableString *backupStatus;
@property (retain) NSMutableString *restoreStatus;
@property (retain) SyncOperation *syncOperation;
//@property BOOL enableBackup;
//@property BOOL enableRestore;
@property (retain) NSTimer *chkSyncTimer;
@property (retain) NSMutableArray *backupLogs;
@property (nonatomic,retain) IBOutlet UIProgressView *myProgressView;

//@property (nonatomic,retain) IBOutlet UINavigationBar *defaultBar;
//@property (nonatomic,retain) IBOutlet UINavigationBar *contentBar;

@property (nonatomic,retain) ServiceUtil *serviceUtil;

-(IBAction) doSync:(id)sender;
-(IBAction) stopSync:(id)sneder;
-(IBAction) doBackup:(id)sender;
-(IBAction) doRestore:(id)sender;

-(void) doneSync;
-(void) startBackup:(NSMutableString *)bflag;
-(void) startRestore:(NSString *)bId;
-(void) queryBackupLog;
-(void) updProcess:(NSString *)p;

@end
