    //
//  AgendaViewController.m
//  MyCalendar
//
//  Created by yvesho on 2010/4/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AgendaViewController.h"
#import "NewEventViewController.h"

@implementation AgendaViewController

@synthesize navController;
@synthesize tableViewController;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
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
	//self.title=@"行事曆";
	/*
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calen_head.png"]]; 
	[navController.navigationBar insertSubview:backgroundView atIndex:0]; 
	[backgroundView release];
	*/
	
	self.navController.navigationBar.tintColor = [UIColor colorWithRed:128/255.0 green:64/255.0 blue:0/255.0 alpha:1.0f];
	[self.view addSubview: navController.view];
}


- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES]; 
	
	[self.tableViewController viewWillAppear:YES];
	//[self.tableViewController refreshViewWithPushDirection:3];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction)doAdd:(id)sender{
	DoLog(DEBUG,@"doAdd");
	
	NewEventViewController *nextController = [[[NewEventViewController alloc] initWithNibName:@"NewEventView" dateString:nil] autorelease];
	//self.title=@"首頁";
    [self.navController pushViewController:nextController animated:YES];
}

- (void)dealloc {
	 [tableViewController release];
	 [navController release];
    [super dealloc];
}


@end
