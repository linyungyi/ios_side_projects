//
//  BaseCustomCell.m
//  Music01
//
//  Created by albert on 2009/6/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BaseCustomCell.h"
#import "Constants.h"

@implementation BaseCustomCell
@synthesize dataDictionary;
@synthesize primaryLabel;
@synthesize secondaryLabel;
@synthesize myImageView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // Initialization code
		primaryLabel = [[UILabel alloc]init];
		primaryLabel.textAlignment = UITextAlignmentLeft;
		primaryLabel.font = [UIFont systemFontOfSize:14];
		secondaryLabel = [[UILabel alloc]init];
		secondaryLabel.textAlignment = UITextAlignmentLeft;
		secondaryLabel.font = [UIFont systemFontOfSize:8];
		myImageView = [[UIImageView alloc]init];
		[self.contentView addSubview:primaryLabel];
		[self.contentView addSubview:secondaryLabel];
		[self.contentView addSubview:myImageView];
    }
    return self;
}

-(void)layoutSubviews{
	[super layoutSubviews];
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGRect frame;
	
	frame = CGRectMake(boundsX+10, 0, WidthForImage0, HeightForImage0);
	myImageView.frame =frame;
	
	frame = CGRectMake(boundsX+70, 5, WidthForPrimaryLabel0, HeightForPrimaryLabel0);
	primaryLabel.frame = frame;
	
	frame = CGRectMake(boundsX+70, 30, WidthForSecondaryLabel0, HeightForSecondaryLabel0);
	secondaryLabel.frame = frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[primaryLabel release];
	[secondaryLabel release];
	[myImageView release];
	[dataDictionary release];
    [super dealloc];
}


- (void)setDataDictionary:(NSDictionary *)newDictionary
{
	/*if (dataDictionary == newDictionary)
	 {
	 return;
	 }
	 [dataDictionary release];
	 dataDictionary = [newDictionary retain];*/
	
	if(newDictionary!=dataDictionary){
		[newDictionary retain];
		[dataDictionary release];
		dataDictionary=newDictionary;	
	}
	
	// update value in subviews
	NSString *tag;
	tag=[dataDictionary objectForKey:PrimaryLabel];
	if(tag == nil)
		primaryLabel.text=@" ";
	else
		primaryLabel.text = tag;
	//[tag release];
	tag=[dataDictionary objectForKey:SecondaryLabel];
	if(tag == nil)
		secondaryLabel.text = @" ";
	else
		secondaryLabel.text = tag;
	//[tag release];
	tag = [dataDictionary objectForKey:ImageView];
	if(tag != nil)
		if([[tag pathComponents] count] > 1)
			myImageView.image=[UIImage imageWithContentsOfFile:tag];
		else
			myImageView.image = [UIImage imageNamed:tag];
	//[tag release];
}


@end
