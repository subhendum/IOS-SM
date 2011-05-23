//
//  FilesListViewController.m
//  Brown-Forman-GDocSync
//
//  Created by Suyash Kaulgud on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilesListViewController.h"
#import "SecondDetailViewController.h"
#import "GDFileViewController.h"
#import "DownloadedFile.h"
#import "Reachability.h"

@interface FilesListViewController ()
- (NSMutableArray *)getDownloadedFileArray;
-(void)initAndPlayMovie:(NSURL *)movieURL;
-(void)setMoviePlayerUserSettings;
-(void)playVideo:(NSString *)videoFileName;
-(void)syncNowButtonPressed:(id)sender;
-(void)showTransparentModalView:(NSString *)message;
-(NSString *)stringFromFileSize:(int)size;
-(int)sizeOfFile:(NSString *)path;
-(NSString *)dateOfFile:(NSString *)path;
-(void)downloadOptionSelected:(id)target;
-(BOOL)isInternetConnectivityAvailable;
@end

NSString *kScalingModeKey	= @"scalingMode";
NSString *kControlModeKey	= @"controlMode";
NSString *kBackgroundColorKey	= @"backgroundColor";

@implementation FilesListViewController
@synthesize filesList;
@synthesize progressView;
@synthesize timer;
@synthesize fileIcons;
@synthesize appDelegate;
@synthesize filesListTableView;
@synthesize filesNavigationController;
@synthesize moviePlayer;
@synthesize activityIndicator;
@synthesize transparentView;

#pragma mark -
#pragma mark Helper Methods

-(BOOL)isInternetConnectivityAvailable {
	
	Reachability *internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"@@@@@@@@@@@ !!!!!!! Internet Connection Not Available !!!!!!! @@@@@@@@@@@");
			return NO;
            break;
        }
    }
	
}

#pragma mark -
#pragma mark View lifecycle


-(NSString *)stringFromFileSize:(int)size {
	
	float floatSize = size;
	if (size < 1023)
		return([NSString stringWithFormat:@"%i bytes",size]);
	floatSize = floatSize / 1024;
	if (floatSize < 1023)
		return ([NSString stringWithFormat:@"%1.1f KB",floatSize]);
	floatSize = floatSize / 1024;
	if (floatSize < 1023)
		return ([NSString stringWithFormat:@"%1.1f MB",floatSize]);
	floatSize = floatSize / 1024;	
	if (floatSize < 1023)
		return ([NSString stringWithFormat:@"%1.1f GB",floatSize]);
	return @"";
}

-(int)sizeOfFile:(NSString *)path {
	NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:NO];
	int fileSize = (int)[fileAttributes fileSize];
	return fileSize;
}

-(NSString *)dateOfFile:(NSString *)path {
	NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:NO];
	NSString *date = [fileAttributes objectForKey:@"NSFileModificationDate"];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateStyle:NSDateFormatterLongStyle];
	return [formatter stringFromDate:date];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Managed Folder";
	
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green.jpg"]];	
	backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
			
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	[self.tableView setBackgroundView:nil];
	self.view.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundColor = [UIColor clearColor];
	
	appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
 		
	filesList = [self getDownloadedFileArray];
	[filesList retain];
	
	
	// Setting segmented control for showing download options (Parallel or Serial);
	NSArray *downloadOptions = [[NSArray alloc] initWithObjects:@"Parallel",@"Serial",nil];
	UISegmentedControl *switchFordownloadType = [[UISegmentedControl alloc] initWithItems:downloadOptions];
	[switchFordownloadType setSegmentedControlStyle:UISegmentedControlStyleBar];	
	[switchFordownloadType setSelectedSegmentIndex:0];
	appDelegate.downloadType = @"Parallel";
	[switchFordownloadType addTarget:self action:@selector(downloadOptionSelected:) forControlEvents:UIControlEventAllEvents];
	UIBarButtonItem *switchItem = [[UIBarButtonItem alloc] initWithCustomView:switchFordownloadType];
	[[self navigationItem] setLeftBarButtonItem:switchItem];
	[switchItem release];
	
	UIBarButtonItem *btnSyncNow = [[UIBarButtonItem alloc] initWithTitle:@"Sync Now" style:UIBarButtonItemStyleBordered target:self action:@selector(syncNowButtonPressed:)];
	[[self navigationItem] setRightBarButtonItem:btnSyncNow];
	[btnSyncNow release];
	
	self.view.backgroundColor = [UIColor clearColor];
	self.tableView.backgroundView = backgroundImage;	
}

