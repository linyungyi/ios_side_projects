//
//  SyncErrorCode.m
//  MyCalendar
//
//  Created by app on 2010/4/2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SyncErrorCode.h"
@implementation SyncErrorCode
@synthesize SYNC_SUCCESS;//成功
@synthesize SYNC_HTTP_FAIL;//http result!=200
@synthesize SYNC_RESULT_FAIL;//xml result code !=0
@synthesize SYNC_RES_ADD_FAIL_2;//新增失敗
@synthesize SYNC_RES_ADD_FAIL_3;//新增永久性失敗
@synthesize SYNC_RES_ADD_FAIL_O;//新增其他錯誤
@synthesize SYNC_RES_UPD_FAIL_2;//新增失敗
@synthesize SYNC_RES_UPD_FAIL_3;//新增永久性失敗
@synthesize SYNC_RES_UPD_FAIL_O;//新增其他錯誤
@synthesize SYNC_RES_DEL_FAIL_2;//新增失敗
@synthesize SYNC_RES_DEL_FAIL_3;//新增永久性失敗
@synthesize SYNC_RES_DEL_FAIL_O;//新增其他錯誤
@synthesize SYNC_REQ_ADD_FAIL;//新增失敗
@synthesize SYNC_REQ_UPD_FAIL;//新增永久性失敗
@synthesize SYNC_REQ_DEL_FAIL;//新增其他錯誤
@synthesize SYNC_SYNCSEQ_FAIL;//取得sync_seq失敗
@synthesize SYNC_ROOP_LIMIT;//限制回圈內無法取得ack
@synthesize SYNC_USER_STOP;//使用者取消同步動作
@synthesize SYNC_RESTORE_DEL_FAIL;//還原動作刪除資料庫錯誤
@synthesize errorStr;
- (id)init{
	if (self = [super init]) {
		self.SYNC_SUCCESS =				0		;//成功
		self.SYNC_HTTP_FAIL =			1 		;//http result!=200
		self.SYNC_RESULT_FAIL = 		2 		;//xml result code !=0
		self.SYNC_RES_ADD_FAIL_2 = 		4 		;//新增失敗
		self.SYNC_RES_ADD_FAIL_3 =		8 		;//新增永久性失敗
		self.SYNC_RES_ADD_FAIL_O =		16		;//新增其他錯誤
		self.SYNC_RES_UPD_FAIL_2 =		32 		;//新增失敗
		self.SYNC_RES_UPD_FAIL_3 =		64 		;//新增永久性失敗
		self.SYNC_RES_UPD_FAIL_O =		128		;//新增其他錯誤
		self.SYNC_RES_DEL_FAIL_2 =		256 	;//新增失敗
		self.SYNC_RES_DEL_FAIL_3 =		512 	;//新增永久性失敗
		self.SYNC_RES_DEL_FAIL_O =		1024	;//新增其他錯誤
		self.SYNC_REQ_ADD_FAIL =		2048	;//新增失敗
		self.SYNC_REQ_UPD_FAIL =		4096	;//新增永久性失敗
		self.SYNC_REQ_DEL_FAIL =		8192	;//新增其他錯誤
		self.SYNC_SYNCSEQ_FAIL =		16384	;//取得sync_seq失敗
		self.SYNC_ROOP_LIMIT =			32768	;//限制回圈內無法取得ack
		self.SYNC_USER_STOP =			65536	;//使用者取消同步動作
		self.SYNC_RESTORE_DEL_FAIL =	131072	;//還原動作刪除資料庫錯誤
		
		NSArray *myArray = [[NSArray alloc]initWithObjects:
							//@"成功",
							@"http result!=200",
							@"xml result code !=0",
							@"回應新增失敗",
							@"回應新增永久性失敗",
							@"回應新增其他錯誤",
							@"回應修改失敗",
							@"回應修改永久性失敗",
							@"回應修改其他錯誤",
							@"回應刪除失敗",
							@"回應刪除永久性失敗",
							@"回應刪除其他錯誤",
							@"請求新增失敗",
							@"請求修改失敗",
							@"請求刪除失敗",
							@"取得sync_seq失敗",
							@"限制回圈內無法取得ack",
							@"使用者取消同步動作",
							@"還原動作刪除資料庫錯誤",
							nil];
		self.errorStr=myArray;
		[myArray release];
	}
	return self;
}
- (NSString *)getErrorStringFromCode:(NSInteger)iCode{
	NSMutableString *str = [NSMutableString string];
	NSInteger numberCopy = iCode; // so you won't change your original value
	if(iCode == 0){
		str=[[NSMutableString alloc]initWithString:@"[成功]"];
	}else{
		for(NSInteger i = 0; i < [self.errorStr count] ; i++) {
			if((numberCopy & 1) == 1){
				[str appendFormat:@"[%@]",[self.errorStr objectAtIndex:i]];
			}
			numberCopy >>= 1;
		}
	}
	return str;
}

- (void) dealloc{
	[errorStr release];
	[super dealloc];
}
@end
