//
//  AddSongsViewController.m
//  CueIt
//
//  Created by Keith Greene on 12-07-07.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import "AddSongsViewController.h"
#import "CueItDetailViewController.h"
#import "SongList.h"
#import "DBManager.h"

@implementation AddSongsViewController

@synthesize songsTableView, diskSongs, cueItDetailViewController, cueSheetSongs, cueSheetName, sheetNumber;

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
    //diskSongs = [[NSArray alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppear:(BOOL)animated {

    if([diskSongs count] == 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"NO SONGS IN DOCUMENTS DIRECTORY"
                                                                       message:@"Please load songs into CueIt through the iTunes Document Directory"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    NSLog(@"diskSongs:%@", diskSongs);
    NSLog(@"cueSheetSongs:%@", cueSheetSongs);
    NSLog(@"cueSheetName:%@", cueSheetName);

}

- (void) viewWillAppear:(BOOL)animated {
    [songsTableView reloadData];
}


- (void) viewWillDisappear:(BOOL)animated {

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return diskSongs.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [[diskSongs objectAtIndex:indexPath.row] objectAtIndex:0];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
        
    if (thisCell.accessoryType == UITableViewCellAccessoryNone) {
        // add a new song to the array, but we don't want to save it just yet
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSString *song = [NSString stringWithFormat:@"%@",thisCell.textLabel.text];
        NSString *volume = [NSString stringWithFormat:@"1.0"];
        SongList *newSong = [[SongList alloc] init];
        newSong.name = song;
        newSong.volume_level = volume;
        newSong.fade_time = @"0.7";
        newSong.sheetnumber = self.sheetNumber;
        int bounds = cueSheetSongs.count;
        BOOL success = NO;
        success = [[DBManager getSharedInstance] saveNewSongListData:newSong.sheetnumber songName:newSong.name volumeLevel:newSong.volume_level fadeTime:newSong.fade_time sortOrder:[NSString stringWithFormat:@"%i", indexPath.row]];
        if(success == NO) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"COULD NOT SAVE SONG DATA"
                                                                           message:@"Something broke.. I'll have to fix it"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }

        [cueSheetSongs insertObject:newSong atIndex:bounds];
        [newSong release];
    } else {
        thisCell.accessoryType = UITableViewCellAccessoryNone;
        int bounds = cueSheetSongs.count - 1;
        SongList *deleteSong = [[SongList alloc] init];
        deleteSong = [cueSheetSongs objectAtIndex:bounds];
        BOOL success = NO;
        success = [[DBManager getSharedInstance] deleteSong:deleteSong.listnumber];
        if(success == NO) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"COULD NOT SAVE SONG DATA"
                                                                           message:@"Something broke.. I'll have to fix it"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        [cueSheetSongs removeObjectAtIndex:bounds];
        NSLog(@"cueSheetSongs:%@",cueSheetSongs);        
    }
}



@end
