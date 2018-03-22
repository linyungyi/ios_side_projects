//
//  ServiceDescriptionViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/4/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ServiceDescriptionViewController.h"


@implementation ServiceDescriptionViewController
@synthesize sv;

- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
	//CGPoint offset = aScrollView.contentOffset;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 372)];
	sv.contentSize = CGSizeMake(320.0f, 60.0*24);
	sv.delegate = self;
	sv.backgroundColor=[UIColor whiteColor];
	
	
	CGRect appFrame = CGRectMake(0, 0, 320, 372);
	UILabel *contentView = [[UILabel alloc] initWithFrame:appFrame];
	contentView.text=@"本軟體為中華電信股份有限公司所有，⋯ \n\n(加值處提供)\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
	contentView.numberOfLines=200;
	contentView.backgroundColor=[UIColor clearColor];
	
	[sv addSubview:contentView];
	
	self.view=sv;
	self.view.backgroundColor=[UIColor clearColor];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
	[sv release];
    [super dealloc];
}


@end
