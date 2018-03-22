//
//  MemoTextViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MemoTextViewController.h"


@implementation MemoTextViewController
@synthesize todoEvent;
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
	self.title=@"備註編輯";
	CGRect myRect=CGRectMake(0.0f, 0.0f, 100.0f, 100.0f);
	contentView=[[UITextView alloc]initWithFrame:myRect];
	[contentView setDelegate:self];
	[contentView becomeFirstResponder];
	contentView.text=[[todoEvent objectAtIndex:7] objectAtIndex:0];
	contentView.backgroundColor=[UIColor clearColor];
	self.view=contentView;
	[contentView release];
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


- (void) dealloc {
	[todoEvent release];
    [super dealloc];
}


-(void) textViewDidBeginEditing:(UITextView *) textView{
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"完成" 
											style:UIBarButtonItemStyleDone
											target:self
											action:@selector(doneEditing:)]
											autorelease];	
}

-(void)doneEditing:(id)sender{
	NSMutableString *msg=[[NSMutableString alloc]init];
	
	if([contentView.text length]>MAXMEMO){
		if([msg length]>0)
			[msg appendString:@"\n"];
		[msg appendFormat:@"最多%d字,超過%d字",MAXMEMO,([contentView.text length]-MAXMEMO)];
	}
	
	if([[contentView.text componentsSeparatedByString:@"\n"] count]>MAXMEMOROW){
		if([msg length]>0)
			[msg appendString:@"\n"];
		[msg appendFormat:@"最多%d行",MAXMEMOROW];
	}
	
	if([msg length]>0){
		UIAlertView *baseAlert = [[UIAlertView alloc]
				 initWithTitle:@"內容超過限制"
				 message:msg
				 delegate:self cancelButtonTitle:@"確定"
				 otherButtonTitles:nil];
		[baseAlert show];
		[baseAlert release];
	}else{
		[contentView resignFirstResponder];
		[[[todoEvent objectAtIndex:7] objectAtIndex:0] setString:contentView.text];
		[[self parentViewController] viewWillAppear:YES];
		[self.navigationController popViewControllerAnimated:YES];
	}
	[msg release];
}
	
	
	
@end
