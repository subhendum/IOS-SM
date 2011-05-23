
/*
     File: AppDelegate.h
 Abstract: Application delegate to add the split view controller's view to the window.
 
 */

#import <UIKit/UIKit.h>
#import "GDataInterface.h"

@class RootViewController;
@class FilesListViewController;
@class GDataInterface;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
	UISplitViewController *splitViewController;
	UINavigationController *mainNavigationController;
	
	User *user;
	GDataInterface *GDocImpl;
	NSString *downloadType;
	NSString *isDownloadComplete;
	BOOL userDetailsAvailableFlag;	
	NSString *userCollectionResourceId;
	NSString *currentManagedFolder;
	
	// Application folders paths
	NSString *appDocumentsFolderPath;
	NSString *userDocumentsFolderPath;	
	NSString *userSearchResultsFolderPath;
	NSString *appConfigFolderPath;
	
	// Application Dictionaries
	NSMutableDictionary *filesTagDictionary;
	NSMutableDictionary *filesLinkDictionary;
	NSMutableDictionary *iconsDictionary;	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) GDataInterface *GDocImpl;
@property (nonatomic, retain) UINavigationController *mainNavigationController;
@property (nonatomic, retain) NSMutableDictionary *filesTagDictionary;
@property (nonatomic, retain) NSMutableDictionary *filesLinkDictionary;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSDictionary *iconsDictionary;
@property (nonatomic, retain) NSString *downloadType;
@property (nonatomic, retain) NSString *isDownloadComplete;
@property (nonatomic, retain) NSString *appDocumentsFolderPath;
@property (nonatomic, retain) NSString *userSearchResultsFolderPath;
@property (nonatomic, retain) NSString *userDocumentsFolderPath;
@property (nonatomic, retain) NSString *appConfigFolderPath;
@property (nonatomic, retain) NSString *userCollectionResourceId;
@property (nonatomic, retain) NSString *currentManagedFolder;

// public methods
-(void)setupApplicationConfig;
-(void)checkDocumentsFolder;
-(void)setUserDetailsFlag:(BOOL)isAvailable;
-(BOOL)isUserDetailsAvailable;

@end

