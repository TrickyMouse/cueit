//
//  AddSongsViewController.m
//  CueIt
//
//  Created by Keith Greene on 12-07-07.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import "AddSongsViewController.h"
#import "CueItDetailViewController.h"

@implementation AddSongsViewController

@synthesize songsTableView, diskSongs, cueItDetailViewController, cueSheetSongs, cueSheetName;

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
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
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
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSString *song = [NSString stringWithFormat:@"%@",thisCell.textLabel.text];
        NSString *volume = [NSString stringWithFormat:@"1.0"];
        NSArray *newSong = [NSArray arrayWithObjects:song, volume, nil];
        int bounds = cueSheetSongs.count - 1;
        NSLog(@"bounds:%i", bounds);
        [cueSheetSongs insertObject:newSong atIndex:bounds];
        NSLog(@"cueSheetSongs:%@",cueSheetSongs);
        NSString *plistName = [NSString stringWithFormat:@"%@.plist", cueSheetName];
        //NSLog(@"plistName:%@ cueSheetName:%@", plistName, cueSheetName);
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *plistPath = [libraryPath stringByAppendingPathComponent:plistName];
        [cueSheetSongs writeToFile:plistPath atomically:YES];
    } else {
        thisCell.accessoryType = UITableViewCellAccessoryNone;
        int bounds = cueSheetSongs.count - 1;
        [cueSheetSongs removeObjectAtIndex:bounds];
        NSLog(@"cueSheetSongs:%@",cueSheetSongs);
        NSString *plistName = [NSString stringWithFormat:@"%@.plist", cueSheetName];
        //NSLog(@"plistName:%@ cueSheetName:%@", plistName, cueSheetName);
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *plistPath = [libraryPath stringByAppendingPathComponent:plistName];
        [cueSheetSongs writeToFile:plistPath atomically:YES];
    }
}



@end
