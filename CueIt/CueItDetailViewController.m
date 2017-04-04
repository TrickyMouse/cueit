//
//  CueItDetailViewController.m
//  CueIt
//
//  Created by Keith Greene on 12-07-05.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import "CueItDetailViewController.h"
#import "CueItAppDelegate.h"
#import "AddSongsViewController.h"
#import "CueSheetSettingsViewController.h"

@interface CueItDetailViewController ()
- (void)configureView;
@end

@implementation CueItDetailViewController

@synthesize playCueSheet, _objects, selectedObjects, appDelegate, songListArray, audioFileList;
@synthesize playItViewController, cueSheetName, addSongsViewController, cueSheetSettingsViewController;

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize documentView = _documentView;

- (void)dealloc
{
    [_detailItem release];
    [_detailDescriptionLabel release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
        songListArray = [NSMutableArray arrayWithArray:[[DBManager getSharedInstance] findAllSongsByCueSheetNumber:[_detailItem sheetnumber]]];
        if([songListArray count] > 0) {
            NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortorder" ascending:YES]];
            NSArray *sortedArray = [songListArray sortedArrayUsingDescriptors:sortDescriptors];
            songListArray = [NSMutableArray arrayWithArray:sortedArray];
        }
        [songListArray retain];
        // this searches the document dirctory for audio files and sets it.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        audioFileList = [self listFileAtPath:[paths objectAtIndex:0]];
        
        [_documentView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    appDelegate = (CueItAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [self configureView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = cueSheetName;
    }
    return self;
}

- (IBAction)playCueSheet:(id)sender {
    if (!self.playItViewController) {
        self.playItViewController = [[[PlayItViewController alloc] initWithNibName:@"PlayItViewController" bundle:nil] autorelease];
    }
    NSMutableArray *songsToPlay = [NSMutableArray arrayWithArray:[[DBManager getSharedInstance] findAllSongsByCueSheetNumber:[_detailItem sheetnumber]]];
    // sort the songs to play by database sort order
    if([songsToPlay count] > 0) {
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortorder" ascending:YES]];
        NSArray *sortedArray = [songsToPlay sortedArrayUsingDescriptors:sortDescriptors];
        songsToPlay = [NSMutableArray arrayWithArray:sortedArray];
    }
    playItViewController.songArray = [NSArray arrayWithArray:songsToPlay];
    playItViewController.songNumber = 0;
    if ([appDelegate.audioPlayer isPlaying]) {
        [appDelegate.audioPlayer stop];
    }
    [self.navigationController pushViewController:self.playItViewController animated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        _objects = [[NSMutableArray arrayWithArray:songListArray] retain];
        return _objects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [[songListArray objectAtIndex:indexPath.row] name];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SongList *removeSong = [_objects objectAtIndex:indexPath.row];
        
        BOOL success = NO;
        success = [[DBManager getSharedInstance] deleteSong:[NSString stringWithFormat:@"%@", [removeSong listnumber]]];
        
        if (success == NO) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"FAKE DATA WAS NOT SAVED!"
                                                                           message:@"Something went horribly wrong with the database, so I'll have to fix that or something..."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        
        songListArray = [NSMutableArray arrayWithArray:[[DBManager getSharedInstance] findAllSongsByCueSheetNumber:[_detailItem sheetnumber]]];
        [songListArray retain];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *stringToMove = [_objects objectAtIndex:sourceIndexPath.row];
    [_objects removeObjectAtIndex:sourceIndexPath.row];
    [_objects insertObject:stringToMove atIndex:destinationIndexPath.row];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate {
    [super setEditing:editing animated:animate];
    [_documentView setEditing:editing animated:YES];
    if(!editing) {
        int index = 0;
        for(SongList *song in _objects) {
            BOOL success = NO;
            success = [[DBManager getSharedInstance] saveSongListData:song.listnumber sheetNumber:song.sheetnumber songName:song.name volumeLevel:song.volume_level fadeTime:song.fade_time sortOrder:[NSString stringWithFormat:@"%i", index]];
            if (success == NO) {
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"DATA WAS NOT SAVED!" message:@"Something went horribly wrong with the database, so I'll have to fix that or something..." preferredStyle:UIAlertControllerStyleAlert];
    
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }

            index++;
        }
    }
}


 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
     return YES;
 }


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSString *volume = [NSString stringWithFormat:@"%@",[[_objects objectAtIndex:indexPath.row] objectAtIndex:1]];
    if (!self.cueSheetSettingsViewController) {
        self.cueSheetSettingsViewController = [[[CueSheetSettingsViewController alloc] initWithNibName:@"CueSheetSettingsViewController" bundle:nil] autorelease];
    }
    
    //self.cueSheetSettingsViewController.volumeSetting = volume;
    SongList *song = [[SongList alloc] init];
    song = [_objects objectAtIndex:indexPath.row];
    self.cueSheetSettingsViewController.selectedSong = song;
    [song release];
    
    [self.navigationController pushViewController:self.cueSheetSettingsViewController animated:YES];
}


- (IBAction)insertNewSongs:(id)sender {
    if (!self.addSongsViewController) {
        self.addSongsViewController = [[[AddSongsViewController alloc] initWithNibName:@"AddSongsViewController" bundle:nil] autorelease];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    NSMutableArray *diskSongs = [[[NSMutableArray alloc] init] autorelease];
    diskSongs = [[self listFileAtPath:[paths objectAtIndex:0]] retain];
    addSongsViewController.diskSongs = [NSMutableArray arrayWithArray:diskSongs];
    addSongsViewController.cueSheetSongs = [NSMutableArray arrayWithArray:_objects];

    addSongsViewController.cueSheetName = cueSheetName;
    addSongsViewController.sheetNumber = [NSString stringWithFormat:@"%@", [_detailItem sheetnumber]];
    [self.navigationController pushViewController:self.addSongsViewController animated:YES];
}

#pragma mark - document directory methods

-(NSMutableArray *)listFileAtPath:(NSString *)path {
    // list all audio files in the documents directory
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    NSArray *fileTypes = [NSArray arrayWithObjects:@".mp3", @".aiff", @".wav", @".caf", @".m4a", @".aif", nil];

    NSMutableArray *filteredContent = [[NSMutableArray alloc] init];
    for (count = 0; count < [directoryContent count]; count++) {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        for (NSString *item in fileTypes) {
            if ([[directoryContent objectAtIndex:count]rangeOfString:item].location != NSNotFound) {
                NSLog(@"directoryContent object:%@", [directoryContent objectAtIndex:count]);
                //the second item in the object (1.0) is the volume level
                //the third item is the preset fade level
                NSArray *content = [NSArray arrayWithObjects:[directoryContent objectAtIndex:count], @"1.0", @"0.7", nil];
                
                [filteredContent addObject:content];
            }
        }
        
    }
    NSLog(@"filtered: %@",filteredContent);
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:filteredContent];
    return array;
}
							
@end
