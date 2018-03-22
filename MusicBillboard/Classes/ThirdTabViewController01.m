//
//  ThirdTabViewController01.m
//  Music01
//
//  Created by albert on 2009/6/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ThirdTabViewController01.h"
#import "CustomCell.h"
#import "Constants.h"
#import "avTouchViewController.h"


@implementation ThirdTabViewController01
@synthesize myTableView;
@synthesize myTableSection;
@synthesize mySectionRow;
@synthesize avController;


// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

-(void)setMember:(NSString *)theMember {
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self initDataSource];
}

- (void)initDataSource{
	//section
	//myTableSection = [[NSArray alloc] initWithObjects:@"No蘇打綠 No Life！",nil];
	self.myTableSection =[[NSMutableArray alloc] init];
	[myTableSection addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							   @"活動名稱：No蘇打綠 No Life！", SectionTitle,
							   @"送可口可樂T、蘇打綠簽名馬克杯喔！", PrimaryLabel,
							   @"活動期間：2009-06-08～2009-06-28", SecondaryLabel,
							   @"252X193.png", ImageView,	 
							   nil]];
	[myTableSection addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							   @"歌曲清單", SectionTitle,
							   nil]];
	 self.mySectionRow =  [[NSMutableArray alloc] init];
	//for(int i=0;i<7;i++)
	//{
		[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 @"早點回家", PrimaryLabel,
								 @"蘇打綠", SecondaryLabel,
								 @"411145.png", ImageView,	 
								 @"01.mp3", FilePath,
								 nil]];
		[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 @"是我的海", PrimaryLabel,
								 @"蘇打綠", SecondaryLabel,
								 @"411145.png", ImageView,	 
								 @"01.mp3", FilePath,
								 nil]];
		[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 @"OhOhOhOh…", PrimaryLabel,
								 @"蘇打綠", SecondaryLabel,
								 @"411145.png", ImageView,	 
								 @"01.mp3", FilePath,
								 nil]];
		[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 @"相對論IV", PrimaryLabel,
								 @"蘇打綠", SecondaryLabel,
								 @"411145.png", ImageView,	 
								 @"01.mp3", FilePath,
								 nil]];
		[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 @"降落練習存在孿生基因", PrimaryLabel,
								 @"蘇打綠", SecondaryLabel,
								 @"411145.png", ImageView,	 
								 @"01.mp3", FilePath,
								 nil]];
		[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 @"That Moment Is Over", PrimaryLabel,
								 @"蘇打綠", SecondaryLabel,
								 @"411145.png", ImageView,	 
								 @"01.mp3", FilePath,
								 nil]];
		[mySectionRow addObject:[NSDictionary dictionaryWithObjectsAndKeys:
								 @"你喔", PrimaryLabel,
								 @"蘇打綠", SecondaryLabel,
								 @"411145.png", ImageView,	 
								 @"01.mp3", FilePath,
								 nil]];
	//}

}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	//return (section == 0) ? 2: 1;
	//return [mySectionRow00 count];
	int count=0;
	NSString *debugString;
	debugString=@"tableView:numberOfRowsInSection";
	@try{
		//count=[mySectionRow00 count];
		if(section ==0)
			count = 1;
		else
			count=[mySectionRow count];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}
	@finally {
		return count;
	}
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	int count=1;
	NSString *debugString;
	debugString=@"numberOfSectionsInTableView";
	if(myTableSection == nil)
		return count;
	@try{
		count=[myTableSection count];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}
	@finally {
		return count;
	}
	
}

 -(CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section{
	 if(section==0)
		 return HeightForHeader1;
	 else
		 return HeightForHeader0;
 }
 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//NSLog([NSString stringWithFormat:@"a:%d",indexPath.row );
	if(indexPath.row == 0 && indexPath.section == 0)
		return HeightForRow1;
	else
		return HeightForRow0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	//return [NSString stringWithFormat:@"歌手 %d",section];
	//return [myTableSection objectAtIndex:section];
	NSString *title=@"";
	NSString *debugString;
	debugString=@"tableView:titleForHeaderInSection";
	if(myTableSection == nil)
		return title;
	@try{
		title =[[myTableSection objectAtIndex:section] objectForKey:SectionTitle];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}
	@finally {
		return title;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	/*UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TestCell"];
	 if (cell == nil) {
	 CGRect rect;
	 rect = CGRectMake(0.0,0.0,320.0,60.0);
	 cell = [[[UITableViewCell alloc] initWithFrame:rect reuseIdentifier:@"TestCell"] autorelease];
	 
	 }
	 cell.text = [NSString stringWithFormat:@"%@ %d %@ %d",@"蘇打綠" , indexPath.section ,@"早點回家" , indexPath.row];
	 return cell;*/
	//NSLog([NSString stringWithFormat:@"b:%d %d",indexPath.section,(self.style1)?1:0] );
	static NSString *CellIdentifier = @"Cell";	
	NSString *debugString;
	debugString=@"tableView:cellForRowAtIndexPath";
	CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	NSDictionary *showData;
	int showStyle;
	
	if(indexPath.row ==0 && indexPath.section == 0)
	{
		showStyle=STYLE1;
		showData = [myTableSection objectAtIndex:indexPath.row];
	}else
	{
		showStyle=STYLE0;
		showData = [mySectionRow objectAtIndex:indexPath.row];
	}
	
	if (cell == nil) {
		cell = [[[[CustomCell alloc] initWithViewStyle:showStyle] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	@try{
		cell.dataDictionary = [showData retain];
	}@catch (NSException *exception) {
		NSLog(@"%@[%@] >> %@",NSStringFromClass([self class]),debugString,[exception reason]);
	}@finally {
		[showData release];
	}
	return cell;
}

 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
	 /*
 if(self.firstTabViewController01 == nil){
 FirstTabViewController01 *view01 = [[FirstTabViewController01 alloc] initWithNibName:@"FirstTabView01" bundle:[NSBundle mainBundle]];
 self.firstTabViewController01 = view01;
 [view01 release];
 }
 
 [self.navigationController pushViewController:firstTabViewController01 animated:YES];	*/

	 if(self.avController == nil){
		 avTouchViewController *view01 = [[avTouchViewController alloc] initWithNibName:@"avTouchViewController" bundle:[NSBundle mainBundle]];
		 self.avController = view01;
		 [view01 release];
	 }
	 //[avController setUri:[[mySectionRow objectAtIndex:indexPath.row] objectForKey:FilePath]];
	 [self.navigationController setHidesBottomBarWhenPushed:YES];
	 [self.navigationController pushViewController:avController animated:YES];	
 
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
	[myTableView release];
	[myTableSection release];
	[mySectionRow release];
    [super dealloc];
}


@end
