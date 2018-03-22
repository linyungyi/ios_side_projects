//
//  FirstTabViewController01.h
//  Music01
//
//  Created by albert on 2009/6/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FirstTabViewController01 : UIViewController <UIActionSheetDelegate>{
	UIActionSheet *downloadActionSheet;
	UIActionSheet *timeActionSheet;
	UIActionSheet *groupActionSheet;
	//UIActionSheet *confirmActionSheet;
	UIAlertView *confirmActionSheet;
}

-(void)confirmAction;

@end
