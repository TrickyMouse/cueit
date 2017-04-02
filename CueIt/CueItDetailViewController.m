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

@synthesize playCueSheet, _objects, selectedObjects, appDelegate, plistArray;
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

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                             NSUserDomainMask, YES);
        _detailItem = [[self listFileAtPath:[paths objectAtIndex:0]] retain];
        NSString *plistName = [NSString stringWithFormat:@"%@.plist", cueSheetName];
        NSArray *libraryDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *plistPath = [[libraryDirectory objectAtIndex:0] stringByAppendingPathComponent:plistName];
        plistArray = [NSMutableArray arrayWithArray:_detailItem];
        //NSLog(@"configure view array: %@", plistArray);
        [plistArray writeToFile:plistPath atomically:YES];
        [_documentView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    appDelegate = (CueItAppDelegate *)[[UIApplication sharedApplication] delegate];
    plistArray = [[[NSMutableArray alloc] init] autorelease];
//    plistArray = [[[NSMutableArray alloc] initWithObjects:nil] autorelease];
    //[self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    // Get path to documents directory
    NSString *plistName = [NSString stringWithFormat:@"%@.plist", cueSheetName];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [libraryPath stringByAppendingPathComponent:plistName];   
    // negative check for plist at path
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        [self configureView];       
    } else {
        _detailItem = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
//
//        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
//        _detailItem = [NSMutableArray arrayWithObjects:dict, nil];
        plistArray = [NSMutableArray arrayWithArray:_detailItem];
        NSLog(@"viewWillAppear plistArray: %@", plistArray);
        if([_detailItem count] > 0) {
            NSString *firstObject = [NSString stringWithFormat:@"%@", [_detailItem objectAtIndex:0]];
            if (firstObject.length == 0) {
                [self configureView];
            } else {
                [_documentView reloadData];
            }
        } else {
            [self configureView];
        }
    }


}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Cue Sheet", @"Cue Sheet");
        self.title = cueSheetName;
    }
    return self;
}

- (IBAction)playCueSheet:(id)sender {
    if (!self.playItViewController) {
        self.playItViewController = [[[PlayItViewController alloc] initWithNibName:@"PlayItViewController" bundle:nil] autorelease];
    }
    //playItViewController.songArray = [NSArray arrayWithArray:plistArray];
    playItViewController.songArray = [NSArray arrayWithArray:_detailItem];
    playItViewController.songNumber = 0;
    if ([appDelegate.audioPlayer isPlaying]) {
        [appDelegate.audioPlayer stop];
    }
    //self.detailViewController.detailItem = object;
    [self.navigationController pushViewController:self.playItViewController animated:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _objects = _detailItem;
    return _objects.count;
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
    
    
    NSString *object = [[_objects objectAtIndex:indexPath.row] objectAtIndex:0];
    cell.textLabel.text = object;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        plistArray = [NSMutableArray arrayWithArray:_objects];
        //NSLog(@"during deletion: %@", plistArray);
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //write plist
        NSString *plistName = [NSString stringWithFormat:@"%@.plist", cueSheetName];
        //NSLog(@"plistName:%@ cueSheetName:%@", plistName, cueSheetName);
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *plistPath = [libraryPath stringByAppendingPathComponent:plistName];
        [plistArray writeToFile:plistPath atomically:YES];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    id object = [[[_objects objectAtIndex:fromIndexPath.row] retain] autorelease];
    [_objects removeObjectAtIndex:fromIndexPath.row];
    [_objects insertObject:object atIndex:toIndexPath.row];
    plistArray = [NSMutableArray arrayWithArray:_objects];
    //NSLog(@"during editing: %@", plistArray);
    //write plist
    NSString *plistName = [NSString stringWithFormat:@"%@.plist", cueSheetName];
    //NSLog(@"plistName:%@ cueSheetName:%@", plistName, cueSheetName);
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [libraryPath stringByAppendingPathComponent:plistName];
    [plistArray writeToFile:plistPath atomically:YES];

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
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
    //NSString *volume = [NSString stringWithFormat:@"%@",[[_objects objectAtIndex:indexPath.row] objectAtIndex:1]];
    if (!self.cueSheetSettingsViewController) {
        self.cueSheetSettingsViewController = [[[CueSheetSettingsViewController alloc] initWithNibName:@"CueSheetSettingsViewController" bundle:nil] autorelease];
    }
    
    //self.cueSheetSettingsViewController.volumeSetting = volume;
    self.cueSheetSettingsViewController.plistIndex = indexPath.row;
    self.cueSheetSettingsViewController.plistName = cueSheetName;
    [self.navigationController pushViewController:self.cueSheetSettingsViewController animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_documentView setEditing:editing animated:YES];
    //NSLog(@"set editing object:%@", _objects);
    /*if (editing) {
        addButton.enabled = NO;
    } else {
        addButton.enabled = YES;
    }*/
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
    [self.navigationController pushViewController:self.addSongsViewController animated:YES];
}

#pragma mark - document directory methods

-(NSMutableArray *)listFileAtPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
    //NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    NSArray *fileTypes = [NSArray arrayWithObjects:@".mp3", @".aiff", @".wav", @".caf", @".m4a", @".aif", nil];

    NSMutableArray *filteredContent = [[NSMutableArray alloc] init];
    int directoryContentCount = [directoryContent count];
    for (count = 0; count < directoryContentCount; count++) {
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
