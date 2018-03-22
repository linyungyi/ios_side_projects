//
//  MemoTextViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MemoTextViewController : UIViewController <UITextViewDelegate>{
	UITextView *contentView;
	NSArray *todoEvent;
}
@property (nonatomic, retain) NSArray *todoEvent;

@end
