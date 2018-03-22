//
//  FourthTabRootViewController.h
//  Music01
//
//  Created by albert on 2009/6/24.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FourthTabViewController01;
@class Music01AppDelegate;

@interface FourthTabRootViewController : UIViewController <UINavigationBarDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
	IBOutlet UITableView				*myTableView;
	NSMutableArray						*myTableSection;
	NSMutableDictionary					*mySectionRow;
	//FourthTabViewController01			*fourthTabViewController01;
	
	IBOutlet UIActivityIndicatorView	*activityIndicator;
	IBOutlet UISearchBar				*sBar;//search bar
	NSString							*myQuery;
	//NSMutableArray					*dataSource; //will be storing all the data
	//NSMutableArray					*tableData;//will be storing data that will be displayed in table
	//NSMutableArray					*searchedData;//will be storing data matching with the search string
	UIColor								*defaultTintColor;
	Music01AppDelegate					*appDelegate;
	NSURLConnection						*searchConnection;
	NSMutableData						*searchData;
}
@property (nonatomic, retain) UITableView					*myTableView;
@property (nonatomic, retain) NSMutableArray				*myTableSection;
@property (nonatomic, retain) NSMutableDictionary			*mySectionRow;
//@property (nonatomic, retain) FourthTabViewController01		*fourthTabViewController01;
@property (nonatomic, retain) UISearchBar					*sBar;
@property (nonatomic, retain) NSString						*myQuery;
@property (nonatomic, retain) UIActivityIndicatorView		*activityIndicator;
@property (nonatomic,retain)  NSURLConnection				*searchConnection;
@property (nonatomic,retain)  NSMutableData					*searchData;
-(void)initDataSource;
-(void)initAppDelegate;
-(void)showResult:(NSString *)strQuery;
-(void) startAnimation;
-(void) stopAnimation;
@end
