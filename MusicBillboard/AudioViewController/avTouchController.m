

#import "avTouchController.h"
#import "QuartzCore/QuartzCore.h" // for CALayer
#import "Song.h"
#import "Constants.h"
#import "LyricsParser.h"
#import "Music01AppDelegate.h"

@implementation avTouchController

@synthesize _volumeSlider;
@synthesize _progressBar;
@synthesize albumView;
@synthesize reflectionView;
@synthesize myDictionary;
@synthesize albumFilePath;
@synthesize musicFilePath;
@synthesize dataPath;
@synthesize activityIndicator;
@synthesize playbackIndicator;
@synthesize _player;
@synthesize playController;
@synthesize _currentTime;
@synthesize _duration;
@synthesize _updateTimer;
@synthesize _currentLyric;
@synthesize singleSong;
@synthesize lyricParser;
@synthesize DynLyricsContent;
@synthesize sortedKeysArray;

// image reflection
const CGFloat kDefaultReflectionFraction	= 0.75;
const CGFloat kDefaultReflectionOpacity		= 0.40;

NSString *kScalingModeKey	= @"scalingMode";
NSString *kControlModeKey	= @"controlMode";
NSString *kBackgroundColorKey	= @"backgroundColor";
// amount to skip on rewind or fast forward
#define SKIP_TIME 1.0			
// amount to play between skips
#define SKIP_INTERVAL .2

#pragma mark -
#pragma mark player control

-(void)playNextSong
{
	self.sortedKeysArray=[appDelegate.playlistDic allKeys];
	//NSLog(@"playNextSong key:%@--->%d",[self.sortedKeysArray objectAtIndex:playlistIndex],playlistIndex);
	
	[self setSongObj:(Song *)[appDelegate.playlistDic objectForKey:[self.sortedKeysArray objectAtIndex:playlistIndex]]];
	[self showAlbum];
	[self getMusicFile];

	playlistIndex=playlistIndex+1;
	//NSLog(@"playlistIndex:%d",playlistIndex);

	if(playlistIndex ==[appDelegate.playlistDic count])
		playlistIndex=0;
}
-(void)initPlayer
{	
	//[self._player release];
	self._player = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:musicFilePath] error:nil];
	if(self._player){
		self.playController.hidden=FALSE;
		self._duration.text = [NSString stringWithFormat:@"%d:%02d", (int)self._player.duration / 60, (int)self._player.duration % 60, nil];
		self._progressBar.maximumValue = self._player.duration;
	}
}
-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)player
{
	self._currentTime.text = [NSString stringWithFormat:@"%d:%02d", (int)player.currentTime / 60, (int)player.currentTime % 60, nil];
	self._progressBar.value = player.currentTime;
	
	//lyric dyn
	NSString *durtime=[NSString stringWithFormat:@"%02d:%02d",(int)player.currentTime / 60, (int)player.currentTime % 60];
	@try{
		//[lyricParser getLyrics:durtime:@"%M:%S.%F"];
		[lyricParser getLyrics:durtime:@"M:S.00"];
		self._currentLyric.text=lyricParser.CurrentLyrics;//NextLyrics,LyricsContent
	}@catch (NSException *e ) {
		//NSLog(@"lyric time: %@\n", durtime);
		NSLog( @"NSException: %@\n: ", e );		//NSLog(@"lyric: %@\n", lyricParser.CurrentLyrics);
	}
	
}

- (void)updateCurrentTime
{
	[self updateCurrentTimeForPlayer:self._player];
}

- (void)updateViewForPlayerState:(AVAudioPlayer *)player
{
	[self updateCurrentTimeForPlayer:player];
	
	if (_updateTimer) 
		[_updateTimer invalidate];
	@try{
	if (player.playing)
	{
		//NSLog(@"playing");
		//[_playButton setImage:_pauseBtnBG  forState:UIControlStateNormal];
		//[_playButton setImage:((player.playing == YES) ? _pauseBtnBG : _playBtnBG) forState:UIControlStateNormal];
		_updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:player repeats:YES];
	}
	else
	{
		//NSLog(@"stop");
		//[_playButton setImage:_playBtnBG forState:UIControlStateNormal];
		//[_playButton setImage:_playBtnBG forState:UIControlStateNormal];
		//[_playButton setImage:((player.playing == YES) ? _pauseBtnBG : _playBtnBG) forState:UIControlStateNormal];
		_updateTimer = nil;
	}
	}@catch (NSException *exception) {
		NSLog(@"%@ >> %@",NSStringFromClass([self class]),[exception reason]);
	}
	
}

