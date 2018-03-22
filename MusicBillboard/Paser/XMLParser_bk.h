//
//  XMLParser.h
//  XML
//
//  Created by iPhone SDK Articles on 11/23/08.
//  Copyright 2008 www.iPhoneSDKArticles.com.
//

#import <UIKit/UIKit.h>


@class MusicAppAppDelegate, Song,SongSearch,MusicBox,Album;

@interface XMLParser : NSObject {

	
	NSMutableArray *finishedParserArray;	
	NSMutableArray *tmpArray;
	
	NSMutableString *currentElementValue;
	NSMutableArray *currentParseBatch;
	Song *currentSong;
	//SongSearch *currentSongSearch;
	MusicBox *currentMusicBox;
	Album *currentAlbum;
	
	Boolean accumulatingParsedCharacterData;
	
	NSMutableDictionary *finishedParserDic;
	
	NSString *currentSearchTitle;
	
	NSString *parserType;
	
	NSString *ringtonMember;
	
	
}

@property (nonatomic,retain) NSMutableArray *finishedParserArray;
@property (nonatomic,retain) NSMutableArray *tmpArray;

@property (nonatomic,retain) NSMutableArray *currentParseBatch;
@property (nonatomic,retain) Song *currentSong;
//@property (nonatomic,retain) SongSearch *currentSongSearch;
@property (nonatomic,retain) Album *currentAlbum;
@property (nonatomic,retain) NSMutableDictionary *finishedParserDic;
@property (nonatomic,retain) NSString *currentSearchTitle;
@property (nonatomic,retain) MusicBox *currentMusicBox;
@property (nonatomic,retain) NSString *parserType;
@property (nonatomic,retain) NSString *ringtonMember;


- (XMLParser *) initXMLParser;

@end
