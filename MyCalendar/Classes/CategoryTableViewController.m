//
//  CategoryTableViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/3/2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "CategoryDetailViewController.h"
#import "MySqlite.h"
#import "TodoCategory.h"
#import "RuleArray.h"

@implementation CategoryTableViewController

@synthesize flag;
@synthesize categorys;
@synthesize todoEvent;

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
    }
    return self;
}

/*
-(id)init{
	DoLog(DEBUG,@"hsin_init");
	if(self=[super initWithStyle:UITableViewStyleGrouped]){
		MySqlite *mySqlite=[[MySqlite alloc]init];
		
		NSArray *myCategorys=[mySqlite getTodoCategorys];
		self.categorys=myCategorys;
		[myCategorys release];
		[mySqlite release];
		
	}
	return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	//DoLog(DEBUG,@"hsin_viewDidLoad");
	//[self.tableView setStyle:UITableViewStyleGrouped];
	
	MySqlite *mySqlite=[[MySqlite alloc]init];
	
	NSArray *myCategorys=[mySqlite getTodoCategorys];
	self.categorys=myCategorys;
	[myCategorys release];
	[mySqlite release];
	
	
	//self.tableView.backgroundColor=[UIColor colorWithRed:192/255.0 green:96/255.0 blue:0/255.0 alpha:1.0f];
	//self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"calendar_weekly_bg.png"]];
    
	//self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	//self.tableView.backgroundColor=[UIColor clearColor];
	
	self.tableView.backgroundColor = [UIColor clearColor];
	
	if(self.flag==0)
		self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]  initWithTitle:@"新增" style:UIBarButtonItemStyleBordered target:self action:@selector(addCategory:)] autorelease];
	
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	DoLog(DEBUG,@"categoryTableViewController viewWillappear");
	//self.categorys=[[NSArray alloc]init];
	//[self.tableView reloadData];
	
	MySqlite *mySqlite=[[MySqlite alloc]init];
	
	NSArray *myCategorys=[mySqlite getTodoCategorys];
	self.categorys=myCategorys;
	[myCategorys release];
	[mySqlite release];
	
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.categorys count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"分類";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Set up the cell...
    NSUInteger row = [indexPath row];
	
	TodoCategory *myCategory=[categorys objectAtIndex:row];
	
	/*
	CGRect myRect = cell.contentView.frame;
	UIView *myView = [[UIView alloc]initWithFrame:myRect];
	
	myRect.origin.x=50;
	myRect.origin.y=3;
	myRect.size.width=myRect.size.width-50-130;
	myRect.size.height=myRect.size.height-6;
	
	UILabel *myLabel = [[UILabel alloc]initWithFrame:myRect];
	myLabel.text=myCategory.categoryName;
	[myView addSubview:myLabel];
	[myLabel release];
	
	
	NSInteger r = myCategory.categoryColor/1000000;
	NSInteger g = (myCategory.categoryColor%1000000)/1000;
	NSInteger b = (myCategory.categoryColor%1000);
	
	myRect.origin.x=5;
	myRect.origin.y=5;
	myRect.size.width=30;
	myRect.size.height=30;
	myLabel = [[UILabel alloc]initWithFrame:myRect];
	myLabel.backgroundColor=[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
	[myView addSubview:myLabel];
	[myLabel release];

	[cell.contentView addSubview:myView];
	[myView release];
	*/
	
	
    cell.textLabel.text = myCategory.folderName;
    //cell.imageView.image = [self createFolderImage:CGSizeMake(30.0f,30.0f) bgColor:myCategory.colorRgb];
	
	NSString *colorImage=[RuleArray getColorDictionary:myCategory.colorRgb];
	if(self.flag==0){
		if(colorImage!=nil)
			cell.imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"calenfolder_small_%@.png",colorImage]];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}else{
		if(colorImage!=nil){
			cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"calenfolder_320_%@.png",colorImage]]];
			//cell.textLabel.opaque = NO; 
			cell.textLabel.backgroundColor = [UIColor clearColor];
			cell.textLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
		}
	}
	
		
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	NSUInteger row = [indexPath row];
	
	if(self.flag==0){
		CategoryDetailViewController *nextController = [[[CategoryDetailViewController alloc] initWithCategoryId:[[categorys objectAtIndex:row] folderId] nib:@"CategoryDetailView"] autorelease];
		[self.navigationController pushViewController:nextController animated:YES];
	}else{
		[[[todoEvent objectAtIndex:5]  objectAtIndex:0] setString:[NSString stringWithFormat:@"%@#%@#%d",[[categorys objectAtIndex:row] folderId],[[categorys objectAtIndex:row] folderName],[[categorys objectAtIndex:row] colorRgb] ] ];
		[[self parentViewController] viewWillAppear:YES];
		[self.navigationController popViewControllerAnimated:YES];
	}
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[todoEvent release];
	[categorys release];
    [super dealloc];
}

- (UIImage *) createFolderImage:(CGSize) mySize bgColor:(NSInteger) myColor	{
	UIImage *result;
	//UIGraphicsBeginImageContext (size); 
	UIGraphicsBeginImageContext(CGSizeMake(20.0, 20.0));
	
	CGRect myRect=CGRectMake(0, 0, mySize.width, mySize.height);
	
	NSInteger r = myColor/1000000;
	NSInteger g = (myColor%1000000)/1000;
	NSInteger b = (myColor%1000);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f] setFill];
	CGContextFillRect(context,myRect);
	
	result = UIGraphicsGetImageFromCurrentImageContext(); 
	UIGraphicsEndImageContext(); 
	return result; 
} 

-(void) addCategory:(id)sender{
	CategoryDetailViewController *nextController = [[[CategoryDetailViewController alloc] initWithNibName:@"CategoryDetailView" bundle:nil] autorelease];
    [self.navigationController pushViewController:nextController animated:YES];
}

@end

