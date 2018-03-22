//
//  RuleArray.m
//  MyCalendar
//
//  Created by Admin on 2010/3/19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RuleArray.h"


@implementation RuleArray
@synthesize keepRule1,keepRule2,redoRule1,redoRule2,redoRule3,syncRule1,syncRule2;
@synthesize autoRule1,autoRule2,notifyRule1,notifyRule2;

- (id)init{
	if (self = [super init]) {
		NSArray *myArray = [[NSArray alloc]initWithObjects:@"1個月內的事件",@"3個月內的事件",@"6個月內的事件",@"1年內的事件",@"2年內的事件",@"全部事件",nil];
		self.keepRule1=myArray;
		[myArray release];
		myArray = [[NSArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5",@"9",nil];
		self.keepRule2=myArray;
		[myArray release];
		
		myArray = [[NSArray alloc]initWithObjects:@"不重複",@"每天",@"每週",@"每月",@"每年",nil];
		self.redoRule1=myArray;
		[myArray release];
		myArray = [[NSArray alloc]initWithObjects:@"-1",@"0",@"1",@"2",@"5",nil];
		self.redoRule2=myArray;
		[myArray release];
		myArray = [[NSArray alloc]initWithObjects:@"-1",@"1",@"7",@"30",@"365",nil];
		self.redoRule3=myArray;
		[myArray release];
		
		myArray=[[NSArray alloc]initWithObjects:@"以手機為主",@"以伺服器為主",nil];
		self.syncRule1=myArray;
		[myArray release];
		myArray = [[NSArray alloc]initWithObjects:@"C",@"S",nil];
		self.syncRule2=myArray;
		[myArray release];	
		
		myArray = [[NSArray alloc]initWithObjects:@"關閉",@"5分鐘",@"10分鐘",@"20分鐘",@"30分鐘",@"1小時",nil];
		self.autoRule1=myArray;
		[myArray release];
		myArray = [[NSArray alloc]initWithObjects:@"-1",@"5",@"10",@"20",@"30",@"60",nil];
		self.autoRule2=myArray;
		[myArray release];
		
		myArray = [[NSArray alloc]initWithObjects:@"關閉",@"5分鐘",@"15分鐘",@"30分鐘",@"1小時",nil];
		self.notifyRule1=myArray;
		[myArray release];
		myArray = [[NSArray alloc]initWithObjects:@"-1",@"5",@"15",@"30",@"60",nil];
		self.notifyRule2=myArray;
		[myArray release];
	}
	return self;
}

-(NSInteger) getKeepRowNo:(NSInteger) value{
	NSInteger result=[keepRule1 count]-1;
	int i=0;
	for(i=0;i<[keepRule2 count];i++){
		if([[keepRule2 objectAtIndex:i]intValue]==value){
			result=i;
			break;
		}
	}
	return result;
}

-(NSInteger) getSyncRowNo:(NSString *) value{
	NSInteger result=0;
	int i=0;
	for(i=0;i<[syncRule2 count];i++){
		if([[syncRule2 objectAtIndex:i] isEqualToString:value]){
			result=i;
			break;
		}
	}
	return result;
}

-(NSInteger) getRedoRowNo:(NSInteger) value{
	NSInteger result=0;
	int i=0;
	for(i=0;i<[redoRule2 count];i++){
		if([[redoRule2 objectAtIndex:i]intValue]==value){
			result=i;
			break;
		}
	}
	return result;
}

-(NSInteger) getAutoRowNo:(NSInteger) value{
	NSInteger result=0;
	int i=0;
	for(i=0;i<[autoRule2 count];i++){
		if([[autoRule2 objectAtIndex:i]intValue]==value){
			result=i;
			break;
		}
	}
	return result;
}

-(NSInteger) getNotifyRowNo:(NSInteger) value{
	NSInteger result=0;
	int i=0;
	for(i=0;i<[notifyRule2 count];i++){
		if([[notifyRule2 objectAtIndex:i]intValue]==value){
			result=i;
			break;
		}
	}
	return result;
}



- (void) dealloc{
	[notifyRule1 release];
	[notifyRule2 release];
	[keepRule1 release];
	[keepRule2 release];
	[syncRule1 release];
	[syncRule2 release];
	[redoRule1 release];
	[redoRule2 release];
	[redoRule3 release];
	[autoRule1 release];
	[autoRule2 release];
	[super dealloc];
}


+(NSString *) getColorDictionary:(NSInteger) key{
	/*
	NSDictionary *colorDictionary=[[NSDictionary alloc] initWithObjectsAndKeys:
								@"applegreen",@"111196084",@"blue",@"104187255",@"brown",@"254170108",
								@"cyan",@"110225222",@"gray",@"177177177",@"green",@"111196084",
								@"orange",@"255147042",@"pink",@"253186217",@"purple",@"211163255",
								@"purpledeep",@"253156203",@"red",@"250149171",@"yellow",@"254254051",nil];
	*/
	NSDictionary *colorDictionary=[[NSDictionary alloc] initWithObjectsAndKeys:
								   @"purple",@"1",@"orange",@"2",@"blue",@"3",
								   @"yellow",@"4",@"green",@"5",@"red",@"6",
								   @"pink",@"7",@"brown",@"8",@"cyan",@"9",
								   @"applegreen",@"10",@"gray",@"11",@"purpledeep",@"12",nil];
	
	
	NSString *myKey=[NSString stringWithFormat:@"%d",key];
	//DoLog(INFO,@"%@ %d",myKey,key);
	NSString *myValue=[colorDictionary objectForKey:myKey];
	//DoLog(INFO,@"%@",myValue);
	/*
	if(myValue==nil)
		myValue=@"yellow";
	*/
	[colorDictionary release];
	
	return myValue;
}

+(NSArray *) getColorArray{
	/*
	NSArray *colorArray=[[[NSArray alloc] initWithObjects:
						  @"111196084",@"104187255",@"254170108",
						  @"110225222",@"177177177",@"111196084",
						  @"255147042",@"253186217",@"211163255",
						  @"253156203",@"250149171",@"254254051",nil]autorelease];
	*/
	NSArray *colorArray=[[[NSArray alloc] initWithObjects:
						  @"000000001",@"000000002",@"000000003",
						  @"000000004",@"000000005",@"000000006",
						  @"000000007",@"000000008",@"000000009",
						  @"000000010",@"000000011",@"000000012",nil]autorelease];
	
	return colorArray;
}

+(NSString *) getEventIcon:(NSInteger) key{
	NSDictionary *iconDictionary=[[NSDictionary alloc] initWithObjectsAndKeys:
								   @"car",@"1",@"note",@"2",@"movie",@"3",
								   @"shopping",@"4",@"celebrate",@"5",@"work",@"6",
								   @"car",@"7",@"note",@"8",@"movie",@"9",
								   @"shopping",@"10",@"celebrate",@"11",@"work",@"12",nil];
	
	NSString *myKey=[NSString stringWithFormat:@"%d",key];
	NSString *myValue=[iconDictionary objectForKey:myKey];
	[iconDictionary release];
	
	return myValue;
}

+(NSArray *) getEventIconArray{
	
	NSArray *colorArray=[[[NSArray alloc] initWithObjects:
						  @"1",@"2",@"3",
						  @"4",@"5",@"6",
						  @"7",@"8",@"9",
						  @"10",@"11",@"12",nil]autorelease];
	
	return colorArray;
}

@end
