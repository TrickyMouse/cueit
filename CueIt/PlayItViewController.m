//
//  PlayItViewController.m
//  CueIt
//
//  Created by Keith Greene on 12-07-05.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import "PlayItViewController.h"
#import "CueItAppDelegate.h"
#import "SongList.h"

@interface PlayItViewController ()

@end

@implementation PlayItViewController

@synthesize playButton, songArray, navBarIsHidden, appDelegate, songNumber, audioPlayer, fadeAmount;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *rewindButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(playLastSong:)] autorelease];
    UIBarButtonItem *forwardButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(skipNextSong:)] autorelease];
    NSArray *array = [NSArray arrayWithObjects:forwardButton, rewindButton, nil];
    //self.navigationItem.rightBarButtonItem = rewindButton;
    [self.navigationItem setRightBarButtonItems:array];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    navBarIsHidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    appDelegate = (CueItAppDelegate *)[[UIApplication sharedApplication] delegate];
    SongList *song = [[SongList alloc] init];
    song = [songArray objectAtIndex:songNumber];
    SongList *next_song = [[SongList alloc] init];
    next_song = [songArray objectAtIndex:songNumber + 1];
    NSString *currentSong = [[NSString alloc] initWithFormat:@"%@", [song name]];
    NSString *upcomingSong = [[NSString alloc] initWithFormat:@"%@", [next_song name]];
    nowPlayingLabel.text = currentSong;
    nextSongLabel.text = upcomingSong;
    songNumber = 0;
}

- (void)viewDidAppear:(BOOL)animated {

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) skipNextSong:(id)sender {
        songNumber++;
//    NSLog(@"songNumber:%i, songArray:%i", songNumber, [songArray count]);
    if(songNumber < [songArray count]) {

        playingStateLabel.text = @"Start Playing";
        SongList *filename = [[SongList alloc] init];
        filename = [songArray objectAtIndex:songNumber];
//        NSString *song_file = [[NSString alloc] initWithFormat:@"%@", filename];
        SongList *next_song_file = [[SongList alloc] init];
        next_song_file = [songArray objectAtIndex:songNumber];
        NSString *song = [[NSString alloc] initWithFormat:@"%@", [filename name]];
        NSString *nextSong = [[NSString alloc] init];
            if (songNumber != ([songArray count] - 1)) {
                nextSong = [NSString stringWithFormat:@"%@", [next_song_file name]];
            } else {
                nextSong = @"Restart from beginning";
            }
        NSLog(@"%@", song);
        nowPlayingLabel.text = song;
        nextSongLabel.text = nextSong;
    } else {
        songNumber = 0;
        SongList *filename = [[SongList alloc] init];
        filename = [songArray objectAtIndex:songNumber];
//        NSString *song_file = [[NSString alloc] initWithFormat:@"%@", [filename name]];
        SongList *next_song_file = [[SongList alloc] init];
        next_song_file = [songArray objectAtIndex:songNumber];
        NSString *currentSong = [[NSString alloc] initWithFormat:@"%@", [filename name]];
        NSString *upcomingSong = [[NSString alloc] initWithFormat:@"%@", [next_song_file name]];
        nowPlayingLabel.text = currentSong;
        nextSongLabel.text = upcomingSong;
    }
}

- (IBAction)playNextSong:(id)sender {
    if(songNumber < [songArray count]) {
        //if ([appDelegate.audioPlayer isPlaying]) {
        //    [appDelegate.audioPlayer stop];
        if ([audioPlayer isPlaying]) {
            
            [self fadeVolumeDown:audioPlayer];
            //[audioPlayer stop];
            playingStateLabel.text = @"Start Playing";
            SongList *filename = [[SongList alloc] init];
            filename = [songArray objectAtIndex:songNumber];
//            NSString *song_file = [[NSString alloc] initWithFormat:@"%@", filename];
            SongList *next_song_file = [[SongList alloc] init];
            next_song_file = [songArray objectAtIndex:songNumber];
            NSString *song = [[NSString alloc] initWithFormat:@"%@", [filename name]];
            NSString *nextSong = [[NSString alloc] init];
            if (songNumber != ([songArray count] - 1)) {
                nextSong = [NSString stringWithFormat:@"%@", [next_song_file name]];
            } else {
                nextSong = @"Restart from beginning";
            }
            NSLog(@"%@", song);
            nowPlayingLabel.text = [filename name];
            nextSongLabel.text = [next_song_file name];
        } else {
            NSLog(@"play");
            playingStateLabel.text = @"Stop Playing";
            SongList *filename = [[SongList alloc] init];
            filename = [songArray objectAtIndex:songNumber];
            NSString *song = [[NSString alloc] initWithFormat:@"%@", [filename name]];
            SongList *next_song_file = [[SongList alloc] init];
            next_song_file = [songArray objectAtIndex:songNumber];
            NSString *nextSong = [[NSString alloc] init];
            if (songNumber != ([songArray count] - 1)) {
                nextSong = [NSString stringWithFormat:@"%@", [next_song_file name]];
            } else {
                nextSong = @"Restart from beginning";
            }
            NSLog(@"%@", song);
            nowPlayingLabel.text = [filename name];
            nextSongLabel.text = [next_song_file name];
            NSString *documentsDirectoryPath = [self documentsDirectoryPath];
            NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", documentsDirectoryPath, song]];
            
            NSError *error;
            //appDelegate.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            [audioPlayer setDelegate:self];
            //appDelegate.audioPlayer.numberOfLoops = 0;
            audioPlayer.numberOfLoops = 0;
            
            NSString *trackVolume = [[NSString alloc] initWithFormat:@"%@", [filename volume_level]];
            float vol = [trackVolume floatValue];
            NSLog(@"trackVolume: %@", trackVolume);
            NSString *fadeVolume = [[NSString alloc] initWithFormat:@"%@", [filename fade_time]];
            fadeAmount = [fadeVolume floatValue];
            NSLog(@"fadeAmount: %f", fadeAmount);
            audioPlayer.volume = vol;
            //if (appDelegate.audioPlayer == nil) {
            if (audioPlayer == nil) {
                NSLog(@"%@", [error description]);
                songNumber++;
            } else { 
                //[appDelegate.audioPlayer play];
                [audioPlayer play];
                songNumber++;
            }
            [song release];
        }
    } else {
        if ([audioPlayer isPlaying]) {
            [audioPlayer stop];
            songNumber = 0;
            SongList *filename = [[SongList alloc] init];
            filename = [songArray objectAtIndex:songNumber];
//            NSString *song = [[NSString alloc] initWithFormat:@"%@", [filename name]];
            SongList *next_song_file = [[SongList alloc] init];
            next_song_file = [songArray objectAtIndex:songNumber+1];
            NSString *currentSong = [[NSString alloc] initWithFormat:@"%@", [filename name]];
            NSString *upcomingSong = [[NSString alloc] initWithFormat:@"%@", [next_song_file name]];
            nowPlayingLabel.text = currentSong;
            nextSongLabel.text = upcomingSong;
        }
    }

}

