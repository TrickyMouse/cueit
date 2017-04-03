//
//  CueSheetSettingsViewController.h
//  CueIt
//
//  Created by Keith Greene on 12-07-22.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SongList.h"

@interface CueSheetSettingsViewController : UIViewController {
    IBOutlet UILabel *volume;
}

@property (nonatomic, retain) NSString *volumeSetting;
@property (nonatomic, retain) IBOutlet UILabel *volume;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) NSString *fadeSetting;
@property (nonatomic, retain) IBOutlet UILabel *fade;
@property (nonatomic, retain) IBOutlet UISlider *fadeSlider;

@property (nonatomic, readwrite) int plistIndex;
@property (nonatomic, retain) NSString *plistName;
@property (nonatomic, retain) SongList *selectedSong;

- (IBAction)volumeChanged:(id)sender;
- (IBAction)fadeChanged:(id)sender;

@end
