//
//  LyricsParser.m
//
//  Created by gagaga on 08-3-6.
//  Copyright 2008 www.cocoachina.com. some rights reserved.
//

#import "LyricsParser.h"


@implementation LyricsParser

-(void) InitWithString:(NSString *)theLyricsContent
{
	//NSLog(@"theLyricsContent:%@",theLyricsContent);
	file =[[NSString alloc]
	       initWithString:theLyricsContent];
	lyricsdict=[[NSMutableDictionary alloc] initWithCapacity:500];
	results= [file componentsSeparatedByString:@"\\r\\n"];
	for (NSString *s in results)
	{
		//NSLog(@"InitWithString:%@",s);
		dict=[self splitlrc:s];
		[lyricsdict addEntriesFromDictionary:dict];
	}
	sortedKeysArray=[[NSMutableArray alloc] 
					 initWithArray: [lyricsdict keysSortedByValueUsingSelector:
									 @selector(localizedCaseInsensitiveCompare:)]];
	[sortedKeysArray sortUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
	LyricsContent=[NSString stringWithString:file];
}
-(void) InitWithFilename:(NSString *)theLyricsFile
{//NSLog(@"InitWithFilename =============================: %@\n",theLyricsFile);
	NSString *filepath = [NSString stringWithString:theLyricsFile]; 
	//Get file into string
	NSError *error;
	file =[[NSString alloc]
	       initWithContentsOfFile:filepath
	       encoding:CFStringConvertEncodingToNSStringEncoding( kCFStringEncodingMacChineseTrad )//kCFStringEncodingBig5_HKSCS_1999  ,kCFStringEncodingGB_18030_2000
	       error:&error];
	//NSLog(@"file:%@",file);
	lyricsdict=[[NSMutableDictionary alloc] initWithCapacity:500];
	results= [file componentsSeparatedByString:@"\n"];
	for (NSString *s in results)
	{
		//NSLog(@"InitWithFilename:%@",s);
		dict=[self splitlrc:s];
		[lyricsdict addEntriesFromDictionary:dict];
	}
	sortedKeysArray=[[NSMutableArray alloc] 
					 initWithArray: [lyricsdict keysSortedByValueUsingSelector:
									 @selector(localizedCaseInsensitiveCompare:)]];
	[sortedKeysArray sortUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
	LyricsContent=[NSString stringWithString:file];
}

- (void)getLyrics:(NSString *)theTime:(NSString *)timeFormat
{
	//NSDateFormatter *dateFormat = [[NSDateFormatter alloc]
	//							   initWithDateFormat: timeFormat  allowNaturalLanguage: NO]; 
	NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
	//[dateFormat setTimeStyle:NSDateFormatterNoStyle];
	//[dateFormat setDateStyle:NSDateFormatterMediumStyle];
	[dateFormat setDateFormat:timeFormat];
	
	//NSDate *date = [NSDate date];
	
	NSString *playingtime=[[NSString alloc] initWithString:theTime]; 
	NSString *lyrictime=@"";
	NSRange endrange;
	NSInteger lenghnumber;
	NSInteger startnumber;

	//NSMutableString *returnLyrics=[[NSMutableString alloc] initWithCapacity:500];
	//NSMutableString *nextLyrics=[[NSMutableString alloc] initWithCapacity:500];

	int indexofsortedKeysArray=0;
	if([playingtime isEqualToString:@"00:00"]){
		self.CurrentLyrics=@"";
		self.NextLyrics=@"";
	}
		
	for (indexofsortedKeysArray=0;indexofsortedKeysArray<[sortedKeysArray count];indexofsortedKeysArray++)
	{
		lyrictime=[sortedKeysArray objectAtIndex:indexofsortedKeysArray];
		endrange=[lyrictime rangeOfString:@"."];
		lenghnumber=endrange.location;
		startnumber=endrange.location-endrange.location;
		NSRange lyricsub={startnumber,lenghnumber};
		lyrictime=[lyrictime substringWithRange:lyricsub];
		//NSLog(@"lyrictime:%@", lyrictime);
		
		//NSLog(@"playingtime:%@", playingtime);
		if([lyrictime isEqualToString:playingtime])
		//if ([[dateFormat dateFromString:[sortedKeysArray objectAtIndex:indexofsortedKeysArray]] compare:[dateFormat dateFromString:playingtime]]==NSOrderedAscending)
		{
			//returnLyrics=[lyricsdict objectForKey:[sortedKeysArray objectAtIndex:indexofsortedKeysArray]];
			//nextLyrics=[lyricsdict objectForKey:[sortedKeysArray objectAtIndex:indexofsortedKeysArray+1]];
			self.CurrentLyrics=[lyricsdict objectForKey:[sortedKeysArray objectAtIndex:indexofsortedKeysArray]];
			self.NextLyrics=[lyricsdict objectForKey:[sortedKeysArray objectAtIndex:indexofsortedKeysArray+1]];
		}
	}
	
	//self.NextLyrics=nextLyrics;
	//self.CurrentLyrics=returnLyrics;
}
- (NSDictionary *)splitlrc:(NSString *)lrc
{
	NSMutableString *tmplrc=[[NSMutableString alloc] initWithString:lrc];
	[tmplrc replaceOccurrencesOfString:@"[" withString:@"" options:NSCaseInsensitiveSearch  range:NSMakeRange(0,[tmplrc length])];
	NSArray *split;
	NSMutableArray *times=[NSMutableArray arrayWithCapacity:20];
	NSMutableArray *contents=[NSMutableArray arrayWithCapacity:20];
	split=[tmplrc componentsSeparatedByString:@"]"];
	int i=0;
	for (NSString *s in split)
	{
		if (i<[split count]-1){
			[times addObject:s];
			//NSLog(@"times:%@",s);
			[contents addObject:[split lastObject]];
			//NSLog(@"contents:%@",[split lastObject]);
			i++;
		}
	}
	NSDictionary *dictionary;
	dictionary	=[[NSDictionary alloc] initWithObjects:contents forKeys:times];
	return dictionary;
}
@synthesize CurrentStopTime;
@synthesize Lyrics_by;
@synthesize LyricsDictionary;
@synthesize Lyrics_ar;
@synthesize CurrentStartTime;
@synthesize CurrentLyrics;
@synthesize CurrentPlayTime;
@synthesize Lyrics_offset;
@synthesize Lyrics_al;
@synthesize Lyrics_ti;
@synthesize NextLyrics;
@synthesize LyricsContent;
@end
