//
//  GDataInterface.h
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataDocs.h"
#import "GDataSpreadsheet.h"
#import "User.h"
#import "AppDelegate.h"

@class FilesListViewController;
@class AppDelegate;

@interface GDataInterface : NSObject {

	GDataFeedDocList *mDocListFeed;
	GDataServiceTicket *mDocListFetchTicket;
	NSError *mDocListFetchError;
	GDataFeedDocRevision *mRevisionFeed;
	GDataServiceTicket *mRevisionFetchTicket;
	NSError *mRevisionFetchError;
	GDataEntryDocListMetadata *mMetadataEntry;
	GDataServiceTicket *mUploadTicket;
	int counter;	
	int downloadSize;
	User *user;	
	NSMutableDictionary *exportFormatDictionary;
	NSMutableDictionary *mimeTypeDictionary;	
	int imageCounter;
	NSMutableArray *serialDownloadArray;
	AppDelegate *appDelegate;
}

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) NSMutableDictionary *exportFormatDictionary;
@property (nonatomic, retain) NSMutableDictionary *mimeTypeDictionary;
@property (nonatomic, retain) NSMutableArray *serialDownloadArray;

//-(id)init;
-(id)initWithUser:(User *)userData;
- (void)fetchDocList;
- (void)fetchDocListWithSearchStr:(NSString *)searchStr ofType:(NSString *)ofType;
- (GDataFeedDocList *)docListFeed;
- (void)setDownloadSize:(int)size;
- (int)getDownloadSize;
- (int)getCurrentDownloadCounter;
- (void)resetDownloadCounter;
- (void)fetchDocListForDownload;
- (void)fetchDocListSerial;
- (void)saveDocumentEntry:(GDataEntryBase *)docEntry
                   toPath:(NSString *)savePath;
- (void)fetchResourceIdForFolder:(NSString *)folderName;

@end
