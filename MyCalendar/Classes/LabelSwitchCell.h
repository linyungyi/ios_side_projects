#import <UIKit/UIKit.h>

@interface LabelSwitchCell : UITableViewCell {
	NSInteger myTag;
    IBOutlet UISwitch *customSwitch;
	IBOutlet UILabel *customLabel;
	UIViewController *viewController;
}

@property NSInteger myTag;
@property (assign) UISwitch *customSwitch;
@property (assign) UILabel *customLabel;
@property (assign) UIViewController *viewController;
- (IBAction) switchChanged: (UISwitch *) aSwitch;
@end
