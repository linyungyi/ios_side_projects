//
//  CustomCell.m
//  MusicApp
//
//  Created by administrator on 2009/6/16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Style6CustomCell.h"


@implementation Style6CustomCell

@synthesize songLabel,singerLabel,songIdLabel,cpLabel,dataDictionary,img,priceLabel;

- (void)setDataDictionary:(NSDictionary *)newDictionary
{
	/*
	if(newDictionary!=dataDictionary){
		[newDictionary retain];
		[dataDictionary release];
		dataDictionary=newDictionary;	
	}*/
	
	// update value in subviews
	NSString *tag =[dataDictionary objectForKey:@"song"];
	if(tag == nil)
		songLabel.text=@" ";
	else
		songLabel.text = tag;
	
	tag=[dataDictionary objectForKey:@"singer"];
		if(tag == nil)
		singerLabel.text=@" ";
	else
		singerLabel.text = tag;
	
	tag=[dataDictionary objectForKey:@"songId"];
	if(tag == nil)
		songIdLabel.text=@" ";
	else	
		songIdLabel.text = tag;
	
	tag=[dataDictionary objectForKey:@"cp"];
	if(tag==nil)
		cpLabel.text=@"";
	else
		cpLabel.text=tag;
	
	tag=[dataDictionary objectForKey:"price"];
	if(tag==nil)
		priceLabel.text=@"";
	else{
		NSMutableString *tmpstring=[[NSMutableString alloc] initWithString:tag];
		[tmpstring appendString:@"元"];
		priceLabel.text=tmpstring;
		[tmpstring release];
	}
	/*
	tag = [dataDictionary objectForKey:ImageView];
	if([[tag pathComponents] count]==1 ){
		
		img.image=[UIImage imageNamed:tag];
	}
	else
		img.image=[UIImage imageWithContentsOfFile:tag];
	*/
		
}


//#ifdef __IPHONE_3_0
/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self = [[[[NSBundle mainBundle] loadNibNamed:@"Style6CustomCell" owner:self options:nil] objectAtIndex:0] retain];
	}
	return self;
}*/
/*#else
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self = [[[[NSBundle mainBundle] loadNibNamed:@"Style6CustomCell" owner:self options:nil] objectAtIndex:0] retain];
    }
    return self;
}
#endif*/

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[songLabel release];
	[singerLabel release];
	[songIdLabel release];
	[cpLabel release];
	[dataDictionary release];
	[img release];
    [super dealloc];
}


@end