-(void)downloadOptionSelected:(id)target {
	
	if ([target selectedSegmentIndex] == 0) {
		appDelegate.downloadType = @"Parallel";
		UIBarButtonItem *btnSyncNow = [[UIBarButtonItem alloc] initWithTitle:@"Sync Now" style:UIBarButtonItemStyleBordered target:self action:@selector(syncNowButtonPressed:)];
		[[self navigationItem] setRightBarButtonItem:btnSyncNow];
		[btnSyncNow release];		
	}
	else {
		appDelegate.downloadType = @"Serial";
		if ([filesList count] > 0) {
			self.navigationItem.rightBarButtonItem = self.editButtonItem;	
		}
		
	}
	NSLog(@" Selected download option = %@ ",appDelegate.downloadType);
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
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, round((self.view.frame.size.height-100)/2), 550, 30)];
	label.textAlignment = UITextAlignmentCenter;
	label.text = message;
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue-left.png"]];
	label.alpha = 0.9;
	label.tag = 3;
	[transparentView addSubview:activityIndicator];
	[transparentView addSubview:label];
	
	progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	progressView.progress = 0.0;
	progressView.frame = CGRectMake(100, 335, 550, 100);
	progressView.tag = 2;
	[transparentView addSubview:progressView];
	
	[self.view addSubview:transparentView];
	
	// Adding transparent view to left side of the split view.
	CGRect transparentViewFrame2 = CGRectMake(0, 0, 768, 768);
	UIView *transparentView2 = [[UIView alloc] initWithFrame:transparentViewFrame2];
	transparentView2.backgroundColor = [UIColor lightTextColor];
	transparentView2.alpha = 0.9;
	transparentView2.tag = 1;
	
	[[[appDelegate.splitViewController.viewControllers objectAtIndex:0] view] addSubview:transparentView2];
	
	
	[label release];
	[progressView release];
	[transparentView release];
	[activityIndicator retain];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

// This method returns array of filenames from application's document folder.
- (NSMutableArray *)getDownloadedFileArray {
//	NSLog(@"Entry - getDownloadedFileArray");
		
	NSError *error;
	
	NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appDelegate.userDocumentsFolderPath error:&error];
	
	NSMutableArray *fileArray = nil;
	
	if (folderContents == nil) {
		NSLog(@"%@ does not exist",appDelegate.userDocumentsFolderPath);
	}
	else if ([folderContents count] == 0) {
		NSLog(@"%@ is empty",appDelegate.userDocumentsFolderPath);
	}
	else {
		NSLog(@" %@ contains %i documents",appDelegate.userDocumentsFolderPath, [folderContents count]);
		
		fileArray = [[NSMutableArray alloc] initWithCapacity:[folderContents count]];
		
		for (NSString *name in folderContents) {
			DownloadedFile *file = [[DownloadedFile alloc] init];
			[file setFileName:name];
			[file setFileSize:[self  stringFromFileSize:[self sizeOfFile:[appDelegate.userDocumentsFolderPath stringByAppendingPathComponent:name]]]];
			[file setModifiedDate:[self dateOfFile:[appDelegate.userDocumentsFolderPath stringByAppendingPathComponent:name]]];
			[fileArray addObject:file];
			file = nil;
		}
	}
	
	return fileArray;
}

