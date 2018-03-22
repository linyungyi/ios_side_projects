//
//  ConfigList.h
//  MusicApp
//
//  Created by administrator on 2009/6/29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//style for 答鈴設定
#import <UIKit/UIKit.h>



@interface Style7CustomCell : UITableViewCell {
	NSDictionary *dataDictionary;
	IBOutlet UILabel *label1;
	IBOutlet UILabel *label2;
}

@property (nonatomic,retain) UILabel *label1;
@property (nonatomic,retain) UILabel *label2;
@property(nonatomic,retain) NSDictionary *dataDictionary;

@end
