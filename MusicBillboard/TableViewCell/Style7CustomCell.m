//
//  ConfigList.m
//  MusicApp
//
//  Created by administrator on 2009/6/29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Style7CustomCell.h"
#import "Constants.h"

@implementation Style7CustomCell

@synthesize label1,label2,dataDictionary;

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
		label1.text=@" ";
	else
		label1.text = tag;
	tag=[[dataDictionary objectForKey:SecondaryLabel] retain];
	if(tag == nil)
		label2.text = @" ";
	else
		label2.text = tag;
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self = [[[[NSBundle mainBundle] loadNibNamed:@"Style7CustomCell" owner:self options:nil] objectAtIndex:0] retain];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
