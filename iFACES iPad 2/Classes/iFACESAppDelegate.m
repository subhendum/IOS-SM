//
//  iFACESAppDelegate.m
//  iFACES
//
//  Created by Hardik Zaveri on 05/09/08.
//  Copyright Deloitte  2008. All rights reserved.
//

#import "iFACESAppDelegate.h"
#import "clsLogin.h"
#import "clsHome.h"

@implementation iFACESAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize objLogin;
@synthesize objHome;
@synthesize navigationController;
@synthesize objCaseload;
@synthesize iFACESSSN;
@synthesize iEntityID;
@synthesize iMediaID;
@synthesize iCaseID;
@synthesize sCaseName;
@synthesize sMediaFileSelected;
@synthesize iContactEntityID;
@synthesize iContactID;
@synthesize sOperationMode;
@synthesize sContactName;
@synthesize iMediaType;
@synthesize sCaseOpenDate;
@synthesize blnRefreshPage;
@synthesize blnRefreshContactsPage;
@synthesize sMapQuery;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	[self createEditableCopyOfDatabaseIfNeeded];
	
	if(objHome == nil)
		objHome = [[clsHome alloc] initWithNibName:@"nHome" bundle:nil];
	[window addSubview:objHome.view];
	
//	
//	NSTimer *timer;
//	timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
    
    if(objLogin == nil)
		objLogin = [[clsLogin alloc] initWithNibName:@"nLogin" bundle:nil];

    
	[window addSubview:objLogin.view];  
	[window makeKeyAndVisible];
}

-(IBAction)handleTimer: (id) sender
{
	[sender release];
	if(objLogin == nil)
		objLogin = [[clsLogin alloc] initWithNibName:@"nLogin" bundle:nil];
	
	[window addSubview:objLogin.view];
}


- (void)dealloc {
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[objHome release];
	[tabBarController release];
	[navigationController release];
	[window release];
	[super dealloc];
}

- (void)LoggedInSuccessful 
{
	if(objCaseload == nil)
		objCaseload = [[clsCaseLoad alloc] initWithNibName:@"nCaseload" bundle:nil];
	navigationController = [[UINavigationController alloc] initWithRootViewController:objCaseload];
	[window addSubview:navigationController.view];
}
- (void)createEditableCopyOfDatabaseIfNeeded 
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    
    NSLog(@" DB PATH : %@ ",writableDBPath);
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iFaces.db"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) 
	{
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
	/*defaultDBPath = nil;
	writableDBPath = nil;
	documentsDirectory = nil;
	paths = nil;
	error = nil;
	fileManager = nil;
	
	[defaultDBPath release];
	[writableDBPath release];
	[documentsDirectory release];
	[paths release];
	[error release];
	[fileManager release];*/
	
}
//[tabBarController setSelectedViewController:[[tabBarController viewControllers] objectAtIndex:1]];

@end
