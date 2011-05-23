
/*
     File: AppDelegate.m
 Abstract: Application delegate to add the split view controller's view to the window.
 
 */

#import "AppDelegate.h"
#import "RootViewController.h"
#import "User.h"
#import "SettingsViewController.h"
#import "FilesListViewController.h"

@interface AppDelegate (PrivateMethods)
-(User *)getUserDetailsFromFile;
-(void)storeETagsToFile;
-(void)storeDocLinksToFile;
-(NSMutableDictionary *)loadETagsToDictionary;
-(NSMutableDictionary *)loadDocLinksToDictionary;
-(void)setIconsDictionary;
-(void)writeUserCredentialsToFile;
@end

@implementation AppDelegate

// public variables
@synthesize window;
@synthesize splitViewController;
@synthesize GDocImpl;
@synthesize mainNavigationController;
@synthesize filesTagDictionary;
@synthesize user;
@synthesize iconsDictionary;
@synthesize downloadType;
@synthesize isDownloadComplete;
@synthesize appDocumentsFolderPath;
@synthesize userSearchResultsFolderPath;
@synthesize userDocumentsFolderPath;
@synthesize appConfigFolderPath;
@synthesize filesLinkDictionary;
@synthesize userCollectionResourceId;
@synthesize currentManagedFolder;

#pragma mark -
#pragma mark Delegate Protocol

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

	NSArray *updatedViewControllers = nil;

	// Checks and creates necessary application config.
	[self setupApplicationConfig];
	
	NSLog(@"folder name INIT - %@",self.user.managedFolder);
	
	
	if (!user) {		
		SettingsViewController *settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
		updatedViewControllers = [NSArray arrayWithObjects:
								   [splitViewController.viewControllers objectAtIndex:0],
								   settingsController,nil
								   ];
		[settingsController release];
	}
	else {
		self.GDocImpl = [[GDataInterface alloc] initWithUser:user];
		FilesListViewController *filesController = [[FilesListViewController alloc] init];
		filesController.filesNavigationController = [[UINavigationController alloc] initWithRootViewController:filesController];
		updatedViewControllers = [NSArray arrayWithObjects:
								  [splitViewController.viewControllers objectAtIndex:0],
								  filesController.filesNavigationController,nil
								  ];	
		[filesController release];
	}
	
	splitViewController.viewControllers = updatedViewControllers;
	splitViewController.view.backgroundColor = [UIColor clearColor];	
	mainNavigationController = [[UINavigationController alloc] initWithRootViewController:splitViewController];

	
	[window addSubview:splitViewController.view];
    [window makeKeyAndVisible];
	return YES;
}

// This method stores application data in property files
-(void)applicationWillResignActive:(UIApplication *)application {
	[self storeETagsToFile];
	[self storeDocLinksToFile];
	[self writeUserCredentialsToFile];
}

#pragma mark -
#pragma mark Application Setup

-(void)setupApplicationConfig {

	// Application specific folder paths
	self.appDocumentsFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	self.userDocumentsFolderPath = [self.appDocumentsFolderPath stringByAppendingPathComponent:@"UserGoogleDocs"];
	self.userSearchResultsFolderPath = [self.appDocumentsFolderPath stringByAppendingPathComponent:@"UserSearchResultsDocs"];
	self.appConfigFolderPath = [appDocumentsFolderPath stringByAppendingPathComponent:@"Config"];
	
	[self checkDocumentsFolder];
	
	// loads user authentication details, if present in Plist file.
	[self setUser:[self getUserDetailsFromFile]];
	
	// loads Etags of downloaded files into NSMutableDictionary.
	[self setFilesTagDictionary:[self loadETagsToDictionary]];
	
	// loads html links of downloaded documents into NSMutableDictionary.
	[self setFilesLinkDictionary:[self loadDocLinksToDictionary]];
	
	// setup icons dictionary
	[self setIconsDictionary];
}

// This method checks if app document folder exists. If not it creates it.
-(void)checkDocumentsFolder {
		
	// If UserGoogleDocs folder does not exist, create it 
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.userDocumentsFolderPath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:self.userDocumentsFolderPath attributes:nil];
	}
	
	// If UserSearchResultsDocs folder does not exist, create it 
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.userSearchResultsFolderPath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:self.userSearchResultsFolderPath attributes:nil];		
	}
	
	// If Config folder does not exist, create it 
	if (![[NSFileManager defaultManager] fileExistsAtPath:appConfigFolderPath]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:appConfigFolderPath attributes:nil];		
	}		
}

