//
//  ActivityList.m
//  MusicApp
//
//  Created by administrator on 2009/6/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Style4CustomCell.h"
#import "Constants.h"

@implementation Style4CustomCell

@synthesize label1,label2,dataDictionary,img;

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
	
	/*tag=[dataDictionary objectForKey:SecondaryLabel];
		if(tag == nil)
		label2.text = @" ";
	else
		label2.text = tag;*/
	

	tag=[dataDictionary objectForKey:ThirdLabel];
	//NSLog(@"test1-> %@",tag);
	NSMutableString *date=[[NSMutableString alloc] initWithString:tag];
	[date appendString:@" ~ "];
	tag=[dataDictionary objectForKey:FourthLabel];
	//NSLog(@"test2-> %@",tag);
	[date appendString:tag];
	//NSLog(@"test3-> %@",date);
	if(date == nil)
		label2.text = @" ";
	else
		label2.text = date;
	[date release];
	
	
	tag = [dataDictionary objectForKey:ImageView];
	if([[tag pathComponents] count]==1 ){
		
		img.image=[UIImage imageNamed:tag];
	}
	else
		img.image=[UIImage imageWithContentsOfFile:tag];
	
	
	/*tag = [dataDictionary objectForKey:ImageView];
	if(tag != nil){
		img.image=[UIImage imageWithContentsOfFile:tag];
		//img.image = [UIImage imageNamed:tag];
		//img.frame = CGRectMake(0, 0, 100, 100);
	}*/

}


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		self = (Style4CustomCell *)[[[[NSBundle mainBundle] loadNibNamed:@"Style4CustomCell" owner:self options:nil] objectAtIndex:0] retain];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[label1 release];
	[label2 release];
	[dataDictionary release];
    [super dealloc];
}


@end
