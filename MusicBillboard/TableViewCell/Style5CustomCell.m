//
//  RankList.m
//  MusicApp
//
//  Created by administrator on 2009/6/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Style5CustomCell.h"
#import "Constants.h"

@implementation Style5CustomCell

@synthesize label1,dataDictionary;

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
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self = [[[[NSBundle mainBundle] loadNibNamed:@"Style5CustomCell" owner:self options:nil] objectAtIndex:0 ] retain];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[label1 release];
	[dataDictionary release];
    [super dealloc];
}


@end
