//
//  URLXmlConnection.m
//  Music01
//
//  Created by albert on 2009/8/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "URLXmlConnection.h"
#import "URLCacheAlert.h"

@implementation URLXmlConnection

@synthesize delegate;
@synthesize receivedData;
@synthesize rowIndex;
@synthesize idArgs;

//- (id) initWithURL:(NSURL *)theURL delegate:(id<URLXmlConnectionDelegate>)theDelegate atIndex:(NSIndexPath *)index
- (id) initWithURL:(NSURL *)theURL delegate:(id<URLXmlConnectionDelegate>)theDelegate atIndex:(id)index
{
	if (self = [super init]) {
		
		self.delegate = theDelegate;
		//self.rowIndex = index;
		self.idArgs = index;
		
		NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
													cachePolicy:NSURLRequestUseProtocolCachePolicy 
												timeoutInterval:60];
				
		NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:theRequest 
																	  delegate:self 
															  startImmediately:YES] autorelease];
		if (connection == nil) {
			/* inform the user that the connection failed */
			NSString *message = NSLocalizedString (@"Unable to initiate request.", 
												   @"NSURLConnection initialization method failed.");
			URLCacheAlertWithMessage(message);
		}
	}
	
	return self;
}

- (void)dealloc
{
	[rowIndex release];
	[idArgs release];	
	[receivedData release];
	[super dealloc];
}

#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how the connection object,
// which is working in the background, can asynchronously communicate back to its delegate on the thread from which it was
// started - in this case, the main thread.

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
    self.receivedData = [NSMutableData data];
	
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    /* Append the new data to the received data. */
    [self.receivedData appendData:data];
}


- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	//URLCacheAlertWithError(error);
	[self.delegate xmlConnectionDidFail:self atIndex:rowIndex];
	//[connection release];
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.delegate xmlConnectionDidFinish:self recData:self.receivedData atIndex:idArgs];
	//[self.delegate xmlConnectionDidFinish:self recData:self.receivedData atIndex:rowIndex];
	//[connection release];
}


@end
