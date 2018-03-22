#import "HTTPSHelper.h"

#define CALLBACK(X, Y) if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(X)]) [sharedInstance.delegate performSelector:@selector(X) withObject:Y];
#define NUMBER(X) [NSNumber numberWithFloat:X]

static HTTPSHelper *sharedInstance = nil;

@implementation HTTPSHelper

@synthesize response;
@synthesize data;
@synthesize delegate;
@synthesize urlString;
@synthesize urlConnection;
@synthesize isGoing;
@synthesize requestXML;



- (void) start
{
	self.isGoing = NO;
	
	NSURL *url = [NSURL URLWithString:self.urlString];
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
	
	[postRequest setHTTPMethod:@"POST"];
	[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	[postRequest setHTTPBody:[[[NSData alloc] initWithData:[self.requestXML dataUsingEncoding:NSUTF8StringEncoding]]autorelease]];
	
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
	if (!self.urlConnection)
	{
		NSString *reason = [NSString stringWithFormat:@"can't get connection from url which is %@", self.urlString];
		CALLBACK(dataReceiveFailed:, reason);
		return;
	}
	
	self.isGoing = YES;
	
	// Create the new data object
	self.data = [NSMutableData data];
	self.response = nil;
	
	[self.urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) cleanup
{
	self.requestXML = nil;
	self.data = nil;
	self.response = nil;
	self.urlConnection = nil;
	self.urlString = nil;
	self.isGoing = NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
	
	self.response = aResponse;
	
	if ([aResponse expectedContentLength] < 0)
	{
		NSString *reason = [NSString stringWithFormat:@"No data from URL [%@]", self.urlString];
		CALLBACK(dataReceiveFailed:, reason);
		[connection cancel];
		[self cleanup];
		return;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
	[self.data appendData:theData];
	if (self.response)
	{
		float expectedLength = [self.response expectedContentLength];
		float currentLength = self.data.length;
		float percent = currentLength / expectedLength;
		CALLBACK(dataReceiveAtPercent:, NUMBER(percent));
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
		
	if (self.delegate)
	{
		NSMutableDictionary *theDictionary = [[NSMutableDictionary alloc]init];
		
		NSDictionary *header=[(NSHTTPURLResponse *)self.response allHeaderFields];
		
		DoLog(INFO,@"header=%@",header);
		
		NSEnumerator *enumerator = [header keyEnumerator];
		id key;
		while ((key = [enumerator nextObject])) {
			[theDictionary setValue:[header objectForKey:key] forKey:key];
		}
	
		[theDictionary setValue:[self.data retain] forKey:@"returnData"];
		[theDictionary setValue:[NSString stringWithFormat:@"%d",((NSHTTPURLResponse *)self.response).statusCode] forKey:@"returnCode"];
		CALLBACK(didReceiveData:, theDictionary);
	}
	
	[self.urlConnection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[self cleanup];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	self.isGoing = NO;
	CALLBACK(dataDownloadFailed:, error);
	[self cleanup];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace { 
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]; 
} 

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	DoLog(DEBUG,@"%@",challenge.protectionSpace.host);
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) 
		//if ([trustedHosts containsObject:challenge.protectionSpace.host]) 
		[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge]; 
	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge]; 
} 

+ (HTTPSHelper *) sharedInstance
{
	if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

+ (void) go:(NSString *) aURLString
{
	if (sharedInstance.isGoing)
	{
		CALLBACK(dataReceiveFailed:, @"still running");
		return;
	}
	
	sharedInstance.urlString = aURLString;
	[sharedInstance start];
}

+ (void) cancel
{
	if (sharedInstance.isGoing) [sharedInstance.urlConnection cancel];
	[sharedInstance cleanup];
}


@end
