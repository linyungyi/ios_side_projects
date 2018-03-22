//
//  CustomCell.h
//  MusicApp
//
//  Created by administrator on 2009/6/16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//styple for 歌曲清單
#import <UIKit/UIKit.h>


@interface Style8CustomCell : UITableViewCell {
	NSDictionary *dataDictionary;
	//NSMutableDictionary *dataDictionary;
	IBOutlet UILabel *songLabel;
	//IBOutlet UILabel *singerLabel;
	IBOutlet UILabel *songIdLabel;
	IBOutlet UILabel *cpLabel;
	//IBOutlet UIImageView *img;
	//UIImage *tmpImg;
	 
}
@property (nonatomic,retain) UILabel *songLabel;
//@property (nonatomic,retain) UILabel *singerLabel;
@property (nonatomic,retain	) UILabel *songIdLabel;
@property (nonatomic,retain) UILabel *cpLabel;
@property (nonatomic,retain) NSDictionary *dataDictionary;
//@property (nonatomic,retain) UIImageView *img;
@end
