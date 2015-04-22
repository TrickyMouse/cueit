//
//  CueSheetSettingsViewController.m
//  CueIt
//
//  Created by Keith Greene on 12-07-22.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import "CueSheetSettingsViewController.h"

@interface CueSheetSettingsViewController ()

@end

@implementation CueSheetSettingsViewController

@synthesize volumeSetting, volume, volumeSlider, plistIndex, plistName, fade, fadeSetting, fadeSlider;

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
    fadeSlider.minimumValue = 0.0f;
    fadeSlider.maximumValue = 1.0f;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"plistPath Index:%i", plistIndex);
    NSLog(@"plistName:%@", plistName);
    NSString *plist = [NSString stringWithFormat:@"%@.plist", plistName];
    NSLog(@"plist:%@", plist);
    NSArray *libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[libraryDirectory objectAtIndex:0] stringByAppendingPathComponent:plist];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        volumeSetting = 0;
        volume.text = volumeSetting;
        [volumeSlider setValue:[volumeSetting floatValue] animated:NO];
        fadeSetting = 0;
        fade.text = fadeSetting;
        [fadeSlider setValue:[fadeSetting floatValue] animated:NO];
    } else {
        NSMutableArray *plistArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
        volumeSetting = [[plistArray objectAtIndex:plistIndex] objectAtIndex:1];
        volume.text = volumeSetting;
        [volumeSlider setValue:[volumeSetting floatValue] animated:NO];
        fadeSetting = [[plistArray objectAtIndex:plistIndex] objectAtIndex:2];
        fade.text = fadeSetting;
        [fadeSlider setValue:[fadeSetting floatValue] animated:NO];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    float progress = volumeSlider.value;
    volumeSetting = [NSString stringWithFormat:@"%f", progress];
    float fadeProgress = fadeSlider.value;
    fadeSetting = [NSString stringWithFormat:@"%f", fadeProgress];
    NSString *plist = [NSString stringWithFormat:@"%@.plist", plistName];
    NSLog(@"plist:%@", plist);
    NSArray *libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [[libraryDirectory objectAtIndex:0] stringByAppendingPathComponent:plist];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSLog(@"FILE DOES NOT EXIST");
    } else {
        NSLog(@"File Exists");
        NSLog(@"plistIndex:%i", plistIndex);
        NSMutableArray *plistArray = [NSMutableArray arrayWithContentsOfFile:plistPath];
        NSString *trackName = [[plistArray objectAtIndex:plistIndex] objectAtIndex:0];
        NSLog(@"trackName:%@", trackName);
        NSArray *array = [[[NSArray alloc] initWithObjects:trackName, volumeSetting, fadeSetting, nil] autorelease];
        //NSArray *array = [NSArray arrayWithObjects:trackName, volumeSetting, nil];
        NSLog(@"%@", array);
        [plistArray replaceObjectAtIndex:plistIndex withObject:array];
        NSLog(@"replaced: %@", plistArray);
        [plistArray writeToFile:plistPath atomically:YES];
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
