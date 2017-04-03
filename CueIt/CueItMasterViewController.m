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
    UITextField *cueSheetName;
}
@end

@implementation CueItMasterViewController

@synthesize detailViewController = _detailViewController; 
@synthesize cueSheet, cueSheetArray;

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
    
    cueSheetArray = [[DBManager getSharedInstance] getAllCuesheets];
    
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

- (void)insertNewObject:(id)sender {
    _alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Cue Sheet", @"new_list_dialog")
                                                          message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];

    _alertView.alertViewStyle = UIAlertViewStylePlainTextInput;

    [_alertView addSubview:cueSheetName];
    [_alertView show];
    [cueSheetName becomeFirstResponder];

 }


- (void) createCueSheet {
    BOOL success = NO;
    success = [[DBManager getSharedInstance]saveNewSheet:cueSheet];
    if (success == NO) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"CUESHEET WAS NOT SAVED!"
                                                                       message:@"Something went horribly wrong with the database, so I'll have to fix that or something..."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        cueSheetArray = [[DBManager getSharedInstance] getAllCuesheets];
        [self.tableView reloadData];
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        cueSheetName = [_alertView textFieldAtIndex:0];
        cueSheet = cueSheetName.text;
        [self createCueSheet];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return cueSheetArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CueSheet *_cueSheet = [[CueSheet alloc] init];
    _cueSheet = [cueSheetArray objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = _cueSheet.name;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        CueSheet *removeSheet = [cueSheetArray objectAtIndex:indexPath.row];
        
        BOOL success = NO;
        success = [[DBManager getSharedInstance]deleteSheet:[NSString stringWithFormat:@"%@", [removeSheet sheetnumber]]];
        if (success == NO) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"CUESHEET WAS NOT DELETED!"
                                                                           message:@"Something went horribly wrong with the database, so I'll have to fix that or something..."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        cueSheetArray = [[DBManager getSharedInstance] getAllCuesheets];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%i", cell.tag);

    if (!self.detailViewController) {
        self.detailViewController = [[[CueItDetailViewController alloc] initWithNibName:@"CueItDetailViewController" bundle:nil] autorelease];
    }
    
    NSString *object = [cueSheetArray objectAtIndex:indexPath.row];
    self.detailViewController.cueSheetName = [[NSString alloc] initWithFormat:@"%@",object];
    self.detailViewController.detailItem = object;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}



@end
