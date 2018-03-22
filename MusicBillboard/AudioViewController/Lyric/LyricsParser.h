//
//  LyricsParser.m
//
//  Created by gagaga on 08-3-6.
//  Copyright 2008 www.cocoachina.com. some rights reserved.
//


#import <UIKit/UIKit.h>

@interface LyricsParser : NSObject {
	NSString *CurrentLyrics;
	NSString *CurrentPlayTime;
	NSString *CurrentStartTime;
	NSString *NextLyrics;
	NSString *CurrentStopTime;
	NSDictionary *LyricsDictionary;
	NSString *Lyrics_ar;
	NSString *Lyrics_ti;
	NSString *Lyrics_al;
	NSString *Lyrics_by;
	NSString *Lyrics_offset;
	NSString *file;
	NSArray *results;
	NSDictionary *dict;
	NSMutableDictionary *lyricsdict;
	NSMutableArray  *sortedKeysArray;
	NSString *LyricsContent;
}
-(void) InitWithFilename:(NSString *)theLyricsFile;
-(void) InitWithString:(NSString *)theLyricsContent;
- (void)getLyrics:(NSString *)theTime:(NSString *)timeFormat;
- (NSDictionary *)splitlrc:(NSString *)lrc;

@property (retain) NSString *Lyrics_ar;
@property (retain) NSString *CurrentStartTime;
@property (retain) NSString *Lyrics_by;
@property (retain) NSString *CurrentLyrics;
@property (retain) NSString *Lyrics_al;
@property (retain) NSString *CurrentPlayTime;
@property (retain) NSDictionary *LyricsDictionary;
@property (retain) NSString *Lyrics_offset;
@property (retain) NSString *CurrentStopTime;
@property (retain) NSString *Lyrics_ti;
@property (retain) NSString *NextLyrics;
@property (copy) NSString *LyricsContent;
@end
