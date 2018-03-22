//
//  SyncDetailViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SyncDetailViewController : UITableViewController {
	NSArray *syncDatas;
}
@property (nonatomic, retain) NSArray *syncDatas;

@end
