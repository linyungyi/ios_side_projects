//
//  RuleArray.h
//  MyCalendar
//
//  Created by Admin on 2010/3/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RuleArray : NSObject {
	NSArray *keepRule1;
	NSArray *keepRule2;
	NSArray *syncRule1;
	NSArray *syncRule2;
	NSArray *redoRule1;
	NSArray *redoRule2;
	NSArray *redoRule3;
	NSArray *autoRule1;
	NSArray *autoRule2;
	NSArray *notifyRule1;
	NSArray *notifyRule2;
}

@property (nonatomic,retain) NSArray *keepRule1;
@property (nonatomic,retain) NSArray *keepRule2;
@property (nonatomic,retain) NSArray *syncRule1;
@property (nonatomic,retain) NSArray *syncRule2;
@property (nonatomic,retain) NSArray *redoRule1;
@property (nonatomic,retain) NSArray *redoRule2;
@property (nonatomic,retain) NSArray *redoRule3;
@property (nonatomic,retain) NSArray *autoRule1;
@property (nonatomic,retain) NSArray *autoRule2;
@property (nonatomic,retain) NSArray *notifyRule1;
@property (nonatomic,retain) NSArray *notifyRule2;

-(NSInteger) getSyncRowNo:(NSString *) value;
-(NSInteger) getKeepRowNo:(NSInteger) value;
-(NSInteger) getRedoRowNo:(NSInteger) value;
-(NSInteger) getAutoRowNo:(NSInteger) value;
-(NSInteger) getNotifyRowNo:(NSInteger) value;

+(NSString *) getColorDictionary:(NSInteger)key;
+(NSArray *) getColorArray;

+(NSString *) getEventIcon:(NSInteger)key;
+(NSArray *) getEventIconArray;

@end
