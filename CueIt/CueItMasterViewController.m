//
//  CueItMasterViewController.m
//  CueIt
//
//  Created by Keith Greene on 12-07-05.
//  Copyright (c) 2012 Space Dog. All rights reserved.
//

#import "CueItMasterViewController.h"

#import "CueItDetailViewController.h"

@interface CueItMasterViewController () {
    //NSMutableArray *_objects;
    UITextField *cueSheetName;
}
@end

@implementation CueItMasterViewController

@synthesize detailViewController = _detailViewController; 
@synthesize cueSheet, plistArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Create Cue Sheet", @"Create Cue Sheet");
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    //[_objects release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"cuesheets.plist"];   

    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistArray = [[NSMutableArray alloc] init];
    } else {
        plistArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    }
    // print the home directory for simulator debugging
    NSString *homeDir = [NSString stringWithFormat:@"%@", NSHomeDirectory()];
    NSLog(@"HOME DIR:%@", homeDir);
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)insertNewObject:(id)sender
{
   /* if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }*/
    _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Cue Sheet", @"new_list_dialog")
                                                          message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//    cueSheetName = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
//    [cueSheetName setBackgroundColor:[UIColor whiteColor]];
    _alertView.alertViewStyle = UIAlertViewStylePlainTextInput;

    [_alertView addSubview:cueSheetName];
    [_alertView show];
    [cueSheetName becomeFirstResponder];
//    [_alertView release];

 }


- (void) createMasterPlist {
    //NSLog(@"createMasterPlist plistArray:%@", plistArray);
   // NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"cuesheets.plist"];      
    NSArray *array = [NSArray arrayWithArray:plistArray];
    [array writeToFile:plistPath atomically:YES];
    [self createCueSheetPlist];

}

- (void) createCueSheetPlist {
    NSString *plistName = [NSString stringWithFormat:@"%@.plist", cueSheet];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:plistName];
    NSArray *array = [[NSArray alloc] initWithObjects:@"", nil];
    [array writeToFile:plistPath atomically:YES];

}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //NSLog(@"Button 0");
    } else {
        cueSheetName = [_alertView textFieldAtIndex:0];
        cueSheet = cueSheetName.text;
        //[plistArray addObject:[NSString stringWithFormat:@"%@",cueSheet]];
        //[plistArray insertObject:[NSString stringWithFormat:@"%@",cueSheet] atIndex:0];
        //NSLog(@"alertView plistArray:%@", plistArray);
        [self insertIntoTableView];
    }
}

- (void) insertIntoTableView {
    //[_objects insertObject:cueSheet atIndex:0];
    [plistArray insertObject:cueSheet atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self createMasterPlist];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return _objects.count;
    //NSLog(@"plistArray count:%i",plistArray.count);
    return plistArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cueSheet = [plistArray objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = cueSheet;
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
        
        //[_objects removeObjectAtIndex:indexPath.row];
        [plistArray removeObjectAtIndex:indexPath.row];
        NSLog(@"plistArray count:%i, plistArray:%@", plistArray.count, plistArray);
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSString *plistName = [NSString stringWithFormat:@"%@.plist", cueSheetName.text];
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *plistPath = [rootPath stringByAppendingPathComponent:plistName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:plistPath error:NULL];
        //[plistArray removeObjectAtIndex:indexPath.row];

        NSString *masterPlistPath = [rootPath stringByAppendingPathComponent:@"cuesheets.plist"];      
        NSArray *array = [NSArray arrayWithArray:plistArray];
        [array writeToFile:masterPlistPath atomically:YES];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
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
    if (!self.detailViewController) {
        self.detailViewController = [[[CueItDetailViewController alloc] initWithNibName:@"CueItDetailViewController" bundle:nil] autorelease];
    }
    //NSDate *object = [_objects objectAtIndex:indexPath.row];
    NSString *object = [plistArray objectAtIndex:indexPath.row];
    //NSLog(@"object:%@", object);
    self.detailViewController.cueSheetName = [[NSString alloc] initWithFormat:@"%@",object];
    //NSLog(@"self.detailViewController.cueSheetName:%@, cueSheetName.text:%@", self.detailViewController.cueSheetName, cueSheetName.text);
    self.detailViewController.detailItem = object;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}



@end
