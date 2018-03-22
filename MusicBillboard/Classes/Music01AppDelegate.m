//
//  Music01AppDelegate.m
//  Music01
//
//  Created by albert on 2009/6/17.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "Music01AppDelegate.h"
#import "URLCacheAlert.h"
#import "Constants.h"
#import "XMLParser.h"
#import "Song.h"
#import "MusicBox.h"
#import "Album.h"

@interface NSObject (PrivateMethods)

//- (void) startAnimation;
//- (void) stopAnimation;
- (void) initCache;
- (void) clearCache;
- (void) listCache;

@end

@implementation Music01AppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize dataPath;
@synthesize WSArray;
@synthesize singleList;
@synthesize musicboxList;
@synthesize cdList;
@synthesize imgCacheDictionary;
@synthesize rTotalList;
@synthesize rMaleList;
@synthesize rFemaleList;
@synthesize rGroupList;
@synthesize rTaiwanList;
@synthesize rJapanList;
@synthesize rWesternList;
@synthesize rMoodList;
@synthesize activityList;
@synthesize searchTopicList;
@synthesize cdSongsList;
@synthesize musicboxSongsList;
@synthesize activitySongList;
@synthesize	userProfile;
@synthesize	rbtMember;
@synthesize mediaPlayerPath;

//mysong------------
@synthesize playlistDic,serverlistDic;
//--------------------

-(id)init{
	[self initApp];
	return [super init];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
	
	if([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault)
	{
		//self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	}else if([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleBlackOpaque)
	{
		//self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque ;
		//UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"default.png"]];
		//img.frame=CGRectMake(0, 50, img.frame.size.width, img.frame.size.height);
		//[window addSubview:img];
		//[img release];
		window.backgroundColor = [UIColor blackColor];
	}else if([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleBlackTranslucent)
	{
		//self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent ;
	}
	
	//[self startAnimation];
	// Override point for customization after application launch

	[window addSubview:[tabBarController view]];
    [window makeKeyAndVisible];



}

-(void)initApp {
	
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WebServices" ofType:@"plist"];
    if (path) {
		NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
        self.WSArray = [[NSMutableArray alloc] init];
        for (NSString *element in array) {
            [self.WSArray addObject:[NSURL URLWithString:element]];
        }
		[array release];
    }	
	
	[self initCache];
	[self initPlayerCache];
	[self initDataSource:RecommandSingleSong orLink:nil withData:nil];
	[self initDataSource:RecommandAlbum orLink:nil withData:nil];
	[self initDataSource:RecommandMusicBox orLink:nil withData:nil];
	//[self initDataSource:RankTotal orLink:nil withData:nil];
	//[self initDataSource:RankMaleArtist orLink:nil withData:nil];
	//[self initDataSource:RankFemaleArtist orLink:nil withData:nil];
	//[self initDataSource:Activities orLink:nil withData:nil];
}

-(void)initDataSource:(int)forKey orLink:(NSString *)strLink withData:(NSData *)theData{
	NSString *debugString;
	debugString=@"initDataSource:forKey";
	NSURL *myURL;
	NSXMLParser *xmlParser;
	
	if(theData == nil)
	{
		if(strLink != nil)
			myURL = [NSURL URLWithString:strLink];
		else
			myURL = [(NSArray *)WSArray objectAtIndex:forKey];
		xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:myURL];
	}
	else
	{
		xmlParser = [[NSXMLParser alloc] initWithData:theData];
	}

	//Initialize the delegate.
	XMLParser *parser = [[XMLParser alloc] initXMLParser];
	
	//Set delegate
	[xmlParser setDelegate:parser];
	
	//Start parsing the XML file.
	BOOL success = [xmlParser parse];
	
	if(!success)
		NSLog(@"%@[%@] >> %@ %d",NSStringFromClass([self class]),debugString,@"Fail Parse Xml at index",forKey);
	
	switch (forKey) {
		case RecommandSingleSong:
			//appDelegate = (MusicAppAppDelegate *)[[UIApplication sharedApplication] delegate];
			//singleList=[[NSArray alloc] initWithArray:appDelegate.songs];
			self.singleList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case RecommandAlbum:
			self.cdList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case RecommandMusicBox:
			self.musicboxList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case RecommandAlbumSong:
			//self.=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			
			break;
		case RecommandMusicBoxSong:
			//self.singleList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			
			break;
		case RankTotal:
			self.rTotalList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case RankMaleArtist:
			self.rMaleList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case RankFemaleArtist:
			self.rFemaleList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case RankGroup:
			self.rGroupList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case RankTaiwan:
			self.rTaiwanList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case RankJapanKorea:
			self.rJapanList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case RankWestern:
			self.rWesternList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case RankMood:
			self.rMoodList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case Activities:
			self.activityList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case ActivitySong:
			//self.List=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case SearchTopicKeyword:
			self.searchTopicList=[[NSMutableDictionary alloc] initWithDictionary:parser.finishedParserDic];
			break;
		case Searching:
			//self.singleList=[[NSArray alloc] initWithArray:parser.finishedParserArray];
			break;
		case UserProfile:
			self.userProfile=[[NSDictionary alloc] initWithDictionary:parser.finishedParserDic];
			self.rbtMember=parser.ringtonMember;
			break;
		default:
			NSLog(@"%@[%@] >> %@ %d",NSStringFromClass([self class]),debugString,@"There is no switch-definition at index",forKey);
			break;
	}
	[parser release];
	[xmlParser release];
}
/*
//修改for接Parser第三層
-(NSArray *)initSongsDataSource:(NSString *)strLink{
	NSString *debugString;
	debugString=@"initSongsDataSource";
	NSURL *myURL=[NSURL URLWithString:strLink];	
	
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:myURL];
	
	//Initialize the delegate.
	XMLParser *parser = [[XMLParser alloc] initXMLParser];
	
	//Set delegate
	[xmlParser setDelegate:parser];
	
	//Start parsing the XML file.
	BOOL success = [xmlParser parse];
	
	if(!success)
		NSLog(@"%@[%@] >> %@ ",NSStringFromClass([self class]),debugString,@"Fail Parse Xml at index");
	
	NSArray *songsArray=[[[NSArray alloc] initWithArray:parser.finishedParserArray] autorelease];
	
	[parser release];
	[xmlParser release];
	
	return songsArray;
}*/

-(BOOL)imgExistsAtCache:(NSString *)imgFile {
	NSNumber *value=[imgCacheDictionary objectForKey:imgFile];
	if( value == nil)
		return false;
	NSString *filePath = [dataPath stringByAppendingPathComponent:imgFile];
	if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		return false;
	}
	[imgCacheDictionary setObject:[NSNumber numberWithInt:([value intValue]+1)] forKey:imgFile];
	return true;
}

- (void)dealloc {

	[imgCacheDictionary release];
	[rTotalList release];
	[rMaleList release];
	[rFemaleList release];
	[rGroupList release];
	[rTaiwanList release];
	[rJapanList release];
	[rWesternList release];
	[rMoodList release];
	[activityList release];
	[userProfile release];
	[searchTopicList release];
	[cdSongsList release];
	[musicboxSongsList release];
	[activitySongList release];
	[dataPath release];
	[error release];
	[rbtMember release];
	[WSArray release];
	[singleList release];
	[cdList release];
	[musicboxList release];
	[tabBarController release];
    [window release];
	
	//mysong------------------
	[playlistDic release];
	[serverlistDic release];
	//---------------------------
	
    [super dealloc];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[self clearCache];
	[self clearPlayerCache];
}
/*
 ------------------------------------------------------------------------
 Private methods used only in this file
 ------------------------------------------------------------------------
 */

#pragma mark -
#pragma mark Private methods

- (void) initCache
{
	/* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"IMGCache"];
	//NSLog(self.dataPath);
	/* check for existence of cache directory */
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		NSArray *array = [[NSFileManager defaultManager] directoryContentsAtPath:dataPath];
		self.imgCacheDictionary = [[NSMutableDictionary alloc] init];
		for (NSString *element in array) {
			if(![element hasPrefix:@"."])
			{
				[imgCacheDictionary setObject:[NSNumber numberWithInt:0] forKey:element];
				//NSLog([NSString stringWithFormat:@"%@  %d",element,[[imgCacheDictionary objectForKey:element] intValue]]);
			}
        }
		//[array release];
		return;
	}
	
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath 
								   withIntermediateDirectories:NO
													attributes:nil 
														 error:&error]) {
		//URLCacheAlertWithError(error);
		return;
	}
	self.imgCacheDictionary = [[NSMutableDictionary alloc] init];
}

