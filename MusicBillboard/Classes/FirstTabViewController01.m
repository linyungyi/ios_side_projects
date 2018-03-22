//
//  FirstTabViewController01.m
//  Music01
//
//  Created by albert on 2009/6/17.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FirstTabViewController01.h"


@implementation FirstTabViewController01

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	UIBarButtonItem *addButton = [[[UIBarButtonItem alloc]
								   initWithTitle:NSLocalizedString(@"下載", @"")
								   style:UIBarButtonItemStyleBordered
								   target:self
								   action:@selector(addAction:)] autorelease];
	self.navigationItem.rightBarButtonItem = addButton;	

    //[super viewDidLoad];
}

- (void)addAction:(id)sender
{
	// the add button was clicked, handle it here
	//
	NSLog(@"download");
	UIActionSheet *downloadAlert =
	[[UIActionSheet alloc] initWithTitle:@"請選擇播放條件:"
								delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
					   otherButtonTitles:@"基本音", @"時間音", @"群組音", nil];
	
	downloadAlert.actionSheetStyle = self.navigationController.navigationBar.barStyle;
	downloadActionSheet = downloadAlert;
	[downloadAlert showInView:self.view];
	[downloadAlert release];
}

// change the navigation bar style, also make the status bar match with it
- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(modalView == downloadActionSheet){
		switch (buttonIndex)
		{
			case 0:
			{
				//NSLog(@"basic");
				[self confirmAction];
				break;
			}
			case 1:
			{
				UIActionSheet *timeAlert =
				[[UIActionSheet alloc] initWithTitle:@"請選擇時間條件:"
										delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
							   otherButtonTitles:@"白天音", @"晚上音", @"週末音", nil];
			
				// use the same style as the nav bar
				timeActionSheet = timeAlert;
				timeAlert.actionSheetStyle = self.navigationController.navigationBar.barStyle;
			
				[timeAlert showInView:self.view];
				[timeAlert release];
			
				break;
			}
			case 2:
			{
				UIActionSheet *groupAlert =
				[[UIActionSheet alloc] initWithTitle:@"請選擇群組條件:"
											delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
								   otherButtonTitles:@"群組一", @"群組二", @"群組三", @"群組四", @"群組五", nil];
				
				// use the same style as the nav bar
				groupActionSheet = groupAlert;
				groupAlert.actionSheetStyle = self.navigationController.navigationBar.barStyle;
				
				[groupAlert showInView:self.view];
				[groupAlert release];
				break;
			}
		}
	}
	if(modalView == timeActionSheet)
	{
		/*
		switch (buttonIndex)
		{
			case 0:
			{
				NSLog(@"day");
				break;
			}
			case 1:
			{
				NSLog(@"night");
				break;
			}
			case 2:
			{
				NSLog(@"weekend");
				break;
			}
		}*/
		[self confirmAction];
	}
	if(modalView == groupActionSheet)
	{
		/*
		switch (buttonIndex)
		{
			case 0:
			{
				NSLog(@"group1");
				break;
			}
			case 1:
			{
				NSLog(@"group2");
				break;
			}
			case 2:
			{
				NSLog(@"group3");
				break;
			}
			case 3:
			{
				NSLog(@"group4");
				break;
			}
			case 4:
			{
				NSLog(@"group5");
				break;
			}
		}
		 */
		[self confirmAction];
	}
	/*
	if(modalView == confirmActionSheet)
	{
		switch (buttonIndex)
		{
			case 0:
			{
				NSLog(@"ok");
				break;
			}
			case 1:
			{
				NSLog(@"cancle");
				break;
			}
		}
	}*/
}
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action

	if(buttonIndex == 1)
	{
		NSLog(@"ok");
	}
}

-(void)confirmAction{
	/*
	UIActionSheet *confirmAlert =
	[[UIActionSheet alloc] initWithTitle:@"確定下載？"
								delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"確定"
					   otherButtonTitles: nil];
	
	// use the same style as the nav bar
	confirmActionSheet = confirmAlert;
	confirmAlert.actionSheetStyle = self.navigationController.navigationBar.barStyle;
	
	[confirmAlert showInView:self.view];
	[confirmAlert release];*/
	UIAlertView *confirmAlert =
	[[UIAlertView alloc] initWithTitle:@"鈴聲下載" message:@"確定下載？"
								delegate:self cancelButtonTitle:@"取消" 
					   otherButtonTitles:@"確定", nil];
	
	// use the same style as the nav bar
	//confirmActionSheet = confirmAlert;
	//confirmAlert.actionSheetStyle = self.navigationController.navigationBar.barStyle;
	
	//[confirmAlert showInView:self.view];
	//[confirmAlert release];
	[confirmAlert show];
	[confirmAlert release];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[downloadActionSheet release];
	[timeActionSheet release];
	[groupActionSheet release];
	[confirmActionSheet release];
    [super dealloc];
}


@end
