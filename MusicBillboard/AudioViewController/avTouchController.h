

#import <UIKit/UIKit.h>
#import	"AlbumImgConnection.h"
#import	"Song.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@class LyricsParser,Music01AppDelegate;

@interface avTouchController : NSObject <UIPickerViewDelegate,AlbumImgConnectionDelegate,AVAudioPlayerDelegate> {

	Music01AppDelegate					*appDelegate;
	IBOutlet UILabel					*_songName;
	IBOutlet UILabel					*_artistName;
	IBOutlet UILabel					*_currentTime;
	IBOutlet UILabel					*_duration;
	IBOutlet UILabel					*_currentLyric;
	IBOutlet UIButton					*_playButton;
	IBOutlet UIButton					*_ffwButton;
	IBOutlet UIButton					*_rewButton;
	IBOutlet UIActivityIndicatorView	*_isPlayingView;

	IBOutlet UISlider					*_volumeSlider;
	IBOutlet UISlider					*_progressBar;
	IBOutlet UIImageView                *albumView;
	IBOutlet UIImageView	            *reflectionView;
	IBOutlet UIActivityIndicatorView    *activityIndicator;
	IBOutlet UIActivityIndicatorView    *playbackIndicator;
	IBOutlet UIToolbar                  *playController;
	UIImage								*_playBtnBG, *_pauseBtnBG;
	
	AVAudioPlayer						*_player;
	
	//NSMutableDictionary					*playlistDic;
	NSMutableDictionary					*myDictionary;
	NSArray								*sortedKeysArray;
	NSInteger                                playlistIndex;
	
	NSString							*albumFilePath;
	NSString							*musicFilePath;
	NSString							*dataPath;
	NSString							*DynLyricsContent;
	NSTimer								*_updateTimer;
	NSTimer								*_rewTimer;
	NSTimer								*_ffwTimer;
	Song								*singleSong;
	LyricsParser                        *lyricParser;
}

- (IBAction)playButtonPressed:(UIButton *)sender;
- (IBAction)rewButtonPressed:(UIButton *)sender;
- (IBAction)rewButtonReleased:(UIButton *)sender;
- (IBAction)ffwButtonPressed:(UIButton *)sender;
- (IBAction)ffwButtonReleased:(UIButton *)sender;
- (IBAction)volumeSliderMoved:(UISlider *)sender;
- (IBAction)progressSliderMoved:(UISlider *)sender;

@property (nonatomic, retain) UIImageView				*albumView;
@property (nonatomic, retain) UIImageView				*reflectionView;
@property (nonatomic, copy) NSString					*albumFilePath;
@property (nonatomic, copy) NSString					*musicFilePath;
@property (nonatomic, copy) NSString					*dataPath;
@property (nonatomic, retain) NSString					*DynLyricsContent;
@property (nonatomic, retain) IBOutlet UIToolbar		*playController;
@property (nonatomic, retain) NSTimer					*_updateTimer;
@property (nonatomic, retain) UISlider					*_volumeSlider;
@property (nonatomic, retain) UISlider					*_progressBar;
@property (nonatomic, retain) UILabel					*_currentTime;
@property (nonatomic, retain) UILabel					*_duration;
@property (nonatomic, retain) UILabel					*_currentLyric;
@property (nonatomic, retain) Song						*singleSong;
@property (nonatomic, retain) NSArray					*sortedKeysArray;
@property (retain)			  LyricsParser				*lyricParser;

@property (nonatomic, retain) NSMutableDictionary		*myDictionary;
//@property (nonatomic, retain) NSMutableDictionary		*playlistDic;
@property (nonatomic, retain) UIActivityIndicatorView	*activityIndicator;
@property (nonatomic, retain) UIActivityIndicatorView	*playbackIndicator;
@property (nonatomic, assign) AVAudioPlayer				*_player;

-(void)setSongObj:(Song *)theSong;
-(void)showAlbum;
-(void)getMusicFile;
-(void)playerClose;
-(void)initDynLyric:(NSString *)lyric;
-(void)setPlaylist:(NSMutableDictionary *)listdic;
@end