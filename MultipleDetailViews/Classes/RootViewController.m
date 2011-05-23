
/*
     File: RootViewController.m
 Abstract: A table view controller that manages two rows. Selecting a row creates a new detail view controller that is added to the split view controller.
  
 */

#import "RootViewController.h"
#import "FirstDetailViewController.h"
#import "SecondDetailViewController.h"
#import "SettingsViewController.h"
#import "FilesListViewController.h"
#import "SearchViewController.h"
#import "DownloadViewController.h"


@implementation RootViewController

@synthesize splitViewController, menuArray, menuImageArray;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Set the content size for the popover: there are just two rows in the table view, so set to rowHeight*2.
    //self.contentSizeForViewInPopover = CGSizeMake(310.0, self.tableView.rowHeight*2.0);
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	menuArray = [[NSArray alloc] initWithObjects:@"Settings",@"Managed Folder",@"Search",@"Download",nil];
	menuImageArray = [[NSArray alloc] initWithObjects:@"settings.png",@"folder.png",@"search_folder.png",@"download.png",nil];
	self.title = @"Menu";	
	
	self.view.backgroundColor = [UIColor clearColor];	
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green.jpg"]];	
	backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
	self.tableView.backgroundView = backgroundImage;

}

-(void) viewDidUnload {
	[super viewDidUnload];
	
	self.splitViewController = nil;
	//self.rootPopoverButtonItem = nil;
}

#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc {
    
    // Keep references to the popover controller and the popover button, and tell the detail view controller to show the button.
    barButtonItem.title = @"Root View Controller";
   // self.popoverController = pc;
   // self.rootPopoverButtonItem = barButtonItem;
//    UIViewController <SubstitutableDetailViewController> *detailViewController = [splitViewController.viewControllers objectAtIndex:1];
//    [detailViewController showRootPopoverButtonItem:rootPopoverButtonItem];
	
   // UIViewController *detailViewController = [splitViewController.viewControllers objectAtIndex:1];
   // [detailViewController showRootPopoverButtonItem:rootPopoverButtonItem];	
}


- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
 
    // Nil out references to the popover controller and the popover button, and tell the detail view controller to hide the button.
//    UIViewController <SubstitutableDetailViewController> *detailViewController = [splitViewController.viewControllers objectAtIndex:1];
//    [detailViewController invalidateRootPopoverButtonItem:rootPopoverButtonItem];
  //  UIViewController  *detailViewController = [splitViewController.viewControllers objectAtIndex:1];
   // [detailViewController invalidateRootPopoverButtonItem:rootPopoverButtonItem];	
   // self.popoverController = nil;
   // self.rootPopoverButtonItem = nil;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    // Two sections, one for each detail view controller.
    return [menuArray count];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RootViewControllerCellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
	cell.imageView.image = [UIImage	imageNamed:[menuImageArray objectAtIndex:indexPath.row]];
	cell.textLabel.textColor = [UIColor blackColor];

    return cell;
}


#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *selectedMenuItem = [menuArray objectAtIndex:indexPath.row];
	//NSLog(@"Selected Menu Item : %@",selectedMenuItem);
	
    UIViewController  *detailViewController = nil;
	
    if ([selectedMenuItem isEqualToString:@"Settings"]) {
		SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
        detailViewController = settingsViewController;
    }
	else if ([selectedMenuItem isEqualToString:@"Managed Folder"]) {
		FilesListViewController *filesViewController = [[FilesListViewController alloc] init];
		filesViewController.filesNavigationController = [[UINavigationController alloc] initWithRootViewController:filesViewController];
        detailViewController = filesViewController.filesNavigationController;
    }	
	else if ([selectedMenuItem isEqualToString:@"Search"]) {
		SearchViewController *searchDetailViewController = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
		searchDetailViewController.searchNavController = [[UINavigationController alloc] initWithRootViewController:searchDetailViewController];
        detailViewController = searchDetailViewController.searchNavController;
    }
	else if ([selectedMenuItem isEqualToString:@"Download"]) {
		DownloadViewController *downloadController = [[DownloadViewController alloc] initWithNibName:@"DownloadViewController" bundle:nil];
		downloadController.downloadNavController = [[UINavigationController alloc] initWithRootViewController:downloadController];        
		detailViewController = downloadController.downloadNavController;
    }	

	
    // Update the split view controller's view controllers array.
    NSArray *viewControllers = [[NSArray alloc] initWithObjects:self.navigationController, detailViewController, nil];
    splitViewController.viewControllers = viewControllers;
    [viewControllers release];
    
    // Dismiss the popover if it's present.
//    if (popoverController != nil) {
//        [popoverController dismissPopoverAnimated:YES];
//    }
//
//    // Configure the new view controller's popover button (after the view has been displayed and its toolbar/navigation bar has been created).
//    if (rootPopoverButtonItem != nil) {
//        [detailViewController showRootPopoverButtonItem:self.rootPopoverButtonItem];
//    }

    [detailViewController release];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
   // [popoverController release];
   // [rootPopoverButtonItem release];
	[menuArray release];
	[menuImageArray release];
    [super dealloc];
}

@end
