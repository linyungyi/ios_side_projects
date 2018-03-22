//
//  CustomCell.m
//  Music01
//
//  Created by albert on 2009/6/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CustomCell.h"
#import "Constants.h"
#import "Style1CustomCell.h"
#import "Style2CustomCell.h"
#import "Style3CustomCell.h"
#import "Style4CustomCell.h"
#import "Style5CustomCell.h"
#import "Style6CustomCell.h"
#import "Style7CustomCell.h"
#import "Style8CustomCell.h"
#import "Style9CustomCell.h"

@implementation CustomCell
@synthesize viewStyle;
//@synthesize style1CustomCell;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	//NSArray *nib;
	switch (self.viewStyle) {
		case STYLE0:
			self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
			break;
		case STYLE1:
			self = [[Style1CustomCell alloc] initWithFrame:frame reuseIdentifier:reuseIdentifier];
			break;
		case STYLE2:
			self = [[Style2CustomCell alloc] initWithFrame:frame reuseIdentifier:reuseIdentifier];
			break;
		case STYLE3:
			self = [[Style3CustomCell alloc] initWithFrame:frame reuseIdentifier:reuseIdentifier];
			break;
		case STYLE4:
		
			self = [[Style4CustomCell alloc] initWithFrame:frame reuseIdentifier:reuseIdentifier];
			break;
		case STYLE5:
			self = [[Style5CustomCell alloc] initWithFrame:frame reuseIdentifier:reuseIdentifier];
			break;
		case STYLE6:
			self = [[Style6CustomCell alloc] initWithFrame:frame reuseIdentifier:reuseIdentifier];
			break;
		case STYLE7:
			self = [[Style7CustomCell alloc] initWithFrame:frame reuseIdentifier:reuseIdentifier];
			break;
			
		case STYLE8:
			self = [[Style8CustomCell alloc] initWithFrame:frame reuseIdentifier:reuseIdentifier];
			break;
		case STYLE9:
			self = [[Style9CustomCell alloc] initWithFrame:frame reuseIdentifier:reuseIdentifier];
			break;

		default:
			self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
			break;
	}
    return self;
}

-(void)layoutSubviews{

	switch (self.viewStyle) {
		case STYLE0:
			[super layoutSubviews];
			break;
		case STYLE1:
			[[Style1CustomCell alloc] layoutSubviews];
			break;
		case STYLE2:
			[[Style2CustomCell alloc] layoutSubviews];
			break;
		case STYLE3:
			[[Style3CustomCell alloc] layoutSubviews];
			break;
		default:
			[super layoutSubviews];
			break;
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    
	switch (self.viewStyle) {
		case STYLE0:
			[super setSelected:selected animated:animated];
			break;
		case STYLE1:
			[[Style1CustomCell alloc] setSelected:selected animated:animated];
			break;
		case STYLE2:
			[[Style2CustomCell alloc] setSelected:selected animated:animated];
			break;
		case STYLE3:
			[[Style3CustomCell alloc] setSelected:selected animated:animated];
			break;
		default:
			[super setSelected:selected animated:animated];
			break;
	}
    // Configure the view for the selected state
}


- (void)dealloc {

    [super dealloc];
}

- (void)setDataDictionary:(NSDictionary *)newDictionary
{
	switch (self.viewStyle) {
		case STYLE0:
			[super setDataDictionary:newDictionary];
			break;
		case STYLE1:
			[[Style1CustomCell alloc] setDataDictionary:newDictionary];
			break;
		case STYLE2:
			[[Style2CustomCell alloc] setDataDictionary:newDictionary];
			break;
		case STYLE3:
			[[Style3CustomCell alloc] setDataDictionary:newDictionary];
			break;
		default:
			[super setDataDictionary:newDictionary];
			break;
	}
}
-(id)initWithViewStyle:(int)style {
	self.viewStyle = style;
	return self;
}

@end