-(void)updateViewForPlayerInfo:(AVAudioPlayer*)player
{
	self._duration.text = [NSString stringWithFormat:@"%d:%02d", (int)player.duration / 60, (int)player.duration % 60, nil];
	self._progressBar.maximumValue = player.duration;
	self._volumeSlider.value = player.volume;
}

- (void)rewind
{
	AVAudioPlayer *player = _rewTimer.userInfo;
	player.currentTime-= SKIP_TIME;
	[self updateCurrentTimeForPlayer:player];
}

- (void)ffwd
{
	AVAudioPlayer *player = _ffwTimer.userInfo;
	player.currentTime+= SKIP_TIME;	
	[self updateCurrentTimeForPlayer:player];
}

-(void)pausePlaybackForPlayer:(AVAudioPlayer*)player
{
	[player pause];
	[self updateViewForPlayerState:player];
}

-(void)startPlaybackForPlayer:(AVAudioPlayer*)player
{
	if ([player play])
	{
		[self updateViewForPlayerState:player];
		player.delegate = self;
	}
	else
		NSLog(@"Could not play %@\n", player.url);
}

- (IBAction)playButtonPressed:(UIButton *)sender
{
	if (self._player.playing == YES)
		[self pausePlaybackForPlayer: self._player];
	else
		[self startPlaybackForPlayer: self._player];
}

- (IBAction)rewButtonPressed:(UIButton *)sender
{
	if (_rewTimer) [_rewTimer invalidate];
	_rewTimer = [NSTimer scheduledTimerWithTimeInterval:SKIP_INTERVAL target:self selector:@selector(rewind) userInfo:self._player repeats:YES];
}

- (IBAction)rewButtonReleased:(UIButton *)sender
{
	if (_rewTimer) [_rewTimer invalidate];
	_rewTimer = nil;
}

- (IBAction)ffwButtonPressed:(UIButton *)sender
{
	if (_ffwTimer) [_ffwTimer invalidate];
	_ffwTimer = [NSTimer scheduledTimerWithTimeInterval:SKIP_INTERVAL target:self selector:@selector(ffwd) userInfo:self._player repeats:YES];
}

- (IBAction)ffwButtonReleased:(UIButton *)sender
{
	if (_ffwTimer) [_ffwTimer invalidate];
	_ffwTimer = nil;
}

- (IBAction)volumeSliderMoved:(UISlider *)sender
{
	self._player.volume = [sender value];
}

- (IBAction)progressSliderMoved:(UISlider *)sender
{
	self._player.currentTime = sender.value;
	[self updateCurrentTimeForPlayer:self._player];
}

#pragma mark AVAudioPlayer delegate methods

-(void)playerClose
{
	[self._player setCurrentTime:0.];
	if (self._player.playing == YES){
		[self._player pause];
		[self updateViewForPlayerState:self._player];
	}
	appDelegate=nil;
	//[self._player release];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	//NSLog(@"Playback finished successfully");
	if (flag == NO)
		NSLog(@"Playback finished unsuccessfully");
	
	[player setCurrentTime:0.];
	[self updateViewForPlayerState:player];
	
	if(appDelegate!=nil){
		//[self playerClose];
		[self playNextSong];
	}
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error); 
}

// we will only get these notifications if playback was interrupted
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	// the object has already been paused,	we just need to update UI
	[self updateViewForPlayerState:player];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
	[self startPlaybackForPlayer:player];
}

#pragma mark -
#pragma mark init methods
- (void) initCache
{
	/* create path to cache directory inside the application's Documents directory */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.dataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCache"];
	[paths release];
	/* check for existence of cache directory */
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
		return;
	}
	
	/* create a new cache directory */
	if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath 
								   withIntermediateDirectories:NO
													attributes:nil 
														 error:nil]) {
		return;
	}
}
-(void)initDynLyric:(NSString *)lyric
{	
	self.DynLyricsContent=lyric;
	//NSString *lyricsFile=[[NSBundle mainBundle] pathForResource:@"02" ofType:@"lrc"];
	//NSFileManager *fm = [NSFileManager defaultManager];
	//BOOL fileExists = [fm fileExistsAtPath:lyricsFile] ;
	//if (fileExists)
	if(self.DynLyricsContent)
	{
		lyricParser=[LyricsParser alloc];
		//[lyricParser InitWithFilename:lyricsFile];
		[lyricParser InitWithString:DynLyricsContent];
	}
	
}	


