//
//  ListEventViewController.h
//  MyCalendar
//
//  Created by Admin on 2010/3/9.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarRootViewController.h";
#import "ListTableView.h";

@interface ListEventViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView *myTableView;
	CalendarRootViewController *calendarRootViewController;
	NSInteger theDay;
	NSDate *now;
	NSMutableArray *dataArray;
	NSMutableArray *titleArray;
	UIView *contentView;
	UIImageView *dayView;
	UILabel *dayViewMonthLabel;
	UILabel *dayViewDayLabel;
	UILabel *dayViewWeeknameLabel;
	UIView *monthView;
	NSInteger noDataFlag;
	UIImageView *listBgView;
	UIImageView *listBtView;
	ListTableView *listTableView;
	UIButton *closeButton;
	UIButton *dragButton;
	NSMutableArray *listArray;
}
@property (nonatomic,retain) IBOutlet UITableView *myTableView;
@property (nonatomic,retain) CalendarRootViewController *calendarRootViewController;
@property (nonatomic) NSInteger theDay;
@property (nonatomic,retain) NSDate *now;
@property (nonatomic,retain) NSMutableArray *dataArray;
@property (nonatomic,retain) NSMutableArray *titleArray;
@property (nonatomic,retain) UIView *contentView;
@property (nonatomic,retain) UIImageView *dayView;
@property (nonatomic,retain) UILabel *dayViewMonthLabel;
@property (nonatomic,retain) UILabel *dayViewDayLabel;
@property (nonatomic,retain) UILabel *dayViewWeeknameLabel;
@property (nonatomic,retain) UIView *monthView;
@property (nonatomic) NSInteger noDataFlag;
@property (nonatomic,retain) UIImageView *listBgView;
@property (nonatomic,retain) UIImageView *listBtView;
@property (nonatomic,retain) ListTableView *listTableView;
@property (nonatomic,retain) UIButton *closeButton;
@property (nonatomic,retain) UIButton *dragButton;
@property (nonatomic,retain) NSMutableArray *listArray;

- (void) refreshData;
- (UIImage *) createFolderImage:(CGSize) mySize bgColor:(NSInteger) myColor;
- (void) refreshViewWithPushDirection:(NSInteger) type;
- (void) showNext;
- (void) showPrevious;
- (void) refreshLabel;
- (void) drawMonth;
- (void) showList;
- (void) closeList;
- (void) refreshListArray;
@end
