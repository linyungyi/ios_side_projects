//
//  CustomCell.m
//  MusicApp
//
//  Created by administrator on 2009/6/16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Style8CustomCell.h"
#import "Constants.h"

@implementation Style8CustomCell

@synthesize songLabel,songIdLabel,cpLabel,dataDictionary;

- (void)setDataDictionary:(NSDictionary *)newDictionary
{
		
	if(newDictionary!=dataDictionary){
		[newDictionary retain];
		[dataDictionary release];
		dataDictionary=newDictionary;	
	}
	
	// update value in subviews
	NSString *tag =[dataDictionary objectForKey:PrimaryLabel];
	if(tag == nil)
		songLabel.text=@" ";
	else
		songLabel.text = tag;
	
	/*
	 tag=[dataDictionary objectForKey:SecondaryLabel];
		if(tag == nil)
		singerLabel.text=@" ";
	else
		singerLabel.text = tag;
	*/
	
	tag=[dataDictionary objectForKey:ThirdLabel];
	if(tag == nil)
		songIdLabel.text=@" ";
	else	
		songIdLabel.text = tag;
	
	tag=[dataDictionary objectForKey:FourthLabel];
	if(tag==nil)
		cpLabel.text=@"";
	else
		cpLabel.text=tag;
	
	/*
	tag = [dataDictionary objectForKey:ImageView];
	if([[tag pathComponents] count]==1 ){
		
		img.image=[UIImage imageNamed:tag];
	}
	else
		img.image=[UIImage imageWithContentsOfFile:tag];
	*/
	
	
	
}


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self = [[[[NSBundle mainBundle] loadNibNamed:@"Style8CustomCell" owner:self options:nil] objectAtIndex:0] retain];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[songLabel release];
	//[singerLabel release];
	[songIdLabel release];
	[cpLabel release];
	[dataDictionary release];
	//[img release];
    [super dealloc];
}


@end
