//
//  CueItMasterViewController.h
//  CueIt
//
//  Created by Keith Greene on 12-07-05.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CueItDetailViewController;

@interface CueItMasterViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) CueItDetailViewController *detailViewController;
@property (nonatomic, retain) NSString *cueSheet;
@property (nonatomic, retain) NSMutableArray *plistArray;
@property (nonatomic, retain) UIAlertView *alertView;

- (void) insertIntoTableView;

- (void) createMasterPlist;
- (void) createCueSheetPlist;
@end