// This method retrieves user account details from property file and updates UI.
// Returns User object if credentials present in resource file
// Returns nil if values can not be retrieved from property file
-(User *)getUserDetailsFromFile {
	//NSLog(@"Entry - getUserDetailsFromFile");
	
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	
	NSString *plistPath = [self.appConfigFolderPath stringByAppendingPathComponent:@"GData.plist"];
	
	// If property file not found , return nil.
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		return nil;
	}
	
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
	
	if (!temp) {
		NSLog(@"Error reading GData.plist : %@ format:%d",errorDesc,format);	
		return nil;
	}
	
	User *userObj = [[User alloc] initWithUserDetails:[temp objectForKey:@"username"] password:[temp objectForKey:@"password"] managedFolder:[temp objectForKey:@"folder"]];
	
	userCollectionResourceId = [temp objectForKey:@"resourceId"];
	[userCollectionResourceId retain];
	userDetailsAvailableFlag = YES;
	return userObj;
}

// This method stores current file ETags to a property file
-(void)storeETagsToFile {
	
	NSString *plistPath = [self.appConfigFolderPath stringByAppendingPathComponent:@"FilesETags.plist"];	
	
	NSString *error;

	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:self.filesTagDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	if (plistData) {
		
		[plistData writeToFile:plistPath atomically:YES];
	}
	else {
		NSLog(@"Error writing FilesETags.plist file - %@",[error description]);
		
	}	
}

// This method stores document links to a property file
-(void)storeDocLinksToFile {
	
	NSString *plistPath = [self.appConfigFolderPath stringByAppendingPathComponent:@"FilesLinks.plist"];	
	
	NSString *error;
	
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:self.filesLinkDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	if (plistData) {
		
		[plistData writeToFile:plistPath atomically:YES];
	}
	else {
		NSLog(@"Error writing FilesLinks.plist file - %@",[error description]);
	}	
}

// This method loads current file ETags into a mutable dictionary, from a property file.
-(NSMutableDictionary *)loadETagsToDictionary {
	
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	
	NSString *plistPath = [self.appConfigFolderPath stringByAppendingPathComponent:@"FilesETags.plist"];
	
	// If property file not found , return nil.
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		return [[NSMutableDictionary alloc] init];
	}
	
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSMutableDictionary *filesETags = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
	
	if (!filesETags) {
		filesETags = [[NSMutableDictionary alloc] init];
	}		
	
	return filesETags;
}

// This method loads current document links into a mutable dictionary, from a property file.
-(NSMutableDictionary *)loadDocLinksToDictionary {
	
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	
	NSString *plistPath = [self.appConfigFolderPath stringByAppendingPathComponent:@"FilesLinks.plist"];
	
	// If property file not found , return empty dictionary.
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		return [[NSMutableDictionary alloc] init];
	}
	
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSMutableDictionary *filesLinks = (NSMutableDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
	
	if (!filesLinks) {
		filesLinks = [[NSMutableDictionary alloc] init];
	}
	
	return filesLinks;
}

// This method is used to store user's google account credentials to a property file
-(void)writeUserCredentialsToFile {
	
	NSString *error;
	
	NSString *plistPath = [self.appConfigFolderPath stringByAppendingPathComponent:@"GData.plist"];
	
	NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:
							   [NSArray arrayWithObjects:user.username,user.password,user.managedFolder,userCollectionResourceId,nil]
														  forKeys:[NSArray arrayWithObjects:@"username",@"password",@"folder",@"resourceId",nil]]; 
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	if (plistData) {
		
		[plistData writeToFile:plistPath atomically:YES];
	}
	else {
		NSLog(@"Error writing GData.plist file - %@",[error description]);
	}	
}

-(void)setIconsDictionary {
		
	iconsDictionary = [[NSMutableDictionary dictionaryWithObjectsAndKeys:@"pdf.png",@"pdf",
					   @"doc.png",@"doc",
					   @"doc.png",@"docx",	
					   @"png.png",@"png",
					   @"xls.png",@"xls",
					   @"xls.png",@"xlsx",
					   @"txt.png",@"txt",
					   @"jpg.png",@"jpg",
					   @"mov.png",@"mov",
					   @"mov.png",@"MOV",
					   @"avi.png",@"avi",
					   @"mail.png",@"mail",
					   @"ppt.png",@"ppt",
					   @"ppt.png",@"pptx",	
					   @"html.png",@"html",
					   @"html.png",@"htm",
					   @"bmp.png",@"bmp",
					   @"rtf.png",@"rtf",
					   @"gif.png",@"gif",
					   @"3gp.png",@"3gp",
					   nil
					   ] retain];
	
}


-(void)setUserDetailsFlag:(BOOL)isAvailable {
	userDetailsAvailableFlag = isAvailable;
}

-(BOOL)isUserDetailsAvailable {
	return userDetailsAvailableFlag;
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	NSLog(@"Entry - dealloc");
    [splitViewController release];
	
	[mainNavigationController release];
	
    [window release];
    [super dealloc];
}


@end
