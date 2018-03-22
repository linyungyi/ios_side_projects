//
//  XMLParser.m
//  XML
//
//  Created by iPhone SDK Articles on 11/23/08.
//  Copyright 2008 www.iPhoneSDKArticles.com.
//

#import "XMLParser.h"
#import "Song.h"
#import "Activity.h"
#import "SongSearch.h"
#import "MusicBox.h"
#import "Album.h"

@implementation XMLParser

@synthesize finishedParserArray,currentParseBatch,currentSong,finishedParserDic,tmpArray,currentSearchTitle,currentMusicBox,parserType,currentAlbum,ringtonMember;


- (XMLParser *) initXMLParser {
	
	[super init];
	
	//appDelegate = (MusicAppAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
	if([elementName isEqualToString:@"basic"]||[elementName isEqualToString:@"daylight"]||[elementName isEqualToString:@"night"]||[elementName isEqualToString:@"weekend"]
	   ||[elementName isEqualToString:@"iRank"]||[elementName isEqualToString:@"Keyword"]||[elementName isEqualToString:@"iRecommendSong"]||[elementName isEqualToString:@"Activity"]
	   ||[elementName isEqualToString:@"ActivitySongList"]||[elementName isEqualToString:@"MusicBoxSongs"]||[elementName isEqualToString:@"MusicBoxPromotion"]
	   ||[elementName isEqualToString:@"AlbumPromotion"]||[elementName isEqualToString:@"AlbumSongs"]||[elementName isEqualToString:@"iTopicSearch"]||[elementName isEqualToString:@"PlayList"]) {
		
		//Initialize the array.
		tmpArray=[[NSMutableArray alloc] init];
		//NSLog(@"XMLParser-> parser:didstartElemnt=> %@",elementName);
		
	}else if([elementName isEqualToString:@"Profile"]||[elementName isEqualToString:@"iSearchManagement"]){
		finishedParserDic=[[NSMutableDictionary alloc] init];
		
		//NSLog(@"XMLParser-> parser:didstartElemnt=> %@",elementName);

	}else if([elementName isEqualToString:@"info"]) {	
		//Initialize the Song.
		Song *aSong=[[Song alloc] init];
		self.currentSong=aSong;
		[aSong release];
		
		self.parserType=@"Songs";
		
	}else if([elementName isEqualToString:@"subject"]){
		
		Activity *aActivity=[[Activity alloc] init];
		
		aActivity.beginDate=[attributeDict objectForKey:@"begin_time"];
		aActivity.endDate=[attributeDict objectForKey:@"end_time"];
		aActivity.content=[attributeDict objectForKey:@"content"];
		aActivity.name=[attributeDict objectForKey:@"name"];
		aActivity.img=[attributeDict objectForKey:@"img"];
		aActivity.url=[attributeDict objectForKey:@"url"];
		
		////NSLog(@"Reading id value :%@", aActivity.beginDate);
		////NSLog(@"Reading id value :%@", aActivity.endDate);
		////NSLog(@"Reading id value :%@", aActivity.content);
		////NSLog(@"Reading id value :%@", aActivity.name);
		////NSLog(@"Reading id value :%@", aActivity.img);
		////NSLog(@"Reading id value :%@", aActivity.url);
		//NSLog(@"XmlParser->appDelegate.aActivity %d",[appDelegate.activitys count]);
		
		[tmpArray addObject:aActivity];
		[aActivity release];

	}else if([elementName isEqualToString:@"Item"]){
		tmpArray=[[NSMutableArray alloc] init];
		currentSearchTitle=[attributeDict objectForKey:@"title"];
		
		////NSLog(@"Item title-> %@",currentSearchTitle);
		
	}else if([elementName isEqualToString:@"list"]){
		
		SongSearch *aSongSearch=[[SongSearch alloc] init];
		aSongSearch.title=[attributeDict objectForKey:@"title"];
		aSongSearch.url=[attributeDict objectForKey:@"url"];
		aSongSearch.keyword=[attributeDict objectForKey:@"keyword"];
		//self.currentSongSearch=aSongSearch;
		
		[tmpArray addObject:aSongSearch];
		
	
		
		////NSLog(@"Reading id value-> %@",aSongSearch.title);
		////NSLog(@"Reading id value-> %@",aSongSearch.url);
		[aSongSearch release];
	
	}else if([elementName isEqualToString:@"MusicBoxProfile"]){
		MusicBox *aMusicBox =[[MusicBox alloc] init];
		self.currentMusicBox=aMusicBox;
		[aMusicBox release];
		self.parserType=@"MusicBox";
	}else if([elementName isEqualToString:@"iAlbumProfile"]){
		Album *aAlbum=[[Album alloc] init];
		self.currentAlbum=aAlbum;
		[aAlbum release];
		self.parserType=@"Album";
	}else if([elementName isEqualToString:@"member"]){
	
	self.parserType=@"Rington";
	}
	
	//NSLog(@"Processing Element: %@", elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string { 
	
	if(!currentElementValue) 
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];
	
	//NSLog(@"Processing Value: %@", currentElementValue);
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	
	if([elementName isEqualToString:@"Activity"]||[elementName isEqualToString:@"iRank"]||[elementName isEqualToString:@"Keyword"]||[elementName isEqualToString:@"iRecommendSong"]
	   ||[elementName isEqualToString:@"ActivitySongList"]||[elementName isEqualToString:@"MusicBoxSongs"]||[elementName isEqualToString:@"MusicBoxPromotion"]
	   ||[elementName isEqualToString:@"AlbumPromotion"]||[elementName isEqualToString:@"AlbumSongs"]||[elementName isEqualToString:@"iTopicSearch"]||[elementName isEqualToString:@"PlayList"]){
		self.finishedParserArray=tmpArray;
		tmpArray=nil;
		
		////NSLog(@"End elementName-> %@ ,Count-> %d",elementName,finishedParserArray.count);
		return;
	}else if([elementName isEqualToString:@"basic"]||[elementName isEqualToString:@"daylight"]||[elementName isEqualToString:@"night"]||[elementName isEqualToString:@"weekend"]){
		
		[finishedParserDic setValue:tmpArray forKey:elementName];
		////NSLog(@"finishedParserDic count-> %d",finishedParserDic.count);
		tmpArray=nil;
		return;
	}else if ([elementName isEqualToString:@"Item"]){
		[finishedParserDic setValue:tmpArray forKey:currentSearchTitle];
		
		////NSLog(@"search finishedParserDic->%d",finishedParserDic.count);
		
		tmpArray=nil;
		
		return;
	
	}
		
	//Parser a SongSearch
	/*if([elementName isEqualToString:@"list"]){
		[tmpArray addObject:currentSongSearch];
		currentSongSearch=nil;
		
		NSLog(@"tmpSongSearchArray Number-> %d",tmpArray.count);
	}*/
	
	//Parse a Song info, MusicBoxProfile and Album
	if([elementName isEqualToString:@"info"]){
		[tmpArray addObject:currentSong];
		currentSong=nil;
		
		////NSLog(@"tmpSongsArray Number->%d",tmpArray.count);
	
	}else if([elementName isEqualToString:@"MusicBoxProfile"]){
		[tmpArray addObject:currentMusicBox];
		currentMusicBox=nil;
		
		////NSLog(@"tmpMusicBoxArray Number->%d",tmpArray.count);
	
	}else if([elementName isEqualToString:@"iAlbumProfile"]){
		[tmpArray addObject:currentAlbum];
		currentAlbum=nil;
		////NSLog(@"tmpAlbumArray Number->%d",tmpArray.count);
		
	//}else if(![elementName isEqualToString:@"grade"] && ![elementName isEqualToString:@"past"]&&![elementName isEqualToString:@"cd"]){
	}else if(![elementName isEqualToString:@"cd"]&&![elementName isEqualToString:@"sourcetype"]&&![elementName isEqualToString:@"mv"]){
		//NSLog(@"test-> %@, elementName->%@",parserType,elementName);
		if([parserType isEqualToString:@"Songs"])
		   [currentSong setValue:currentElementValue forKey:elementName];
		else if([parserType isEqualToString:@"MusicBox"])
		   [currentMusicBox setValue:currentElementValue forKey:elementName];
		else if([parserType isEqualToString:@"Album"])
		   [currentAlbum setValue:currentElementValue forKey:elementName];
		else if([parserType isEqualToString:@"Rington"]){
			self.ringtonMember=currentElementValue;
			NSLog(@"member-> %@",self.ringtonMember);		
			parserType=nil;
		}
		
	}
		
	currentElementValue = nil;
}

- (void) dealloc {	
	
	[currentSong release];
	[currentElementValue release];
	[finishedParserArray release];
	[currentParseBatch release];
	[finishedParserDic release];
	[tmpArray release];
	//[currentSongSearch release];
	[currentSearchTitle release];
	[currentMusicBox release];
	[parserType release];
	[currentAlbum release];
	[ringtonMember release];
	[super dealloc];
}



@end
