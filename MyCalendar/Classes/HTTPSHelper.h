#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HTTPSHelperDelegate <NSObject>
@optional
- (void) didReceiveData: (NSData *) theData;
- (void) dataReceiveFailed: (NSString *) reason;
- (void) dataReceiveAtPercent: (NSNumber *) aPercent;
@end

@interface HTTPSHelper : NSObject 
{
	NSURLResponse *response;
	NSMutableData *data;
	NSString *urlString;
	NSURLConnection *urlConnection;
	id <HTTPSHelperDelegate> delegate;
	BOOL isGoing;
	NSString *requestXML;
	
}
@property (retain) NSURLResponse *response;
@property (retain) NSURLConnection *urlConnection;
@property (retain) NSMutableData *data;
@property (retain) NSString *urlString;
@property (retain) id delegate;
@property (assign) BOOL isGoing;
@property (retain) NSString *requestXML;


+ (HTTPSHelper *) sharedInstance;
+ (void) go:(NSString *) aURLString;
+ (void) cancel;
@end