// Sync Now button process.
-(void)syncNowButtonPressed:(id)sender {
	//NSLog(@"Entry - syncNowButtonPressed");
	
	if (![appDelegate isUserDetailsAvailable]) {
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Google account details not avaiable" message:@"Please use Settings screen to save your google account credentials."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}	
	else if (![self isInternetConnectivityAvailable]) {
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connectivity" message:@"No Internet Connection"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];
	}
	else {
			
		[self showTransparentModalView:[NSString stringWithFormat:@"Syncing files from collection : %@",[[appDelegate user] managedFolder]]];
		self.navigationItem.rightBarButtonItem.enabled = NO;
		[self.tableView retain];
		[appDelegate setIsDownloadComplete:@"NO"];
		if ([[appDelegate downloadType] isEqualToString:@"Parallel"]) {
			[appDelegate.GDocImpl fetchDocList];
			NSLog(@"Downloading parallel");
		}
		else {
			[appDelegate.GDocImpl fetchDocListSerial];
			NSLog(@"Dowloading serial");
		}
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

-(void)reloadFilesListInTable:(int)currentCounter {
		
	filesList = [self getDownloadedFileArray];
	[self.tableView reloadData];
	[self.tableView setNeedsLayout];
	[self.tableView setNeedsDisplay];
	[filesList retain];
	
	if ([appDelegate.isDownloadComplete isEqualToString:@"YES"]) {
		
		self.navigationItem.rightBarButtonItem.enabled = YES;
		
		// removing transparent view from right side of split view.
		transparentView = (UIView *)[self.view viewWithTag:1];
		[transparentView removeFromSuperview];	
		
		// removing transparent view from left side of split view.
		UIView *leftTransparentView = [[[appDelegate.splitViewController.viewControllers objectAtIndex:0] view] viewWithTag:1];
		[leftTransparentView removeFromSuperview];
	}
	else {
		transparentView = (UIView *)[self.view viewWithTag:1];
		UIProgressView *pView = (UIProgressView *)[transparentView viewWithTag:2];
		UILabel *lab = (UILabel *)[transparentView viewWithTag:3];
		lab.text = [NSString stringWithFormat:@"Syncing file %i of %i",currentCounter,[appDelegate.GDocImpl getDownloadSize]];
		pView.progress =  pView.progress + ((float)1/[appDelegate.GDocImpl getDownloadSize]);
		NSLog(@"\nProgress update : %f",pView.progress);
	}

}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [filesList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"Entry - cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	DownloadedFile *downloadedFile = [filesList objectAtIndex:indexPath.row];
	cell.textLabel.text = [downloadedFile fileName];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Size : [%@]  Last Updated At : [%@]",[downloadedFile fileSize],[downloadedFile modifiedDate]];

	
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	
	NSString *imageName = [appDelegate.iconsDictionary objectForKey:[cell.textLabel.text pathExtension]];
	cell.imageView.image = [UIImage imageNamed:imageName];
	cell.textLabel.textColor = [UIColor blackColor];
	cell.backgroundColor = [UIColor clearColor];
		
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	DownloadedFile *downloadedFile = [filesList objectAtIndex:indexPath.row];
	
	NSString *fileName = [downloadedFile fileName];
	

	GDFileViewController *detailViewController = [[GDFileViewController alloc] initWithNibName:@"GDFileViewController" bundle:nil];
	detailViewController.selectedFile = fileName;
	
	// Pass the selected object to the new view controller.
	[self.filesNavigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
    
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animate {
	[super setEditing:editing animated:animate];
	if (editing) {
		NSLog(@"Edit mode is ON");
	}
	else {
		NSLog(@"Edit mode is OFF");
		UIBarButtonItem *btnSyncNow = [[UIBarButtonItem alloc] initWithTitle:@"Sync Now" style:UIBarButtonItemStyleBordered target:self action:@selector(syncNowButtonPressed:)];
		[[self navigationItem] setRightBarButtonItem:btnSyncNow];
		[btnSyncNow release];		
	}

}


#pragma mark -
#pragma mark Video Player

- (void)playVideo:(NSString *)videoFileName {
	//NSLog(@"Method Entry : playVideo : %@",videoFileName);
	
	// Register to receive a notification that the movie is now in memory and ready to play
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(moviePreloadDidFinish:) 
												 name:MPMoviePlayerContentPreloadDidFinishNotification 
											   object:nil];
	
	// Register to receive a notification when the movie has finished playing. 
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(moviePlayBackDidFinish:) 
												 name:MPMoviePlayerPlaybackDidFinishNotification 
											   object:nil];
	
	// Register to receive a notification when the movie scaling mode has changed. 
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(movieScalingModeDidChange:) 
												 name:MPMoviePlayerScalingModeDidChangeNotification 
											   object:nil];	
	
		
	NSString *pathToFile = [appDelegate.userDocumentsFolderPath stringByAppendingPathComponent:videoFileName];
		
	NSURL *url = [NSURL fileURLWithPath:pathToFile];	
	
	[self initAndPlayMovie:url];
}

//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
	/* 
	 < add your code here >
	 
	 MPMoviePlayerController* moviePlayerObj=[notification object];
	 etc.
	 */
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    /*     
	 < add your code here >
	 
	 MPMoviePlayerController* moviePlayerObj=[notification object];
	 etc.
	 */	
}

//  Notification called when the movie scaling mode has changed.
- (void) movieScalingModeDidChange:(NSNotification*)notification
{
    /* 
	 < add your code here >
	 
	 MPMoviePlayerController* moviePlayerObj=[notification object];
	 etc.
	 */
}

-(void)setMoviePlayerUserSettings
{
    /* First get the movie player settings defaults (scaling, controller type and background color)
	 set by the user via the built-in iPhone Settings application */
	
    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kScalingModeKey];
    if (testValue == nil)
    {
        // No default movie player settings values have been set, create them here based on our 
        // settings bundle info.
        //
        // The values to be set for movie playback are:
        //
        //    - scaling mode (None, Aspect Fill, Aspect Fit, Fill)
        //    - controller mode (Standard Controls, Volume Only, Hidden)
        //    - background color (Any UIColor value)
        //
        
        NSString *pathStr = [[NSBundle mainBundle] bundlePath];
        NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
        NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
        
        NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
        NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
        
        NSNumber *controlModeDefault;
        NSNumber *scalingModeDefault;
        NSNumber *backgroundColorDefault;
        
        NSDictionary *prefItem;
        for (prefItem in prefSpecifierArray)
        {
            NSString *keyValueStr = [prefItem objectForKey:@"Key"];
            id defaultValue = [prefItem objectForKey:@"DefaultValue"];
            
            if ([keyValueStr isEqualToString:kScalingModeKey])
            {
                scalingModeDefault = defaultValue;
            }
            else if ([keyValueStr isEqualToString:kControlModeKey])
            {
                controlModeDefault = defaultValue;
            }
            else if ([keyValueStr isEqualToString:kBackgroundColorKey])
            {
                backgroundColorDefault = defaultValue;
            }
        }
        
        // since no default values have been set, create them here
        NSDictionary *appDefaults =  [NSDictionary dictionaryWithObjectsAndKeys:
                                      scalingModeDefault, kScalingModeKey,
                                      controlModeDefault, kControlModeKey,
                                      backgroundColorDefault, kBackgroundColorKey,
                                      nil];
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
	
    /* Now apply these settings to the active Movie Player (MPMoviePlayerController) object  */
	
    /* 
	 Movie scaling mode can be one of: MPMovieScalingModeNone, MPMovieScalingModeAspectFit,
	 MPMovieScalingModeAspectFill, MPMovieScalingModeFill.
	 */
    self.moviePlayer.scalingMode = [[NSUserDefaults standardUserDefaults] integerForKey:kScalingModeKey];
    
    /* 
	 Movie control mode can be one of: MPMovieControlModeDefault, MPMovieControlModeVolumeOnly,
	 MPMovieControlModeHidden.
	 */
    self.moviePlayer.movieControlMode = [[NSUserDefaults standardUserDefaults] integerForKey:kControlModeKey];
	
    /*
	 The color of the background area behind the movie can be any UIColor value.
	 */
    UIColor *colors[15] = {[UIColor blackColor], [UIColor darkGrayColor], [UIColor lightGrayColor], [UIColor whiteColor], 
        [UIColor grayColor], [UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], 
        [UIColor yellowColor], [UIColor magentaColor],[UIColor orangeColor], [UIColor purpleColor], [UIColor brownColor], 
        [UIColor clearColor]};
	self.moviePlayer.backgroundColor = colors[ [[NSUserDefaults standardUserDefaults] integerForKey:kBackgroundColorKey] ];
}

-(void)initAndPlayMovie:(NSURL *)movieURL
{
	// Initialize a movie player object with the specified URL
	MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
	if (mp)
	{
		// save the movie player object
		self.moviePlayer = mp;
		[mp release];
		
		// Apply the user specified settings to the movie player object
		[self setMoviePlayerUserSettings];
		
		[[self.moviePlayer view] setFrame:[self.view bounds]];
		[self.view addSubview:[self.moviePlayer view]];
		
		// Play the movie!
		[self.moviePlayer play];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	//NSLog(@"Entry - didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
	[filesList release];
	[appDelegate release];
    [super dealloc];
}


@end