-(void)setSinger:(NSString *)singer
{
	_artistName.text=singer;
}
-(void)setSongname:(NSString *)song
{
	_songName.text=song;
}
-(void)setSongObj:(Song *)theSong
{
	//playlistIndex=0;
	self.singleSong=theSong;
	[self setSinger:singleSong.singer];
	[self setSongname:singleSong.song];
}
-(void)setPlaylist:(NSMutableDictionary *)listdic;
{
	if(appDelegate == nil)
		appDelegate = (Music01AppDelegate *)[[UIApplication sharedApplication] delegate];
	self.sortedKeysArray=[appDelegate.playlistDic allKeys];
	//NSLog(@"setPlaylist key:%@",[sortedKeysArray objectAtIndex:playlistIndex]);
	/*playlistIndex=0;
	 self.playlistDic=listdic;
	 self.sortedKeysArray=[self.playlistDic allKeys];
	 NSLog(@"setPlaylist key:%@",[sortedKeysArray objectAtIndex:playlistIndex]);*/
	
}

- (void)awakeFromNib
{
	[self initCache];
	_playBtnBG = [[[UIImage imageNamed:@"play.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] retain];
	_pauseBtnBG = [[[UIImage imageNamed:@"pause.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] retain];

	//[_playButton setImage:_playBtnBG forState:UIControlStateNormal];
}
- (void)dealloc
{
	/*[_updateTimer release];
	[_playBtnBG release];
	[_pauseBtnBG release];
	[_player release];*/
	[super dealloc];
}


#pragma mark -
#pragma mark displayContentWithURL methods

CGContextRef MyCreateBitmapContext (int pixelsWide, int pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
    if (context== NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease( colorSpace );
	
    return context;
}

CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
	CGImageRef theCGImage = NULL;
	
	// gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	// create the bitmap context
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, pixelsWide, pixelsHigh,
															   8, 0, colorSpace, kCGImageAlphaNone);
	
	// define the start and end grayscale values (with the alpha, even though
	// our bitmap context doesn't support alpha the gradient requires it)
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	
	// create the CGGradient and then release the gray color space
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	// create the start and end points for the gradient vector (straight down)
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
	
	// draw the gradient into the gray bitmap context
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
								gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	
	// convert the context into a CGImageRef and release the context
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	
	// return the imageref containing the gradient
    return theCGImage;
}

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height
{
	// create a bitmap graphics context the size of the image
	CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.bounds.size.width, height);
	
	// offset the context -
	// This is necessary because, by default, the layer created by a view for caching its content is flipped.
	// But when you actually access the layer content and have it rendered it is inverted.  Since we're only creating
	// a context the size of our reflection view (a fraction of the size of the main view) we have to translate the
	// context the delta in size, and render it.
	//
	CGFloat translateVertical= fromImage.bounds.size.height - height;
	CGContextTranslateCTM(mainViewContentContext, 0, -translateVertical);
	
	// render the layer into the bitmap context
	CALayer *layer = fromImage.layer;
	[layer renderInContext:mainViewContentContext];
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	// create a 2 bit CGImage containing a gradient that will be used for masking the 
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = CreateGradientImage(1, height);
	
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGImageRef reflectionImage = CGImageCreateWithMask(mainViewContentBitmapContext, gradientMaskImage);
	CGImageRelease(mainViewContentBitmapContext);
	CGImageRelease(gradientMaskImage);
	
	// convert the finished reflection image to a UIImage 
	UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
	
	// image is retained by the property setting above, so we can release the original
	CGImageRelease(reflectionImage);
	
	return theImage;
}


/* show the user that loading activity has started */

- (void) startAnimation:(NSString *)type
{
	if([type isEqualToString:@"rbtConfig"]){
		[self.playbackIndicator startAnimating];
	}else if([type isEqualToString:@"playback"]){
		[self.playbackIndicator startAnimating];
	}else{
		[self.activityIndicator startAnimating];
	}
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = YES;
}


/* show the user that loading activity has stopped */

- (void) stopAnimation:(NSString *)type
{
	if([type isEqualToString:@"rbtConfig"]){
		[self.playbackIndicator stopAnimating];
	}else if([type isEqualToString:@"playback"]){
		[self.playbackIndicator stopAnimating];
	}else{
		[self.activityIndicator stopAnimating];
	}
	UIApplication *application = [UIApplication sharedApplication];
	application.networkActivityIndicatorVisible = NO;
}
-(void)displayQuestionImage
{
	albumView.image=[UIImage imageNamed:@"question.png"];
}
/* display existing cached image */

- (void) displayCachedImage
{
	
	/* display the file as an image */
	
	//UIImage *theImage = [[UIImage alloc] initWithContentsOfFile:albumFilePath];
	//if (theImage) {
		albumView.image = [[UIImage alloc] initWithContentsOfFile:albumFilePath];
		//[theImage release];
	//}
	
	//專輯圖
	//[albumView setImage:[UIImage imageNamed:@"artist_sample.gif"]];
	[albumView setUserInteractionEnabled:NO];
	
	//專輯反射
	// create the reflection view
	CGRect reflectionRect = albumView.frame;
	
	// the reflection is a fraction of the size of the view being reflected
	reflectionRect.size.height = reflectionRect.size.height * kDefaultReflectionFraction;
	
	// and is offset to be at the bottom of the view being reflected
	reflectionRect = CGRectOffset(reflectionRect, 0, albumView.frame.size.height);
	
	//reflectionView = [[UIImageView alloc] initWithFrame:reflectionRect];
	
	// determine the size of the reflection to create
	NSUInteger reflectionHeight = albumView.bounds.size.height * kDefaultReflectionFraction;
	
	// create the reflection image, assign it to the UIImageView and add the image view to the containerView
	reflectionView.image = [self reflectedImage:albumView withHeight:reflectionHeight];
	reflectionView.alpha = kDefaultReflectionOpacity;
}

- (void) getMusicWithURL:(NSURL *)theURL
{	
	[musicFilePath release]; 
	musicFilePath = [[dataPath stringByAppendingPathComponent:[[theURL path] lastPathComponent]] retain];
	if ([[NSFileManager defaultManager] fileExistsAtPath:musicFilePath]) {
		[self initPlayer];
	}else{
		[self startAnimation:@"playback"];
		(void) [[AlbumImgConnection alloc] initWithURL:theURL delegate:self connectType:@"music"];
		//NSLog(@"theURL:%@",theURL);
	}
}

- (void) getImageWithURL:(NSURL *)theURL
{
	/* get the path to the cached image */
	
	[albumFilePath release]; 
	//NSString *fileName = [[theURL path] lastPathComponent];
	albumFilePath = [[dataPath stringByAppendingPathComponent:[[theURL path] lastPathComponent]] retain];
	if ([[NSFileManager defaultManager] fileExistsAtPath:albumFilePath]) {
		[self displayCachedImage];
	}else{
		NSLog(@"getImageWithURL:%@",theURL);
		[self startAnimation:@"album"];
		(void) [[AlbumImgConnection alloc] initWithURL:theURL delegate:self connectType:@"album"];
	}
}

- (void) initUI
{
	albumView.image = nil;
	reflectionView.image=nil;
	self._duration.text = [NSString stringWithFormat:@"%d:%02d", 0, 0, nil];
	self._progressBar.maximumValue = 0;

}
-(void)showAlbum{
	[self initUI];
	//NSLog(singleSong.img_album);
	if(singleSong.img_album!=nil){
		if([singleSong.img_album isEqualToString:@"null"])
			[self displayQuestionImage];
		else
			[self getImageWithURL:[NSURL URLWithString:singleSong.img_album]];
	}
}
-(void)getMusicFile{
	self.playController.hidden=TRUE;
	//NSLog(singleSong.wav);
	if(singleSong.wav!=nil)
		[self getMusicWithURL:[NSURL URLWithString:singleSong.wav]];
}




#pragma mark -
#pragma mark AlbumImgConnectionDelegate methods

- (void) connectionDidFail:(AlbumImgConnection *)theConnection
{	
	[self stopAnimation:@"album"];
	[self stopAnimation:@"playback"];
	[theConnection release];
}


- (void) connectionDidFinish:(AlbumImgConnection *)theConnection
{	
	if([theConnection.connectType isEqualToString:@"album"]){
		if ([[NSFileManager defaultManager] fileExistsAtPath:albumFilePath] == NO) {
			[[NSFileManager defaultManager] createFileAtPath:albumFilePath 
											contents:theConnection.receivedData 
											attributes:nil];
		}
		[self stopAnimation:@"album"];
		[self displayCachedImage];
	}else if([theConnection.connectType isEqualToString:@"music"]){
		if ([[NSFileManager defaultManager] fileExistsAtPath:musicFilePath] == NO) {
			[[NSFileManager defaultManager] createFileAtPath:musicFilePath 
											contents:theConnection.receivedData 
											attributes:nil];
		}
		[self stopAnimation:@"playback"];
		[self initPlayer];
		if(appDelegate!=nil)
			[self startPlaybackForPlayer: self._player];

	}

	[theConnection release];
}


@end