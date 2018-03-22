    //
//  EventIconViewController.m
//  MyCalendar
//
//  Created by yvesho on 2010/5/8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EventIconViewController.h"
#import "RuleArray.h"

@implementation EventIconViewController
@synthesize sv;
@synthesize viewDatas;
@synthesize todoEvent;
@synthesize selIndex;
@synthesize currIndex;


- (id)init {
    if ((self = [super init])) {
        // Custom initialization
		self.viewDatas=[RuleArray getEventIconArray];
    }
    return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view=[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 370.0f)];
	//self.view.userInteractionEnabled=YES;
	
	self.view.backgroundColor=[UIColor clearColor];
	self.view.backgroundColor=[UIColor blackColor];
	DoLog(DEBUG,@"%f %f",self.view.center.x,self.view.center.y);
	
	NSString *tmpString=[[todoEvent objectAtIndex:6] objectAtIndex:0];
	if([tmpString length]>0){
		self.currIndex=[tmpString intValue];
		self.selIndex=currIndex;
	}
	
	//self.sv = [[UIView alloc] initWithFrame:CGRectMake((320.0f-293.0f)/2,(372.0f-327.0f)/2, 293.0f, 327.0f)];
	self.sv = [[UIScrollView alloc] initWithFrame:CGRectMake((320.0f-293.0f)/2,(372.0f-327.0f)/2, 293.0f, 327.0f)];
	sv.contentSize = CGSizeMake(320.0f, 372.0f);
	sv.delegate = self;
	//sv.backgroundColor=[UIColor clearColor];
	sv.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"alert_color_eventicon_bg.png"]];
	
	
	float f_x=30.0f,f_w=42.0f;
	float f_y=25.0f,f_h=42.0f;
	int i_x=95;
	int i_y=75;
	int i=0,j=0,k=0,key=0;
	
	UIButton *iconButton;
	
	//f_y=0.0f;
	for(i=0;i<[viewDatas count];i++){
		key=[[viewDatas objectAtIndex:i]intValue];
		
		iconButton = [[UIButton alloc] initWithFrame:CGRectMake(f_x+j*i_x, f_y+k*i_y, f_w, f_h)];
		[iconButton setTag:key];
		
		if(key==currIndex){
			
			[iconButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"eventicon_%@40.png",[RuleArray getEventIcon:key]]] forState:UIControlStateNormal];
			//[iconButton setBackgroundImage:[UIImage imageNamed:@"alert_color_eventicon_over_bg.png"] forState:UIControlStateHighlighted];
			[iconButton setBackgroundImage:[UIImage imageNamed:@"alert_color_eventicon_select_bg.png"] forState:UIControlStateNormal];
			//[iconButton setSelected:YES];
		}else {
			
			[iconButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"eventicon_%@40.png",[RuleArray getEventIcon:key]]] forState:UIControlStateNormal];
			//[iconButton setBackgroundImage:[UIImage imageNamed:@"alert_color_eventicon_over_bg.png"] forState:UIControlStateHighlighted];
			[iconButton setImage:[UIImage imageNamed:@"alert_color_eventicon_over_bg.png"] forState:UIControlStateSelected];
		}

		
		iconButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		iconButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[iconButton addTarget:self action:@selector(chooseIcon:) forControlEvents:UIControlEventTouchUpInside];
		
		
		[sv addSubview:iconButton];
		[iconButton release];
		
		j++;
		if(j>=3){
			j=0;
			k++;
		}
	}
	
	[self.view addSubview:sv];
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"無" style:UIBarButtonItemStyleBordered target:self action:@selector(doJob)] autorelease];
}


-(void) chooseIcon:(UIButton *) sender{
	//DoLog(INFO,@"%@ %d",sender,[sender tag]);
	if(self.selIndex!=0)
		[(UIButton *)[self.sv viewWithTag:self.selIndex] setSelected:NO];
	self.selIndex=[sender tag];
	/*
	for(UIView *aButton in [self.sv subviews]){
		if([aButton isKindOfClass:[UIButton class]]==YES)
			[(UIButton *)aButton setSelected:NO];
			[(UIButton *)aButton setHighlighted:NO];
	}
	*/
	[sender setSelected:YES];
	
	[[[todoEvent objectAtIndex:6] objectAtIndex:0] setString:[NSString stringWithFormat:@"%d",selIndex]];
	[[self parentViewController] viewWillAppear:YES];
	[self.navigationController popViewControllerAnimated:YES];	
}

-(void) doJob{
	[[[todoEvent objectAtIndex:6] objectAtIndex:0] setString:[NSString stringWithFormat:@""]];
	
	[[self parentViewController] viewWillAppear:YES];
	[self.navigationController popViewControllerAnimated:YES];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[sv release];
	[viewDatas release];
	[todoEvent release];
    [super dealloc];
}

- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
	//CGPoint offset = aScrollView.contentOffset;
}

@end
