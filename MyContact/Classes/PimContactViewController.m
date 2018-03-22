//
//  PimContactViewController.m
//  PimContact
//
//  Created by bko on 2010/2/22.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "PimContactViewController.h"


@implementation PimContactViewController

@synthesize firstName,lastName,people,contactsTableView;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    // Fetch the address book 
	ABAddressBookRef addressBook = ABAddressBookCreate();
	// Search for the person named "Appleseed" in the address book
	//CFArrayRef people = ABAddressBookCopyPeopleWithName(addressBook, CFSTR("Appleseed"));
	CFArrayRef peopleArrayRef=ABAddressBookCopyArrayOfAllPeople(addressBook);
	//CFMutableArrayRef peopleMutable=CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(people), people);
	//[peopleMutable sortUsingFunction:ABPersonComparePeopleByName context:(void*)sortOrdering];
	
	self.people=(NSArray *)peopleArrayRef;
	
	CFRelease(peopleArrayRef);
	
	
	[super viewDidLoad];
	
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	
}

- (void)viewWillAppear:(BOOL)animated
{
	
	[self.contactsTableView reloadData];
}

- (void)dealloc {
	[firstName release];
	[lastName release];
	[people release];
	[contactsTableView release];
    [super dealloc];
}

-(IBAction)showPicker:(id)sender{
	ABPeoplePickerNavigationController *picker=[[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate=self;
	
	[self presentModalViewController:picker animated:YES];
	[picker release];

}
#pragma mark -
#pragma mark ABPeoplePickerNavigationControllerDelegate methods

// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	[self dismissModalViewControllerAnimated:YES];
}

// Displays the information of a selected person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	NSString *name=(NSString *) ABRecordCopyValue(person, kABPersonFirstNameProperty);
	
	self.firstName.text=name;
	[name release];
	
	name=(NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
	self.lastName.text=name;
	[name release];
	
	[self dismissModalViewControllerAnimated:YES];
	
	
	return NO;
}

// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	return NO;
}

#pragma mark -
#pragma mark UITableViewDataSource methods


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	return [people count] ;
	
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"CustomCell";	
	//NSString *debugString=@"tableView:cellForRowAtIndexPath";

	/*UITableViewCell *cell=[tView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}*/
	
	Style6CustomCell *cell=(Style6CustomCell *)[tView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"Style6CustomCell" owner:self options:nil] objectAtIndex:0] ;
	}
	
	
	
	
	ABRecordRef person=CFArrayGetValueAtIndex(people, indexPath.row);
		
	NSString *temp=(NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
	NSString *temp2=(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
	
	UIImage *pImg;
	CFDataRef picRef=ABPersonCopyImageData (person);
	if(picRef!=nil){
		
		pImg = [[UIImage imageWithData:(NSData *)picRef] _imageScaledToSize:CGSizeMake(60.0f, 60.0f) interpolationQuality:1];
		
			
	}else {
		pImg=[UIImage imageNamed:@"p.png"];
	}

	
	//cell.textLabel.text=temp;
	cell.songLabel.text =temp;
	cell.singerLabel.text=temp2;
	//cell.img.image =[UIImage imageNamed:@"p.png"];
	cell.img.image =pImg;
	[temp release];
	[temp2 release];
	
	//CFRelease(people);
	//CFRelease(person);
	
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	// Fetch the address book 
	ABAddressBookRef addressBook = ABAddressBookCreate();
	
	// Search for the person named "Appleseed" in the address book
	//CFArrayRef people2 = ABAddressBookCopyPeopleWithName(addressBook, CFSTR("Appleseed"));
	
	ABRecordRef person=CFArrayGetValueAtIndex(people, indexPath.row);
	
	NSString *lName=(NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
	
	CFArrayRef people2 = ABAddressBookCopyPeopleWithName(addressBook, lName);
	
	[lName release];
	
	// Display "Appleseed" information if found in the address book 
	if ((people2 != nil) && (CFArrayGetCount(people2) > 0))
	{
		
		//NSLog(@"test");
		
		ABRecordRef person = CFArrayGetValueAtIndex(people2, 0);
		ABPersonViewController *picker = [[[ABPersonViewController alloc] init] autorelease];
		picker.personViewDelegate = self;
		picker.displayedPerson = person;
		// Allow users to edit the person’s information
		picker.allowsEditing = YES;
		
		[self.navigationController pushViewController:picker animated:YES];
	}
	
	
	//test *t=[[test alloc]init];
	
	//[self.navigationController pushViewController:t animated: YES];
	
	
}

#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	return NO;
}


@end
