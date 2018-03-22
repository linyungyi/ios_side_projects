//
//  Style2CustomCell.m
//  Music01
//
//  Created by albert on 2009/6/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Style2CustomCell.h"
#import "Constants.h"

@implementation Style2CustomCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		self.accessoryType = UITableViewCellAccessoryNone;
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews{
	[super layoutSubviews];
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGRect frame;
	
	 frame = CGRectMake(boundsX+100, 20, WidthForImage2, HeightForImage2);
	 myImageView.frame =frame;
	 
	 frame = CGRectMake(boundsX+25, 140, WidthForPrimaryLabel2, HeightForPrimaryLabel2);
	 primaryLabel.frame = frame;
	 
	 frame = CGRectMake(boundsX+25, 180, WidthForSecondaryLabel2, HeightForSecondaryLabel2);
	 secondaryLabel.frame = frame;

}

@end
