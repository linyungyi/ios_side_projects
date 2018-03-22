//
//  MyNavigationBar.m
//  MyCalendar
//
//  Created by Admin on 2010/4/30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyNavigationBar.h"

@implementation UINavigationBar (CustomImage) 
- (void)drawRect:(CGRect)rect { 
    UIImage *image = [UIImage imageNamed: @"calen_head.png"]; 
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)]; 
} 
@end 

