//
//  RankList.h
//  MusicApp
//
//  Created by administrator on 2009/6/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//Style for 排行
#import <UIKit/UIKit.h>


@interface Style5CustomCell : UITableViewCell {
	NSDictionary	*dataDictionary;
	
	IBOutlet UILabel *label1;
}
@property (nonatomic,retain) UILabel *label1;
@property (nonatomic,retain) NSDictionary *dataDictionary;

@end
