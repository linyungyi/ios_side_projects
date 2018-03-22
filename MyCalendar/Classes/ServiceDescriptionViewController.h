//
//  ServiceDescriptionViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/4/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ServiceDescriptionViewController : UIViewController <UIScrollViewDelegate>{
	UIScrollView *sv;
}
@property (nonatomic,retain) UIScrollView *sv;

@end
