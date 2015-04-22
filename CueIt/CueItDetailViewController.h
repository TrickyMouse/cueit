//
//  CueItDetailViewController.h
//  CueIt
//
//  Created by Keith Greene on 12-07-05.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayItViewController.h"

@class CueItAppDelegate, AddSongsViewController, CueSheetSettingsViewController;

@interface CueItDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UIButton *insertSongs;
}

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet UIButton *playCueSheet;
@property (nonatomic, retain) IBOutlet UITableView *documentView;

@property (nonatomic, retain) PlayItViewController *playItViewController;
@property (nonatomic, retain) AddSongsViewController *addSongsViewController;
@property (nonatomic, retain) CueSheetSettingsViewController *cueSheetSettingsViewController;
@property (nonatomic, retain) NSMutableArray *_objects;
@property (nonatomic, retain) NSMutableArray *selectedObjects;
@property (nonatomic, retain) NSMutableArray *plistArray;

@property (nonatomic, retain) CueItAppDelegate *appDelegate;
@property (nonatomic, retain) NSString *cueSheetName;

- (IBAction)playCueSheet:(id)sender;
-(NSMutableArray *)listFileAtPath:(NSString *)path;
- (IBAction) insertNewSongs:(id)sender;

@end
