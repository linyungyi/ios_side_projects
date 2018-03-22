#import "TextFieldCell.h"

@implementation TextFieldCell
@synthesize myTag;
@synthesize customTextField;
@synthesize viewController;

- (IBAction) editDone: (UITextField *) aTextField;
{
	if (self.viewController)
		[self.viewController performSelector:@selector(updateData:forItem:) withObject:aTextField withObject:[NSString stringWithFormat:@"%d",self.myTag]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}

/*
-(void) dealloc{
	[customTextField release];
	[tableViewController release];
	[super dealloc];
}
 */

@end
