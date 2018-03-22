//
//  URLXmlConnection.h
//  Music01
//
//  Created by albert on 2009/8/6.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol URLXmlConnectionDelegate;

@interface URLXmlConnection : NSObject {
	id <URLXmlConnectionDelegate>		delegate;
	NSMutableData						*receivedData;
	NSIndexPath							*rowIndex;
	id									idArgs;
}

@property (nonatomic, assign) id				delegate;
@property (nonatomic, retain) NSMutableData		*receivedData;
@property (nonatomic, retain) NSIndexPath		*rowIndex;
@property (nonatomic, retain) id				idArgs;

//- (id) initWithURL:(NSURL *)theURL delegate:(id<URLXmlConnectionDelegate>)theDelegate atIndex:(NSIndexPath *)index;
- (id) initWithURL:(NSURL *)theURL delegate:(id<URLXmlConnectionDelegate>)theDelegate atIndex:(id)index;
@end

@protocol URLXmlConnectionDelegate<NSObject>

- (void) xmlConnectionDidFail:(URLXmlConnection *)theConnection atIndex:(NSIndexPath *)index;
//- (void) xmlConnectionDidFinish:(URLXmlConnection *)theConnection recData:(NSMutableData *)theData atIndex:(NSIndexPath *)index;
- (void) xmlConnectionDidFinish:(URLXmlConnection *)theConnection recData:(NSMutableData *)theData atIndex:(id)index;
//- (void) xmlConnectionDidFinish:(URLXmlConnection *)theConnection recData:(NSMutableData *)theData withArgs:(id)args;

@end