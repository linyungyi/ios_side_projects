#import <UIKit/UIKit.h>

@interface TextFieldCell : UITableViewCell <UITextFieldDelegate>{
	NSInteger myTag;
    IBOutlet UITextField *customTextField;
	UIViewController *viewController;
}
@property (assign) NSInteger myTag;
@property (assign) UITextField *customTextField;
@property (assign) UIViewController *viewController;
- (IBAction) editDone: (UITextField *) aTextField;
@end
