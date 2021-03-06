//
//  PlayItViewController.h
//  CueIt
//
//  Created by Keith Greene on 12-07-05.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AVFoundation/AVAudioPlayer.h"
#import "SongList.h"

@class CueItAppDelegate;

@interface PlayItViewController : UIViewController <AVAudioPlayerDelegate> {
    IBOutlet UILabel *nowPlayingLabel;
    IBOutlet UILabel *playingStateLabel;
    IBOutlet UILabel *nextSongLabel;
    IBOutlet UILabel *touchToStart;
}

@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) NSArray *songArray;
@property (nonatomic, readwrite) BOOL navBarIsHidden;
@property (nonatomic, retain) CueItAppDelegate *appDelegate;
@property (nonatomic, readwrite) int songNumber;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, readwrite) float fadeAmount;
@property (nonatomic, retain) NSString *upcomingSong;
@property (nonatomic, retain) SongList *currentSong;
@property (nonatomic, retain) SongList *nextSong;


- (IBAction) playNextSong:(id)sender;
-(NSString *)documentsDirectoryPath;
//- (void)fadeVolumeDown:(AVAudioPlayer *)aPlayer;
- (BOOL) fadeVolumeDown;
- (void) restoreVolume:(AVAudioPlayer *)aPlayer;
- (void) playLastSong:(id)sender;
- (void) skipNextSong:(id)sender;
- (void) playNextSongManager:(SongList *)_currentSong;


@end
