//
//  Style3CustomCel.m
//  Music01
//
//  Created by albert on 2009/6/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Style3CustomCell.h"


@implementation Style3CustomCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		self.accessoryType = UITableViewCellAccessoryNone;
        // Initialization code
    }
    return self;
}


@end
