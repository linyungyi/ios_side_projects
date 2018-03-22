//
//  ActivityList.h
//  MusicApp
//
//  Created by administrator on 2009/6/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


//Style for 活動

#import <UIKit/UIKit.h>


@interface Style4CustomCell : UITableViewCell {

	NSDictionary	*dataDictionary;
	
	IBOutlet UILabel *label1;
	IBOutlet UILabel *label2;
	IBOutlet UIImageView *img;
}

@property (nonatomic,retain) UILabel *label1;
@property (nonatomic,retain) UILabel *label2;
@property (nonatomic,retain) NSDictionary *dataDictionary;
@property(nonatomic,retain) UIImageView *img;

@end
