//
//  PimContactViewController.h
//  PimContact
//
//  Created by bko on 2010/2/22.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Style6CustomCell.h"

@class test;

@interface PimContactViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate>{
	IBOutlet UILabel *firstName;
	IBOutlet UILabel *lastName;
	NSArray *people;
	IBOutlet UITableView *contactsTableView;

}

@property (nonatomic,retain) UILabel *firstName;
@property (nonatomic,retain) UILabel *lastName;
@property (nonatomic,retain) NSArray *people;
@property (nonatomic,retain) UITableView *contactsTableView;

-(IBAction) showPicker:(id)sender;

@end

