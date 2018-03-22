//
//  ServiceUtil.h
//  MyCalendar
//
//  Created by Admin on 2010/4/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncOperation.h"

@interface ServiceUtil : NSObject <SyncOperationDelegate>{
	NSInteger stateFlag;
	NSInteger jobFlag;
	NSInteger resultFlag;
	//id myDelegate;
	//UIView *syncView;
	//UIProgressView *myProgressView;
	SyncOperation *syncOperation;
}

@property NSInteger stateFlag;
@property NSInteger jobFlag;
@property NSInteger resultFlag;

//@property (nonatomic,retain) id myDelegate;
//@property (nonatomic,retain) UIView *syncView;
//@property (nonatomic,retain) UIProgressView *myProgressView;
@property (retain) SyncOperation *syncOperation;

-(BOOL) chkResultCode:(NSInteger) resultCode;
-(void) doProvision:(NSString *)p;
@end
