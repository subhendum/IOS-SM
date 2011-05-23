//
//  DownloadViewController.m
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DownloadViewController.h"

@interface DownloadViewController ()
-(void)setFilesArray;
-(NSMutableArray *)getDownloadFileArray;
-(NSMutableSet *)getAvailableDownloadFilesSet:(NSArray *)filesArray;
-(void)downloadOptionSelected:(id)target;
-(GDataEntryBase *)getGoogleDocForFilename:(NSString *)filename;
-(void)syncNowButtonPressed:(id)sender;
-(void)showTransparentModalView:(NSString *)message;
-(void)setDownloadedFilesArray;
-(BOOL)isDownloadedFile:(NSString *)filename;
@end

@implementation DownloadViewController

@synthesize availableFilesArray;
@synthesize downloadNavController;
@synthesize appDelegate;
@synthesize downloadFiles;
@synthesize transparentView;
@synthesize activityIndicator;



#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Download";
	
	//Application delegate instance.
	appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];	
	
	// checking for files available for download.
	[appDelegate.GDocImpl fetchDocListForDownload];
	
	// Initialize view arrays
	availableFilesArray = [[NSMutableArray alloc] init];
	downloadFiles = [[NSMutableArray alloc] init];
	
	// Setting background image & colour of the view
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green.jpg"]];	
	backgroundImage.contentMode = UIViewContentModeScaleAspectFill;		
	self.view.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundView = backgroundImage;		
	
	// Setting segmented control for showing download options (Parallel or Serial);
	NSArray *downloadOptions = [[NSArray alloc] initWithObjects:@"Parallel",@"Serial",nil];
	UISegmentedControl *switchFordownloadType = [[UISegmentedControl alloc] initWithItems:downloadOptions];
	[switchFordownloadType setSegmentedControlStyle:UISegmentedControlStyleBar];	
	[switchFordownloadType setSelectedSegmentIndex:0];
	[switchFordownloadType addTarget:self action:@selector(downloadOptionSelected:) forControlEvents:UIControlEventAllEvents];
	UIBarButtonItem *switchItem = [[UIBarButtonItem alloc] initWithCustomView:switchFordownloadType];
	[[self navigationItem] setLeftBarButtonItem:switchItem];
	[switchItem release];	
	
	//default download mode is parallel.
	appDelegate.downloadType = @"Parallel";
	 
    // display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// This method sets the download mode when user changes 
// segmented control button. (Parallel or Serial)
-(void)downloadOptionSelected:(id)target {
	
	if (self.navigationItem.rightBarButtonItem.enabled) {
		
	
	if ([target selectedSegmentIndex] == 0) {
		appDelegate.downloadType = @"Parallel";
		
		// for Parallel mode, display 'Sync Now' button.
		UIBarButtonItem *btnSyncNow = [[UIBarButtonItem alloc] initWithTitle:@"Sync Now" style:UIBarButtonItemStyleBordered target:self action:@selector(syncNowButtonPressed:)];
		[[self navigationItem] setRightBarButtonItem:btnSyncNow];
		[btnSyncNow release];		
	}
	else {
		appDelegate.downloadType = @"Serial";
		
		// Show edit button only when file(s) are available for download.
		if ([availableFilesArray count] > 0) {
			self.navigationItem.rightBarButtonItem = self.editButtonItem;	
		}
		
	}
	NSLog(@" Selected download option = %@ ",appDelegate.downloadType);
	}
}


// Sync Now button handler.
-(void)syncNowButtonPressed:(id)sender {
		
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[self.tableView retain];
	appDelegate.isDownloadComplete = @"NO";
	[self showTransparentModalView:@"Downloading selected files..."];
	
	[appDelegate.GDocImpl resetDownloadCounter];
	[appDelegate.GDocImpl setDownloadSize:[availableFilesArray count]];
	
	if ([appDelegate.downloadType isEqualToString:@"Parallel"]) {
		
		for (NSString *fileName in availableFilesArray) {
			
			NSString *filepath = [appDelegate.userDocumentsFolderPath stringByAppendingPathComponent:fileName];
			[appDelegate.GDocImpl saveDocumentEntry:[self getGoogleDocForFilename:fileName] toPath:filepath];	
		}		
	}
	else {
		appDelegate.GDocImpl.serialDownloadArray = [[NSMutableArray alloc] initWithCapacity:[availableFilesArray count]];
		for (NSString *fileName in availableFilesArray) {
			
			[appDelegate.GDocImpl.serialDownloadArray addObject:[self getGoogleDocForFilename:fileName]];
			NSString *filepath = [appDelegate.userDocumentsFolderPath stringByAppendingPathComponent:fileName];
			[appDelegate.GDocImpl saveDocumentEntry:[self getGoogleDocForFilename:fileName] toPath:filepath];	
		}
		
	}



}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Data Management

