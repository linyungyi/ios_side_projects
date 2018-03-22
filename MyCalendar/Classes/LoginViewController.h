//
//  LoginViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/4/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceUtil.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>{
	UITextField *idTextField;
	UITextField *passTextField;
	UISwitch *saveSwitch;
	UIButton *loginButton;
	UIButton *cancelButton;
	UIActivityIndicatorView *loginActivityIndicator;
	ServiceUtil *serviceUtil;
}

@property (nonatomic,retain) IBOutlet UITextField *idTextField;
@property (nonatomic,retain) IBOutlet UITextField *passTextField;
@property (nonatomic,retain) IBOutlet UISwitch *saveSwitch;
@property (nonatomic,retain) IBOutlet UIButton *loginButton;
@property (nonatomic,retain) IBOutlet UIButton *cancelButton;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *loginActivityIndicator;
@property (nonatomic,retain) ServiceUtil *serviceUtil;

-(IBAction) doLogin:(id)sender;
-(IBAction) doCancel:(id)sender;
-(IBAction) doSwitch:(id)sender;

//-(void) sendLoginInfo:(NSDictionary *)userInfo;
-(void) doProvision;

-(void) getVersion;

@end