/* removes every file in the cache directory */

- (void) clearCache
{
	//NSLog(@"aa");
	for (id key in imgCacheDictionary) {
		//NSLog(@"key: %@, value: %@", key, [imgCacheDictionary objectForKey:key]);
		if([[imgCacheDictionary objectForKey:key] intValue] == 0)
		{
			if(![[NSFileManager defaultManager] removeItemAtPath:[dataPath stringByAppendingPathComponent:key] error:&error])
			{
				NSLog([error localizedDescription]);
			}
		}
	}
	
}	
/* create player cache dictionary */
- (void) initPlayerCache
{
	/* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.mediaPlayerPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"];
	//NSLog(self.dataPath);
	/* check for existence of cache directory */
	if ([[NSFileManager defaultManager] fileExistsAtPath:mediaPlayerPath]) {
		return;
	}
	
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:mediaPlayerPath 
								   withIntermediateDirectories:NO
													attributes:nil 
														 error:&error]) {
		//URLCacheAlertWithError(error);
		return;
	}
}
/* remove all files in player cache dictionary */
- (void) clearPlayerCache
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:mediaPlayerPath]) {
		NSArray *array = [[NSFileManager defaultManager] directoryContentsAtPath:mediaPlayerPath];
		for (NSString *element in array) 
		{
			if(![element hasPrefix:@"."])
			{
				[[NSFileManager defaultManager] removeItemAtPath:[mediaPlayerPath stringByAppendingPathComponent:element] error:nil];
			}
		}		
	}
	

}	

/*
 ------------------------------------------------------------------------
 UIAlertViewDelegate protocol method
 ------------------------------------------------------------------------
 */

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		/* the user clicked the Cancel button */
        return;
    }
	
	[self clearCache];
}

@end
