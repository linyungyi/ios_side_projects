//
//  ProfileUtil.h
//  MyCalendar
//
//  Created by yves ho on 2010/4/4.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProfileUtil : NSObject {

}

+(BOOL) setBool:(BOOL)value forKey:(NSString *) key;
+(BOOL) setInteger:(NSInteger)value forKey:(NSString *) key;
+(BOOL) setString:(NSString *)value forKey:(NSString *) key;
+(BOOL) setKeyPair:(NSString *) key value:(NSString *)value;

+(BOOL) boolForKey:(NSString *) key;
+(NSInteger) integerForKey:(NSString *) key;
+(NSString *) stringForKey:(NSString *) key;
+(NSString *) getKeyPair:(NSString *) key;

@end
