//
//  SettingTestViewController.m
//  MyCalendar
//
//  Created by Admin on 2010/4/8.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingTestViewController.h"
#import "ProfileUtil.h"
#import "DateTimeUtil.h"
#import "InterfaceUtil.h"

@implementation SettingTestViewController
@synthesize sTextField,aTextField,urlLabel;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	NSString *tmpString=[ProfileUtil stringForKey:SERVICEID];
	if(tmpString==nil)
		tmpString=@"";
	
	self.sTextField.text=tmpString;
	
	tmpString=[ProfileUtil stringForKey:AUTHID];
	if(tmpString==nil)
		tmpString=@"";
	
	self.aTextField.text=tmpString;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *tmpString=[ProfileUtil stringForKey:SERVICEID];
	if(tmpString==nil)
		tmpString=@"";
	
	self.sTextField.text=tmpString;
	
	tmpString=[ProfileUtil stringForKey:AUTHID];
	if(tmpString==nil)
		tmpString=@"";
	
	self.aTextField.text=tmpString;
	
	NSMutableString *urlString=[[NSMutableString alloc]init];
	[urlString appendFormat:@"%@\n",SYNCINITURL];
	[urlString appendFormat:@"%@\n",FOLDERSYNCURL];
	[urlString appendFormat:@"%@\n",CONTENTSYNCURL];
	[urlString appendFormat:@"%@\n",RECURRENCESYNCURL];
	[urlString appendFormat:@"%@\n",BACKUPURL];
	[urlString appendFormat:@"%@\n",BACKUPLISTURL];
	[urlString appendFormat:@"%@\n",RESTOREURL];
	[urlString appendFormat:@"%@\n",RESTORELISTURL];	
	
	
	
	
	[urlString appendFormat:@"uniqueIdentifier=%@ name=%@\n",[[UIDevice currentDevice] uniqueIdentifier],[[UIDevice currentDevice] name]];
	[urlString appendFormat:@"systemName=%@ version=%@ model=%@\n",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion],[[UIDevice currentDevice] model]];
	[urlString appendFormat:@"localizedModel=%@ lang=%@ phoneNo=%@\n",[[UIDevice currentDevice] localizedModel],[[NSLocale preferredLanguages] objectAtIndex:0],[[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"]];	
	
	
	self.urlLabel.text=urlString;
	[urlString release];
	
	self.title=@"For Test";
	self.view.backgroundColor = [UIColor clearColor];
	self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc]initWithTitle:@"儲存" style:UIBarButtonItemStyleBordered target:self action:@selector(doJob:)] autorelease];
}


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


- (void)dealloc {
	[urlLabel release];
	[sTextField release];
	[aTextField release];
    [super dealloc];
}

-(void) doJob:(id)sender{
	
	//[self doTest];
	
	if([self.sTextField.text length]>0)
		[ProfileUtil setString:self.sTextField.text forKey:SERVICEID];
	if([self.aTextField.text length]>0)
		[ProfileUtil setString:self.aTextField.text forKey:AUTHID];
	
	[[self parentViewController] viewWillAppear:YES];
	[self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}

-(void) doTest{
		NSString *serviceId=[ProfileUtil stringForKey:SERVICEID];
		NSString *authId=[ProfileUtil stringForKey:AUTHID];
				
		NSMutableString *requestXML=[[NSMutableString alloc]init];
		//[requestXML setString:[NSString stringWithFormat:@"%@?%@",BACKUPLISTURL,[DateTimeUtil getUrlDateString]]];
		[requestXML setString:@"http://chtblogqa.cht.com.tw/mbr/testForm.jsp"];
		NSURL *backupListUrl = [NSURL URLWithString:requestXML];
		NSMutableURLRequest *postRequest;
		NSData *data;
		
		NSHTTPURLResponse *returnResponse;
		NSError *returnError;
		int statusCode;
		NSDictionary *header;
		
		/*查詢備份紀錄*/
		//adding header information:
		
		postRequest = [NSMutableURLRequest requestWithURL:backupListUrl];
		[postRequest setHTTPMethod:@"POST"];
		[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
	
		[InterfaceUtil setHeader:postRequest];	
	
		//[postRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
		//[postRequest addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
		//[postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		//[postRequest setValue:@"300" forHTTPHeaderField:@"Keep-Alive"];
	
	for(int i=0;i<10;i++){
		[requestXML setString:@"xml=<calendar_backup_list_req>"];
		[requestXML appendString:[NSString stringWithFormat:@"<auth_id>%@</auth_id>",authId]];
		[requestXML appendString:[NSString stringWithFormat:@"<service_id>%@</service_id>",serviceId]];
		[requestXML appendString:@"</calendar_backup_list_req>"];
		DoLog(INFO,@"requestXML=%@",requestXML);
		
		data = [[NSData alloc] initWithData:[requestXML dataUsingEncoding:NSUTF8StringEncoding]];
		[postRequest setHTTPBody:data];
		[data release];
		
		
		returnResponse = nil;
		returnError = nil;
		data = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&returnResponse error:&returnError];
		statusCode = returnResponse.statusCode;
		DoLog(INFO,@"statusCode=%d",statusCode);
		if(statusCode==200){
			header = [postRequest allHTTPHeaderFields];
			DoLog(INFO,@"request=%@",header);
			
			header = [returnResponse allHeaderFields];
			DoLog(INFO,@"response=%@",header);
		}
		[NSThread sleepForTimeInterval:5.0f];
	}	
		[requestXML release];
		
		
	
}

@end
