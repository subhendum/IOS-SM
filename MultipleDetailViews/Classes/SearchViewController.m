    //
//  SearchViewController.m
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "AppDelegate.h"
#import "GDFileViewController.h"

@interface SearchViewController ()
-(void)setSearchResultsArray;
-(BOOL)isDownloadedFile:(NSString *)filename;
-(void)showTransparentModalView:(NSString *)message;
@end

@implementation SearchViewController

@synthesize searchResultsArray;
@synthesize downloadedFilesArray;
@synthesize tableSearchView;
@synthesize searchNavController;
@synthesize appDelegate;
@synthesize transparentView;
@synthesize activityIndicator;

#pragma mark -
#pragma mark View Management

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[self setSearchResultsArray];
	
	downloadedFilesArray = [[NSArray alloc] init];
	self.title = @"Search";
	[self.tableSearchView setBackgroundView:nil];
	
	// Search bar settings
	UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
	searchBar.barStyle = UIBarStyleBlackTranslucent;
	searchBar.showsCancelButton = NO;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.delegate = self;
	[searchBar becomeFirstResponder];
	self.tableSearchView.tableHeaderView = searchBar;
	[searchBar release];	
	
	self.view.backgroundColor = [UIColor clearColor];
	self.tableSearchView.backgroundColor = [UIColor clearColor];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green.jpg"]];	
	backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
	self.tableSearchView.backgroundView = backgroundImage;
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

-(void)reloadFilesListInTable:(int)currentCounter {
	[self setSearchResultsArray];
	transparentView = (UIView *)[self.view viewWithTag:1];
	[transparentView removeFromSuperview];	
	
	// removing transparent view from left side of split view.
	UIView *leftTransparentView = [[[appDelegate.splitViewController.viewControllers objectAtIndex:0] view] viewWithTag:1];
	[leftTransparentView removeFromSuperview];
	
	[self.tableSearchView reloadData];
}

-(void)showTransparentModalView:(NSString *)message {
	CGRect transparentViewFrame = CGRectMake(0, 0, 768, 768);
	transparentView = [[UIView alloc] initWithFrame:transparentViewFrame];
	transparentView.backgroundColor = [UIColor lightTextColor];
	transparentView.alpha = 0.9;
	transparentView.tag = 1;
	
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activityIndicator.frame = CGRectMake(round((self.view.frame.size.width-25)/2), round((self.view.frame.size.height-25)/2), 50, 50);
	activityIndicator.tag = 1;
	activityIndicator.center = transparentView.center;
	[activityIndicator startAnimating];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(round((self.view.frame.size.width-200)/2), round((self.view.frame.size.height-100)/2), 320, 30)];
	label.textAlignment = UITextAlignmentCenter;
	label.text = message;
	label.backgroundColor = [UIColor clearColor];
	[transparentView addSubview:activityIndicator];
	[transparentView addSubview:label];
	[self.view addSubview:transparentView];
	
	// Adding transparent view to left side of the split view.
	CGRect transparentViewFrame2 = CGRectMake(0, 0, 768, 768);
	UIView *transparentView2 = [[UIView alloc] initWithFrame:transparentViewFrame2];
	transparentView2.backgroundColor = [UIColor lightTextColor];
	transparentView2.alpha = 0.9;
	transparentView2.tag = 1;
	
	[[[appDelegate.splitViewController.viewControllers objectAtIndex:0] view] addSubview:transparentView2];	
	
	[label release];
	[transparentView release];
	[activityIndicator retain];
}

#pragma mark -
#pragma mark Search Bar Processing

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[self showTransparentModalView:@"Searching..."];
	[appDelegate.GDocImpl fetchDocListWithSearchStr:searchBar.text ofType:@"TitleSearch"];
	[searchBar setShowsCancelButton:NO animated:YES];
	[searchBar resignFirstResponder];
}

-(void)setSearchResultsArray 
{
	self.searchResultsArray = nil;
	self.downloadedFilesArray = nil;
	
	self.searchResultsArray = [[NSMutableArray alloc] init];
	self.downloadedFilesArray = [[NSMutableArray alloc] init];	
	
	if ([appDelegate.GDocImpl docListFeed] != nil) 
	{
		// Looping through feed to download files.
		for (GDataEntryBase *entry in [[appDelegate.GDocImpl docListFeed] entries]) 
		{
			if ([self isDownloadedFile:[[entry title] stringValue]]) {
				[self.downloadedFilesArray addObject:[[entry title] stringValue]];
			}
			else {
				
				[self.searchResultsArray addObject:[[entry title] stringValue]];				
			}
			
		}
		
	}
}

-(BOOL)isDownloadedFile:(NSString *)filename {
		
	NSString *filepath = [appDelegate.userDocumentsFolderPath stringByAppendingPathComponent:filename];
	
	BOOL isDownloaded = NO;
	isDownloaded = ([[NSFileManager defaultManager] fileExistsAtPath:filepath]);
	
	if (!isDownloaded) {
		filepath = [appDelegate.userSearchResultsFolderPath stringByAppendingPathComponent:filename];
		isDownloaded = ([[NSFileManager defaultManager] fileExistsAtPath:filepath]);
	}
	
	return isDownloaded;
}


#pragma mark -
#pragma mark Table View Management

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(section == 0)
		return @"Search Results";
	else
		return @"Downloaded Files";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return [searchResultsArray count];
	}
	else {
		return [downloadedFilesArray count];	
	}
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *selectedFile = nil;
	
	if (indexPath.section == 0) {
		selectedFile = [searchResultsArray objectAtIndex:indexPath.row];
		
		for (GDataEntryBase *entry in [[appDelegate.GDocImpl docListFeed] entries]) {
			if ([selectedFile isEqualToString:[[entry title] stringValue]]) {
				
				NSString *filepath = [appDelegate.userSearchResultsFolderPath stringByAppendingPathComponent:selectedFile];
				[self showTransparentModalView:@"Downloading selected file..."];
				[appDelegate.GDocImpl resetDownloadCounter];
				[appDelegate.GDocImpl setDownloadSize:1];
				[appDelegate.GDocImpl saveDocumentEntry:entry toPath:filepath];
			}
		}
	}
	else {
		selectedFile = [downloadedFilesArray objectAtIndex:indexPath.row];
				
		GDFileViewController *detailViewController = [[GDFileViewController alloc] initWithNibName:@"GDFileViewController" bundle:nil];
		detailViewController.selectedFile = selectedFile;
		detailViewController.source = @"Search";
		
		// Pass the selected object to the new view controller.
		[self.searchNavController pushViewController:detailViewController animated:YES];
		[detailViewController release];		
	}  
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	if (indexPath.section == 0) {
		cell.textLabel.text = [searchResultsArray objectAtIndex:indexPath.row];
		cell.accessoryView = [[ UIImageView alloc ] 
							  initWithImage:[UIImage imageNamed:@"download.png" ]];
	}
	else {
		cell.textLabel.text = [downloadedFilesArray objectAtIndex:indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.accessoryView = nil;
	}
	
	cell.backgroundColor = [UIColor clearColor];
	cell.detailTextLabel.text = @"Updated at 13:25:00 EST";
	
	NSString *imageName = [appDelegate.iconsDictionary objectForKey:[cell.textLabel.text pathExtension]];
	cell.imageView.image = [UIImage imageNamed:imageName];	
	
    return cell;
}



#pragma mark -
#pragma mark Memory Management


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
    [super dealloc];
	[searchResultsArray release];
	[downloadedFilesArray release];
	[tableSearchView release];
	[transparentView release];
	[activityIndicator release];	
}


@end
