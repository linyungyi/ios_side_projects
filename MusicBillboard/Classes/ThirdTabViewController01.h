//
//  ThirdTabViewController01.h
//  Music01
//
//  Created by albert on 2009/6/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class avTouchViewController;

@interface ThirdTabViewController01 : UIViewController  <UITableViewDelegate,UITableViewDataSource>{
	IBOutlet UITableView	*myTableView;
	NSMutableArray			*myTableSection;
	NSMutableArray			*mySectionRow;
	
	avTouchViewController	*avController;
	
}
@property (nonatomic, retain) UITableView				*myTableView;
@property (nonatomic, retain) NSMutableArray			*myTableSection;
@property (nonatomic, retain) NSMutableArray			*mySectionRow;
@property (nonatomic, retain) avTouchViewController		*avController;

-(void)initDataSource;
-(void)setMember:(NSString *)theMember;
@end
