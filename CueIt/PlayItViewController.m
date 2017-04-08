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

@synthesize playButton, songArray, navBarIsHidden, appDelegate, songNumber, audioPlayer, fadeAmount, currentSong, nextSong;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *rewindButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(playLastSong:)] autorelease];
    UIBarButtonItem *forwardButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(skipNextSong:)] autorelease];
    NSArray *array = [NSArray arrayWithObjects:forwardButton, rewindButton, nil];
    [self.navigationItem setRightBarButtonItems:array];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    navBarIsHidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    appDelegate = (CueItAppDelegate *)[[UIApplication sharedApplication] delegate];
    currentSong = [songArray objectAtIndex:songNumber];
    nextSong = [songArray objectAtIndex:songNumber + 1];
    NSString *current = [[NSString alloc] initWithFormat:@"%@", [currentSong name]];
    NSString *next = [[NSString alloc] initWithFormat:@"%@", [nextSong name]];
    nowPlayingLabel.text = current;
    nextSongLabel.text = next;
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
    if(songNumber < [songArray count]) {

        playingStateLabel.text = @"Start Playing";
        
        currentSong = [songArray objectAtIndex:songNumber];
        NSString *current = [[NSString alloc] initWithFormat:@"%@", [currentSong name]];
        NSString *next = [[NSString alloc] init];
            if (songNumber != ([songArray count] - 1)) {
                nextSong = [songArray objectAtIndex:songNumber + 1];
                next = [NSString stringWithFormat:@"%@", [nextSong name]];
            } else {
                next = @"Restart from beginning";
            }
        nowPlayingLabel.text = current;
        nextSongLabel.text = next;
    } else {
        songNumber = 0;
        currentSong = [songArray objectAtIndex:songNumber];
        nextSong = [songArray objectAtIndex:songNumber + 1];
        NSString *current = [[NSString alloc] initWithFormat:@"%@", [currentSong name]];
        NSString *next = [[NSString alloc] initWithFormat:@"%@", [nextSong name]];
        nowPlayingLabel.text = current;
        nextSongLabel.text = next;
    }
}

- (IBAction)playNextSong:(id)sender {
    NSLog(@"player next song action");
    NSLog(@"%i", [songArray count]);
    NSLog(@"song #%i", songNumber);

    if ([audioPlayer isPlaying]) {
        BOOL faded = NO;
        faded = [self fadeVolumeDown];
        if(faded == YES) {
            playingStateLabel.text = @"Start Playing";
        
            currentSong = [songArray objectAtIndex:songNumber];
            NSString *current = [[NSString alloc] initWithFormat:@"%@", [currentSong name]];
            NSString *next = [[NSString alloc] init];
            if (songNumber != ([songArray count] - 1)) {
                nextSong = [songArray objectAtIndex:songNumber + 1];
                next = [NSString stringWithFormat:@"%@", [nextSong name]];
            } else {
                next = @"Restart from beginning";
            }

            nowPlayingLabel.text = current;
            nextSongLabel.text = next;
            [self playNextSongManager:currentSong];
        }
    } else {
        NSLog(@"play");
        playingStateLabel.text = @"Stop Playing";
            
        currentSong = [songArray objectAtIndex:songNumber];
        NSString *current = [[NSString alloc] initWithFormat:@"%@", [currentSong name]];
            
        NSString *next = [[NSString alloc] init];
        if (songNumber != ([songArray count] - 1)) {
            nextSong = [songArray objectAtIndex:songNumber + 1];
            next = [NSString stringWithFormat:@"%@", [nextSong name]];
        } else {
            next = @"Restart from beginning";
        }
        
        nowPlayingLabel.text = current;
        nextSongLabel.text = next;
        [self playNextSongManager:currentSong];
    }
}

- (void) playLastSong:(id)sender {
    NSLog(@"play last song");
    NSLog(@"%i", songNumber);
    if (songNumber != 0) {
        songNumber--;
        NSLog(@"%i", songNumber);
        currentSong = [songArray objectAtIndex:songNumber];
        nextSong = [songArray objectAtIndex:songNumber+1];
        NSString *current = [[NSString alloc] initWithFormat:@"%@", [currentSong name]];
        NSString *next = [[NSString alloc] initWithFormat:@"%@", [nextSong name]];
        nowPlayingLabel.text = current;
        nextSongLabel.text = next;
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

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"player stopped");
    NSLog(@"%i", [songArray count]);
    NSLog(@"song #%i", songNumber);
    
    playingStateLabel.text = @"Start Playing";
        
    currentSong = [songArray objectAtIndex:songNumber];
    NSString *current = [[NSString alloc] initWithFormat:@"%@", [currentSong name]];
    NSString *next = [[NSString alloc] init];
    // zero index hell
    if (songNumber != [songArray count] - 1) {
        nextSong = [songArray objectAtIndex:songNumber + 1];
        next = [NSString stringWithFormat:@"%@", [nextSong name]];
    } else {
        next = @"Restart from beginning";
    }
    nowPlayingLabel.text = current;
    nextSongLabel.text = next;
}

- (BOOL)fadeVolumeDown {
    while(audioPlayer.volume > fadeAmount) {
        audioPlayer.volume = audioPlayer.volume - fadeAmount;
        [self performSelector:@selector(fadeVolumeDown) withObject:nil afterDelay:0.1];
        return NO;
    }
    [audioPlayer stop];
    playingStateLabel.text = @"Start Playing";
    
    currentSong = [songArray objectAtIndex:songNumber];
    NSString *current = [[NSString alloc] initWithFormat:@"%@", [currentSong name]];
    NSString *next = [[NSString alloc] init];
    if (songNumber != ([songArray count] - 1)) {
        nextSong = [songArray objectAtIndex:songNumber + 1];
        next = [NSString stringWithFormat:@"%@", [nextSong name]];
    } else {
        next = @"Restart from beginning";
    }
    
    nowPlayingLabel.text = current;
    nextSongLabel.text = next;
    return YES;
}

- (void) restoreVolume:(AVAudioPlayer *)aPlayer {
    aPlayer.volume = aPlayer.volume - 1.0;
}

- (void) playNextSongManager:(SongList *)_currentSong {
    NSString *current = [[NSString alloc] initWithFormat:@"%@", [_currentSong name]];
    
    NSString *documentsDirectoryPath = [self documentsDirectoryPath];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", documentsDirectoryPath, current]];
    
    NSError *error;
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [audioPlayer setDelegate:self];
    audioPlayer.numberOfLoops = 0;
    
    NSString *trackVolume = [[NSString alloc] initWithFormat:@"%@", [_currentSong volume_level]];
    float vol = [trackVolume floatValue];
    NSLog(@"trackVolume: %@", trackVolume);
    NSString *fadeVolume = [[NSString alloc] initWithFormat:@"%@", [_currentSong fade_time]];
    fadeAmount = [fadeVolume floatValue];
    NSLog(@"fadeAmount: %f", fadeAmount);
    audioPlayer.volume = vol;
    
    if (audioPlayer == nil) {
        NSLog(@"%@", [error description]);
        songNumber++;
    } else {
        [audioPlayer play];
        songNumber++;
    }
    if(songNumber >= [songArray count])
        songNumber = 0;
}


@end
