//
//  CustomCell.h
//  Music01
//
//  Created by albert on 2009/6/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCustomCell.h"

@interface CustomCell : BaseCustomCell {
	int viewStyle;
}
@property int viewStyle;

-(id)initWithViewStyle:(int)style;
@end
