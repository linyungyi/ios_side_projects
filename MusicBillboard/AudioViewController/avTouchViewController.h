


#import <UIKit/UIKit.h>
#import "URLXmlConnection.h"
#import "LyricViewController.h"

#define kTimeComponent 0
#define kGroupComponent 1
#define showLyricButtonIndex 2
#define hiddenLyricButtonIndex 3
#define LyricContentIndex 4

@class avTouchController,Music01AppDelegate;
//@class Music01AppDelegate;

@interface avTouchViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource,URLXmlConnectionDelegate>{

	IBOutlet avTouchController			*controller;
	Music01AppDelegate					*appDelegate;
	
	BOOL								showLyric;
	NSData								*xmlData;
	NSArray								*pickerViewArray;
	NSArray								*timeTypes;
	NSArray								*groupTypes;
	NSString							*sourcetype;
	UIAlertView							*waitAlert;
	NSDictionary						*titleMap;
	NSDictionary						*ruleMap;
	UIPickerView						*rbtPicker;
	UIActionSheet						*downloadActionSheet;
	UIActionSheet						*timeActionSheet;
	UIActionSheet						*groupActionSheet;
	NSMutableString						*lyricContent;
	NSMutableDictionary					*myDictionary;
	NSMutableDictionary					*configMap;
	
	LyricViewController					*lyricViewController;
    CGPoint lastLocation;
}
@property (nonatomic, retain) NSMutableDictionary		*myDictionary;
@property (nonatomic, retain) UIPickerView				*rbtPicker;
@property (nonatomic, retain) NSArray					*pickerViewArray;
@property (nonatomic, retain) NSArray					*timeTypes;
@property (nonatomic, retain) NSArray					*groupTypes;
@property (nonatomic, retain) NSData					*xmlData;
@property (nonatomic, retain) NSDictionary				*titleMap;
@property (nonatomic, retain) NSDictionary				*ruleMap;
@property (nonatomic, retain) NSMutableDictionary		*configMap;
@property (nonatomic, retain) UIAlertView				*waitAlert;
@property (nonatomic, retain) NSString					*sourcetype;
@property (nonatomic, retain) NSMutableString			*lyricContent;
@property (nonatomic, retain) LyricViewController		*lyricViewController;

-(void)setDictionary:(NSMutableDictionary *)theDictionary;
//-(void)setSourcetype:(NSString *)type;

@end

