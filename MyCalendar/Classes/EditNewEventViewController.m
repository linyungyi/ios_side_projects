//
//  EditNewEventViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/4/29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EditNewEventViewController.h"


@implementation EditNewEventViewController
@synthesize navController;
@synthesize rootViewController;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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
    [super viewDidLoad];
	/*
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calen_head.png"]]; 
	[navController.navigationBar insertSubview:backgroundView atIndex:0]; 
	[backgroundView release]; 
	*/
	
	self.navController.navigationBar.tintColor = [UIColor colorWithRed:128/255.0 green:64/255.0 blue:0/255.0 alpha:1.0f];
	//self.navController.view.backgroundColor = [UIColor clearColor];
	self.navController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:BACKGROUNDIMG]];
	[self.view addSubview: navController.view];
}


- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES]; 
	
	self.rootViewController.fromFlag=1;
	[self.rootViewController initNewTodoEvent:nil];
	[self.rootViewController resetTableDatas];
	[self.rootViewController viewWillAppear:YES];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[rootViewController release];
	[navController release];
    [super dealloc];
}


@end
