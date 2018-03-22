//
//  SyncErrorCode.h
//  MyCalendar
//
//  Created by app on 2010/4/2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SyncErrorCode : NSObject {
	NSInteger SYNC_SUCCESS;//成功
	NSInteger SYNC_HTTP_FAIL;//http result!=200
	NSInteger SYNC_RESULT_FAIL;//xml result code !=0
	NSInteger SYNC_RES_ADD_FAIL_2;//回應新增失敗
	NSInteger SYNC_RES_ADD_FAIL_3;//回應新增永久性失敗
	NSInteger SYNC_RES_ADD_FAIL_O;//回應新增其他錯誤
	NSInteger SYNC_RES_UPD_FAIL_2;//回應修改失敗
	NSInteger SYNC_RES_UPD_FAIL_3;//回應修改永久性失敗
	NSInteger SYNC_RES_UPD_FAIL_O;//回應修改其他錯誤
	NSInteger SYNC_RES_DEL_FAIL_2;//回應刪除失敗
	NSInteger SYNC_RES_DEL_FAIL_3;//回應刪除永久性失敗
	NSInteger SYNC_RES_DEL_FAIL_O;//回應刪除其他錯誤
	NSInteger SYNC_REQ_ADD_FAIL;//請求新增失敗
	NSInteger SYNC_REQ_UPD_FAIL;//請求修改失敗
	NSInteger SYNC_REQ_DEL_FAIL;//請求刪除失敗
	NSInteger SYNC_SYNCSEQ_FAIL;//取得sync_seq失敗
	NSInteger SYNC_ROOP_LIMIT;//限制回圈內無法取得ack
	NSInteger SYNC_USER_STOP;//使用者取消同步動作
	NSInteger SYNC_RESTORE_DEL_FAIL;//還原動作刪除資料庫錯誤
	NSArray	*errorStr;
}
@property(nonatomic) NSInteger SYNC_SUCCESS;//成功
@property(nonatomic) NSInteger SYNC_HTTP_FAIL;//http result!=200
@property(nonatomic) NSInteger SYNC_RESULT_FAIL;//xml result code !=0
@property(nonatomic) NSInteger SYNC_RES_ADD_FAIL_2;//新增失敗
@property(nonatomic) NSInteger SYNC_RES_ADD_FAIL_3;//新增永久性失敗
@property(nonatomic) NSInteger SYNC_RES_ADD_FAIL_O;//新增其他錯誤
@property(nonatomic) NSInteger SYNC_RES_UPD_FAIL_2;//新增失敗
@property(nonatomic) NSInteger SYNC_RES_UPD_FAIL_3;//新增永久性失敗
@property(nonatomic) NSInteger SYNC_RES_UPD_FAIL_O;//新增其他錯誤
@property(nonatomic) NSInteger SYNC_RES_DEL_FAIL_2;//新增失敗
@property(nonatomic) NSInteger SYNC_RES_DEL_FAIL_3;//新增永久性失敗
@property(nonatomic) NSInteger SYNC_RES_DEL_FAIL_O;//新增其他錯誤
@property(nonatomic) NSInteger SYNC_REQ_ADD_FAIL;//新增失敗
@property(nonatomic) NSInteger SYNC_REQ_UPD_FAIL;//新增永久性失敗
@property(nonatomic) NSInteger SYNC_REQ_DEL_FAIL;//新增其他錯誤
@property(nonatomic) NSInteger SYNC_SYNCSEQ_FAIL;//取得sync_seq失敗
@property(nonatomic) NSInteger SYNC_ROOP_LIMIT;//限制回圈內無法取得ack
@property(nonatomic) NSInteger SYNC_USER_STOP;//使用者取消同步動作
@property(nonatomic) NSInteger SYNC_RESTORE_DEL_FAIL;//還原動作刪除資料庫錯誤
@property(nonatomic,retain) NSArray	*errorStr;

- (NSString *)getErrorStringFromCode:(NSInteger)iCode;
@end
