//
//  SettingTestViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/4/8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingTestViewController : UIViewController <UITextFieldDelegate>{
	
	UITextField *sTextField;
	UITextField *aTextField;
	UILabel *urlLabel;
}

@property (nonatomic,retain) IBOutlet UITextField *sTextField;
@property (nonatomic,retain) IBOutlet UITextField *aTextField;
@property (nonatomic,retain) IBOutlet UILabel *urlLabel;

-(void) doJob:(id)sender;

-(void) doTest;

@end
