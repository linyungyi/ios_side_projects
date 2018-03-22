#import "LabelSwitchCell.h"

@implementation LabelSwitchCell
@synthesize myTag;
@synthesize customSwitch;
@synthesize customLabel;
@synthesize viewController;

- (IBAction) switchChanged: (UISwitch *) aSwitch;
{
	if (self.viewController)
		[self.viewController performSelector:@selector(updateSwitch:forItem:) withObject:aSwitch withObject:[NSString stringWithFormat:@"%d",self.myTag]];
}
@end
