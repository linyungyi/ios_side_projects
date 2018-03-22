//
//  UserInfoViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/4/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SyncOperation.h"
#import "ServiceUtil.h"

@interface UserInfoViewController : UIViewController<UITextFieldDelegate,SyncOperationDelegate,UIActionSheetDelegate>{
	UITextField *idTextField;
	UITextField *passTextField;
	UISwitch *saveSwitch;
	UIButton *loginButton;
	
	UIActivityIndicatorView *loginActivityIndicator;
	UIProgressView *myProgressView;
	
	UIButton *changeButton;
	UIButton *delButton;
	UILabel *serviceLabel;
	
	UILabel *applyLabel;
	UIButton *applyButton;
	UIView *webView;
	
	UIView *defaultView;
	SyncOperation *syncOperation;
	ServiceUtil *serviceUtil;
}
@property (nonatomic,retain) IBOutlet UITextField *idTextField;
@property (nonatomic,retain) IBOutlet UITextField *passTextField;
@property (nonatomic,retain) IBOutlet UISwitch *saveSwitch;
@property (nonatomic,retain) IBOutlet UIButton *loginButton;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *loginActivityIndicator;
@property (nonatomic,retain) IBOutlet UIProgressView *myProgressView;

@property (nonatomic,retain) IBOutlet UIButton *changeButton;
@property (nonatomic,retain) IBOutlet UIButton *delButton;
@property (nonatomic,retain) IBOutlet UILabel *serviceLabel;
@property (nonatomic,retain) IBOutlet UIButton *applyButton;
@property (nonatomic,retain) IBOutlet UILabel *applyLabel;

@property (nonatomic,retain) UIView *defaultView;
@property (nonatomic,retain) IBOutlet UIView *webView;
@property (retain) SyncOperation *syncOperation;
@property (nonatomic,retain) ServiceUtil *serviceUtil;

-(IBAction) doLogin:(id)sender;
-(IBAction) doChange:(id)sender;
-(IBAction) doDel:(id)sender;
-(IBAction) doSwitch:(id)sender;
-(IBAction) doApply:(id)sender;

//-(void) sendLoginInfo:(NSDictionary *)userInfo;
-(void) sendChangeCommand:(NSDictionary *)userInfo;
-(void) sendDelCommand:(NSDictionary *)userInfo;

-(void) updProcess:(NSString *)p;

-(void) doProvision;

@end
