#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "MySqlite.h"
#import	"SyncErrorCode.h"

@protocol SyncOperationDelegate <NSObject>
- (void) doneSyncing: (NSString *) status;
- (void) setProgress: (NSString *) p;
@end

@interface SyncOperation : NSOperation 
{
	id <SyncOperationDelegate> delegate;
	BOOL stopFlag;
	SyncErrorCode *errorFlag;
}

@property (retain) id delegate;
@property (assign) BOOL stopFlag;
@property (nonatomic,retain) SyncErrorCode *errorFlag;

-(NSInteger) doFolderSync:(MySqlite *)mySqlite seq:(NSInteger)sId;
//-(BOOL) doContentSync:(sqlite3 *)database seq:(NSInteger)sId;

-(NSDictionary *) getSyncSeq:(sqlite3 *)database;
-(BOOL) updSyncSeq:(sqlite3 *)database sequence:(NSInteger) syncSeq session:(NSInteger) sessionSeq result:(NSInteger)status;
-(BOOL) updSyncSeq:(sqlite3 *) database syncRange:(NSString*) syncRange sequence:(NSInteger) syncSeq session:(NSInteger) sessionSeq result:(NSInteger)status;
//-(BOOL) resetSyncSeq:(sqlite3 *)database;
-(NSInteger) getCountsOfSyncLog:(sqlite3 *) database;
- (TodoCategory *) getCategoryByServerId:(NSString *) serverId db:(sqlite3 *)database;

-(NSInteger) doContentSync:(MySqlite *)database seq:(NSInteger)sId;
- (NSData *) setContentRequest:(NSArray *) iPkArray setContentResponse:(NSMutableData *)iRespData respCount:(NSInteger)respCount syncSeq:(NSInteger)syncSeq sessionSeq:(NSInteger)sessionSeq hasMore:(BOOL)hasMoreDataClient newSyncRange:(NSString *)newSyncRange oldSyncRange:(NSString *)oldSyncRange database:(MySqlite *)mySqlite;
-(NSInteger) doRecurrenceSync:(MySqlite *)mySqlite seq:(NSInteger)sId;
- (NSData *) setRecurrenceRequest:(NSArray *) iPkArray setContentResponse:(NSMutableData *)iRespData respCount:(NSInteger)respCount syncSeq:(NSInteger)syncSeq sessionSeq:(NSInteger)sessionSeq hasMore:(BOOL)hasMoreDataClient database:(MySqlite *)mySqlite;
-(NSInteger) doInitSync:(MySqlite *)mySqlite;
-(NSInteger) doRestore:(MySqlite *)mySqlite;

@end
