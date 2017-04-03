//
//  AddSongsViewController.h
//  CueIt
//
//  Created by Keith Greene on 12-07-07.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CueItDetailViewController;

@interface AddSongsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *songsTableView;
@property (nonatomic, retain) NSMutableArray *diskSongs;
@property (nonatomic, retain) NSMutableArray *cueSheetSongs;
@property (nonatomic, retain) NSString *cueSheetName;
@property (nonatomic, retain) NSString *sheetNumber;

@property (nonatomic, retain) CueItDetailViewController *cueItDetailViewController;


@end
