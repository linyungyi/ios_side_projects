
#import <UIKit/UIKit.h>

@protocol AlbumImgConnectionDelegate;

@interface AlbumImgConnection : NSObject {
	id <AlbumImgConnectionDelegate>		delegate;
	NSMutableData						*receivedData;
	NSDate								*lastModified;
	NSString							*connectType;
}

@property (nonatomic, assign) id				delegate;
@property (nonatomic, retain) NSMutableData		*receivedData;
@property (nonatomic, retain) NSDate			*lastModified;
@property (nonatomic, retain) NSString			*connectType;

-(id)initWithURL:(NSURL *)theURL delegate:(id<AlbumImgConnectionDelegate>)theDelegate connectType:(NSString *)theConnectType;

@end


@protocol AlbumImgConnectionDelegate<NSObject>

- (void) connectionDidFail:(AlbumImgConnection *)theConnection;
- (void) connectionDidFinish:(AlbumImgConnection *)theConnection;

@end
