//
//  CueSheetSettingsViewController.m
//  CueIt
//
//  Created by Keith Greene on 12-07-22.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import "CueSheetSettingsViewController.h"
#import "DBManager.h"

@interface CueSheetSettingsViewController ()

@end

@implementation CueSheetSettingsViewController

@synthesize volumeSetting, volume, volumeSlider, fade, fadeSetting, fadeSlider, selectedSong;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    volumeSlider.minimumValue = 0.0f;
    volumeSlider.maximumValue = 1.0f;
    fadeSlider.minimumValue = 0.01f;
    fadeSlider.maximumValue = 0.9f;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    volumeSetting = [selectedSong volume_level];
    volume.text = volumeSetting;
    [volumeSlider setValue:[volumeSetting floatValue] animated:NO];
    fadeSetting = [selectedSong fade_time];
    fade.text = fadeSetting;
    [fadeSlider setValue:[fadeSetting floatValue] animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    float progress = volumeSlider.value;
    volumeSetting = [NSString stringWithFormat:@"%f", progress];
    float fadeProgress = fadeSlider.value;
    fadeSetting = [NSString stringWithFormat:@"%f", fadeProgress];
    selectedSong.volume_level = volumeSetting;
    selectedSong.fade_time = fadeSetting;
    BOOL success = NO;
    success = [[DBManager getSharedInstance] saveSongListData:selectedSong.listnumber sheetNumber:selectedSong.sheetnumber songName:selectedSong.name volumeLevel:selectedSong.volume_level fadeTime:selectedSong.fade_time sortOrder:selectedSong.sortorder];
    if (success == NO) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"SETTING DATA WAS NOT SAVED!"
                                                                       message:@"Something went horribly wrong with the database, so I'll have to fix that or something..."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction) volumeChanged:(id)sender {
    //UISlider *slider = (UISlider *)sender;
    float progress = volumeSlider.value;
    volumeSetting = [NSString stringWithFormat:@"%f", progress];
    volume.text= volumeSetting;
}

-(IBAction) fadeChanged:(id)sender {
    //UISlider *slider = (UISlider *)sender;
    float fadeProgress = fadeSlider.value;
    fadeSetting = [NSString stringWithFormat:@"%f", fadeProgress];
    fade.text= fadeSetting;
}

@end
