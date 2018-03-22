//
//  LyricViewController.m
//  Music01
//
//  Created by Ben on 2009/9/5.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LyricViewController.h"
#define HORIZ_MIN	 100


@implementation LyricViewController
@synthesize lyricContent;

-(void)setLyricContent:(NSMutableString *)lyric
{
	lyricContent=lyric;
	//NSLog(@"setLyricContent:%@",lyricContent);
	[lyricView loadHTMLString:lyricContent baseURL:nil];

	//NSLog(@"setLyricContent");
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	/*lyricView=[[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[lyricView setScalesPageToFit:YES];
	lyricView.backgroundColor = [UIColor clearColor];
	lyricView.tag=LyricContentIndex;
	lyricView.hidden=FALSE;*/

	//lyricLabel=[[UILabel alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	//[self.view addSubview:lyricLabel];
	/*[lyricTextView setDelegate:self];
	[self.view addSubview:lyricTextView];*/
	//[self.view addSubview:lyricView];
	
	[super viewDidLoad];
	//NSLog(@"viewDidLoad");
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
    [super dealloc];
}
@end