-(void)setEditing:(BOOL)editing animated:(BOOL)animate {
	
	if (editing) {
		NSLog(@"Edit mode is ON");
		[super setEditing:editing animated:animate];
	}
	else {
		NSLog(@"Edit mode is OFF");
		[super setEditing:editing animated:animate];
		
		// Show 'Sync Now' button when edit mode is off
		UIBarButtonItem *btnSyncNow = [[UIBarButtonItem alloc] initWithTitle:@"Sync Now" style:UIBarButtonItemStyleBordered target:self action:@selector(syncNowButtonPressed:)];
		[[self navigationItem] setRightBarButtonItem:btnSyncNow];
		[btnSyncNow release];		
	}
	
}

// This method shows transparent view containing activity indicator 
// when download is in progress.
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
	
	[label release];
	[transparentView release];
	[activityIndicator retain];
}


// This is a callback method to refresh table view data.
// This is called by GDataInterface method, when download process is complete.
-(void)reloadFilesListInTable {
	[self setDownloadedFilesArray];
	
	if ([self.availableFilesArray count] == 0) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
		self.navigationItem.leftBarButtonItem.enabled = NO; 
	}
	else {
		self.navigationItem.rightBarButtonItem.enabled = YES;
		self.navigationItem.leftBarButtonItem.enabled = YES;
	}

	
	transparentView = (UIView *)[self.view viewWithTag:1];
	[transparentView removeFromSuperview];
	[self.tableView reloadData];
	[self.tableView setNeedsLayout];
	[self.tableView setNeedsDisplay];
}


// This method sets two arrays to be shown in table view.
-(void)setDownloadedFilesArray {
	
	self.availableFilesArray = nil;
	self.downloadFiles = nil;
	
	self.availableFilesArray = [[NSMutableArray alloc] init];
	self.downloadFiles = [[NSMutableArray alloc] init];	
	
	if ([appDelegate.GDocImpl docListFeed] != nil) 
	{
		// Looping through feed to download files.
		for (GDataEntryBase *entry in [[appDelegate.GDocImpl docListFeed] entries]) 
		{	
			if ([self isDownloadedFile:[[entry title] stringValue]]) 
			{
				[self.downloadFiles addObject:[[entry title] stringValue]];
			}
			else 
			{				
				[self.availableFilesArray addObject:[[entry title] stringValue]];				
			}
		}
		
	}	
	
}

// This method checks if a file exists in the user documents folder
-(BOOL)isDownloadedFile:(NSString *)filename {	
	NSString *filepath = [appDelegate.userDocumentsFolderPath stringByAppendingPathComponent:filename];
	return ([[NSFileManager defaultManager] fileExistsAtPath:filepath]);		
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return [availableFilesArray count];
	}
	else {
		return [downloadFiles count];
	}

    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(section == 0)
		return @"Files available for download";
	else
		return @"Downloaded Files";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Show Detail disclosure button for downloaded files.
	if (indexPath.section == 0)
	{
		cell.textLabel.text = [availableFilesArray objectAtIndex:indexPath.row];
	}
	else {
		cell.textLabel.text = [downloadFiles objectAtIndex:indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;	
	}

	
	NSString *imageName = [appDelegate.iconsDictionary objectForKey:[cell.textLabel.text pathExtension]];
	cell.imageView.image = [UIImage imageNamed:imageName];
	cell.textLabel.textColor = [UIColor blackColor];		
	cell.backgroundColor = [UIColor clearColor];
	cell.showsReorderControl = YES;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return (indexPath.section == 0);
}

// Perform the re-order
-(void) tableView: (UITableView *) tableView moveRowAtIndexPath: (NSIndexPath *) oldPath toIndexPath:(NSIndexPath *) newPath
{
	NSLog(@"moveRowAtIndexPath called");
	NSString *title = [self.availableFilesArray objectAtIndex:[oldPath row]];
	[title retain];
	[self.availableFilesArray removeObjectAtIndex:[oldPath row]];
	[self.availableFilesArray insertObject:title atIndex:[newPath row]];
}

- (void) deselect
{	
	NSLog(@"deselect called");
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	
}

// Respond to user selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath
{
	
	printf("User selected row %d\n", [newIndexPath row] + 1);
	[self performSelector:@selector(deselect) withObject:nil afterDelay:0.5f];
}

// Handle deletion
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	printf("About to delete item %d\n", [indexPath row]);
	[self.availableFilesArray removeObjectAtIndex:[indexPath row]];
	[self.tableView reloadData];
}	

-(GDataEntryBase *)getGoogleDocForFilename:(NSString *)filename {
	NSLog(@"Getting Google Doc object for %@ ",filename);
	for (GDataEntryBase *entry in [[appDelegate.GDocImpl docListFeed] entries]) { 
		NSString *GDocName = [[entry title] stringValue];
		if ([filename isEqualToString:GDocName]) {
			return entry;
		}
	
	}
	NSLog(@"No Google Doc object found for file - %@ ",filename);
	return nil;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
	[availableFilesArray release];
    [super dealloc];
}


@end

