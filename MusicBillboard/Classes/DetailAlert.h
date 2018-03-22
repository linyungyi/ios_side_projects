//
//  TestAlert.h
//  Music01
//
//  Created by bko on 2009/8/27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailAlert : UIView {

	UILabel *mLabel;
}
- (void) setTitle: (NSString *)titleText;
- (void) setMessage: (NSString *)messageText;
- (void) removeView;
- (void) presentView;
@end
