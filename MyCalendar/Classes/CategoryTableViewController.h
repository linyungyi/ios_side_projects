//
//  CategoryTableViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MySqlite;

@interface CategoryTableViewController : UITableViewController {
	NSInteger flag;
    NSArray *categorys;
	NSArray *todoEvent;
}

@property (nonatomic) NSInteger flag;
@property (nonatomic, retain) NSArray *categorys;
@property (nonatomic, retain) NSArray *todoEvent;

- (UIImage *) createFolderImage:(CGSize) mySize bgColor:(NSInteger) myColor;
-(void) addCategory:(id)sender;

@end
