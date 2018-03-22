//
//  EventIconViewController.h
//  MyCalendar
//
//  Created by yvesho on 2010/5/8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EventIconViewController : UIViewController <UIScrollViewDelegate>{
	UIScrollView *sv;
	NSArray *viewDatas;
	NSArray *todoEvent;
	NSInteger selIndex;
	NSInteger currIndex;
}

@property (nonatomic,retain) UIScrollView *sv;
@property (nonatomic,retain) NSArray *viewDatas;
@property (nonatomic, retain) NSArray *todoEvent;
@property (nonatomic) NSInteger selIndex;
@property (nonatomic) NSInteger currIndex;

-(void) chooseIcon:(UIButton *)sender;
-(void) doJob;

@end
