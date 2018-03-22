//
//  Style1CustemCell.m
//  Music01
//
//  Created by albert on 2009/6/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Style1CustomCell.h"
#import "Constants.h"

@implementation Style1CustomCell
@synthesize dataDictionary;
@synthesize primaryLabel;
@synthesize secondaryLabel;
@synthesize myImageView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		//self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // Initialization code
		primaryLabel = [[UILabel alloc]init];
		primaryLabel.textAlignment = UITextAlignmentLeft;
		primaryLabel.numberOfLines = 2;
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
	/*
	frame = CGRectMake(boundsX+100, 20, WidthForImage1, HeightForImage1);
	myImageView.frame =frame;
	
	frame = CGRectMake(boundsX+25, 140, WidthForPrimaryLabel1, HeightForPrimaryLabel1);
	primaryLabel.frame = frame;
	
	frame = CGRectMake(boundsX+25, 180, WidthForSecondaryLabel1, HeightForSecondaryLabel1);
	secondaryLabel.frame = frame;*/
	
	 frame = CGRectMake(boundsX+10, 10, WidthForImage1, HeightForImage1);
	 myImageView.frame =frame;
	 
	 frame = CGRectMake(boundsX+120, 30, WidthForPrimaryLabel1, HeightForPrimaryLabel1);
	 primaryLabel.frame = frame;
	 
	 frame = CGRectMake(boundsX+120, 70, WidthForSecondaryLabel1, HeightForSecondaryLabel1);
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
	tag=[[dataDictionary objectForKey:PrimaryLabel] retain];
	if(tag == nil)
		primaryLabel.text=@" ";
	else
		primaryLabel.text = tag;
	//[tag release];
	tag=[[dataDictionary objectForKey:SecondaryLabel] retain];
	if(tag == nil)
		secondaryLabel.text = @" ";
	else
		secondaryLabel.text = tag;
	//[tag release];
	tag = [[dataDictionary objectForKey:ImageView] retain];
	if(tag != nil)
		myImageView.image = [UIImage imageNamed:tag];
	//[tag release];
}


@end
