

#import "AlbumImgConnection.h"


@implementation AlbumImgConnection

@synthesize delegate;
@synthesize receivedData;
@synthesize lastModified;
@synthesize connectType;


/* This method initiates the load request. The connection is asynchronous, 
 and we implement a set of delegate methods that act as callbacks during 
 the load. */

- (id) initWithURL:(NSURL *)theURL delegate:(id<AlbumImgConnectionDelegate>)theDelegate connectType:(NSString *)theConnectType    
{
	if (self = [super init]) {

		self.delegate = theDelegate;
		self.connectType=theConnectType;
		/* Create the request. This application does not use a NSAlbumImg 
		 disk or memory cache, so our cache policy is to satisfy the request
		 by loading the data from its source. */
		NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
													cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
												timeoutInterval:60];
		
		/* create the NSMutableData instance that will hold the received data */
		receivedData = [[NSMutableData alloc] initWithLength:0];

		/* Create the connection with the request and start loading the
		 data. The connection object is owned both by the creator and the
		 loading system. */
			
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:theRequest 
																	  delegate:self 
															  startImmediately:YES];
		if (connection == nil) {
		}
	}

	return self;
}


- (void)dealloc
{
	[receivedData release];
	[lastModified release];
	[super dealloc];
}


#pragma mark NSURLConnection delegate methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /* This method is called when the server has determined that it has
	 enough information to create the NSURLResponse. It can be called
	 multiple times, for example in the case of a redirect, so each time
	 we reset the data. */
	
    [self.receivedData setLength:0];
	
	/* Try to retrieve last modified date from HTTP header. If found, format  
	 date so it matches format of cached image file modification date. */
	/*if ([response isKindOfClass:[NSHTTPURLResponse self]]) {
		NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
		NSString *modified = [headers objectForKey:@"Last-Modified"];
		if (modified) {
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
			self.lastModified = [dateFormatter dateFromString:modified];
			[dateFormatter release];
		}
		else {
			self.lastModified = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
		}
	}*/
}


- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    /* Append the new data to the received data. */
    [self.receivedData appendData:data];
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self.delegate connectionDidFail:self];
	[connection release];
}


- (NSCachedURLResponse *) connection:(NSURLConnection *)connection 
				   willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	/* this application does not use a NSAlbumImg disk or memory cache */
    return nil;
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.delegate connectionDidFinish:self];
	[connection release];
}


@end
