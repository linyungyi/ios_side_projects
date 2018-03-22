//
//  LyricViewController.h
//  Music01
//
//  Created by Ben on 2009/9/5.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LyricViewController : UIViewController<UITextViewDelegate> {
	IBOutlet UIWebView			*lyricView;
	NSMutableString				*lyricContent;
}
@property (nonatomic, retain) NSMutableString			*lyricContent;

-(void)setLyricContent:(NSMutableString *)lyric;

@end