- (void) playLastSong:(id)sender {
    NSLog(@"play last song");
    NSLog(@"%i", songNumber);
    if (songNumber != 0) {
        songNumber--;
        NSLog(@"%i", songNumber);
        SongList *filename = [[SongList alloc] init];
        filename = [songArray objectAtIndex:songNumber];
//        NSString *song = [[NSString alloc] initWithFormat:@"%@", filename];
        SongList *next_song_file = [[SongList alloc] init];
        next_song_file = [songArray objectAtIndex:songNumber+1];
        NSString *currentSong = [[NSString alloc] initWithFormat:@"%@", [filename name]];
        NSString *upcomingSong = [[NSString alloc] initWithFormat:@"%@", [next_song_file name]];
        nowPlayingLabel.text = currentSong;
        nextSongLabel.text = upcomingSong;
    }

}

-(NSString *)documentsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    return documentsDirectoryPath;
}

//for the shake to view
- (BOOL)canBecomeFirstResponder {
    return YES;
}
/*
// turn on/off the sourceView UITextView when shaking
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (navBarIsHidden == YES) {
        [self.navigationController setNavigationBarHidden:NO];
        navBarIsHidden = NO;
    } else {
        [self.navigationController setNavigationBarHidden:YES];
        navBarIsHidden = YES;
    }
}
*/

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"player stopped");
    if (songNumber < [songArray count]) {
        playingStateLabel.text = @"Start Playing";
        SongList *filename = [[SongList alloc] init];
        filename = [songArray objectAtIndex:songNumber];
        NSString *song = [[NSString alloc] initWithFormat:@"%@", filename];
        SongList *next_song_file = [[SongList alloc] init];
        next_song_file = [songArray objectAtIndex:songNumber+1];
        NSString *currSong = [[NSString alloc] initWithFormat:@"%@", song];
        NSString *nextSong = [[NSString alloc] init];
        if (songNumber != ([songArray count] - 1)) {
            nextSong = [NSString stringWithFormat:@"%@", next_song_file];
        } else {
            nextSong = @"Restart from beginning";
        }
        NSLog(@"%@", currSong);
        nowPlayingLabel.text = currSong;
        nextSongLabel.text = nextSong;
    } else {
        NSLog(@"songnumber equal to songarray");
        songNumber = 0;
        playingStateLabel.text = @"Start Playing";
        SongList *filename = [[SongList alloc] init];
        filename = [songArray objectAtIndex:songNumber];
        NSString *song = [[NSString alloc] initWithFormat:@"%@", filename];
        SongList *next_song_file = [[SongList alloc] init];
        next_song_file = [songArray objectAtIndex:songNumber+1];
        NSString *currSong = [[NSString alloc] initWithFormat:@"%@", song];
        NSString *nextSong = [[NSString alloc] init];
        nextSong = [NSString stringWithFormat:@"%@", next_song_file];
        nowPlayingLabel.text = currSong;
        nextSongLabel.text = nextSong;
    }
}

- (void)fadeVolumeDown:(AVAudioPlayer *)aPlayer
{
    aPlayer.volume = aPlayer.volume - fadeAmount;
    if (aPlayer.volume < 0.01) {
        [aPlayer stop];         
    } else {
        [self performSelector:@selector(fadeVolumeDown:) withObject:aPlayer afterDelay:0.1];  
    }
}

- (void) restoreVolume:(AVAudioPlayer *)aPlayer
{
    aPlayer.volume = aPlayer.volume - 1.0;
}



@end
