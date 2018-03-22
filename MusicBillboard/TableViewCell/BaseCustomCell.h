//
//  BaseCustomCell.h
//  Music01
//
//  Created by albert on 2009/6/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BaseCustomCell : UITableViewCell {
	NSDictionary	*dataDictionary;
	
	UILabel *primaryLabel;
	UILabel *secondaryLabel;
	UIImageView *myImageView;
}
@property (nonatomic, retain) NSDictionary *dataDictionary;
@property (nonatomic, retain) UILabel *primaryLabel;
@property (nonatomic, retain) UILabel *secondaryLabel;
@property (nonatomic, retain) UIImageView *myImageView;
@end
