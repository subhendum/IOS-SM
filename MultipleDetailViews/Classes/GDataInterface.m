//
//  GDataInterface.m
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GDataInterface.h"
#import "FilesListViewController.h"

@interface GDataInterface (PrivateMethods)

- (GDataServiceGoogleDocs *)docsService;
- (void)setDocListFeed:(GDataFeedDocList *)feed;
- (NSError *)docListFetchError;
- (void)setDocListFetchError:(NSError *)error;
- (GDataServiceTicket *)docListFetchTicket;
- (void)setDocListFetchTicket:(GDataServiceTicket *)ticket;

- (GDataFeedDocRevision *)revisionFeed;
- (void)setRevisionFeed:(GDataFeedDocRevision *)feed;
- (NSError *)revisionFetchError;
- (void)setRevisionFetchError:(NSError *)error;
- (GDataServiceTicket *)revisionFetchTicket;
- (void)setRevisionFetchTicket:(GDataServiceTicket *)ticket;

- (GDataEntryDocListMetadata *)metadataEntry;
- (void)setMetadataEntry:(GDataEntryDocListMetadata *)entry;

- (GDataServiceTicket *)uploadTicket;
- (void)setUploadTicket:(GDataServiceTicket *)ticket;
- (void)fetchMetadataEntry;
- (void)saveDocumentEntry:(GDataEntryBase *)docEntry toPath:(NSString *)path;
- (void)saveDocEntry:(GDataEntryBase *)entry toPath:(NSString *)savePath exportFormat:(NSString *)exportFormat authService:(GDataServiceGoogle *)service;
- (void)saveSpreadsheet:(GDataEntrySpreadsheetDoc *)docEntry toPath:(NSString *)savePath;
-(void)updateUI:(FilesListViewController *)filesListController;
-(void)initExportFormatsDictionary;
-(void)setMimeTypeDictionary;

@end

@implementation GDataInterface

@synthesize user;
@synthesize exportFormatDictionary; 
@synthesize serialDownloadArray;
@synthesize appDelegate;
@synthesize mimeTypeDictionary;

#pragma mark -
#pragma mark Memory Management

-(id)initWithUser:(User *)userData
{
    self = [super init];
    if (self) {
		self.user = userData;
    }
	
	[self initExportFormatsDictionary];
	[self setMimeTypeDictionary];
	imageCounter = 1;
	serialDownloadArray = [[NSMutableArray alloc] init];
	appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    return self;
}

- (void)dealloc {
	[mDocListFeed release];
	[mDocListFetchTicket release];
	[mDocListFetchError release];
	[mRevisionFeed release];
	[mRevisionFetchTicket release];
	[mRevisionFetchError release];
	[mMetadataEntry release];
	[mUploadTicket cancelTicket];
	[mUploadTicket release];
    [super dealloc];
}

#pragma mark -
#pragma mark Document Service

// get an docList service object with the current username/password
//
// A "service" object handles networking tasks.  Service objects
// contain user authentication information as well as networking
// state information (such as cookies and the "last modified" date for
// fetched data.)

- (GDataServiceGoogleDocs *)docsService {
	
	static GDataServiceGoogleDocs* service = nil;
	
	if (!service) {
		service = [[GDataServiceGoogleDocs alloc] init];
		
		[service setShouldCacheDatedData:YES];
		[service setServiceShouldFollowNextLinks:YES];
		[service setIsServiceRetryEnabled:YES];
	}
	
	if ([self.user.username length] && [self.user.password length]) {
		[service setUserCredentialsWithUsername:self.user.username
									   password:self.user.password];
	} else {
		[service setUserCredentialsWithUsername:nil
									   password:nil];
	}
	
	return service;
}


#pragma mark -
#pragma mark Folder ResourceId

// begin retrieving resource id for user's collection folder
- (void)fetchResourceIdForFolder:(NSString *)folderName {
		
	GDataServiceGoogleDocs *service = [self docsService];
	GDataServiceTicket *ticket;
	
	
	NSURL *feedURL = [GDataServiceGoogleDocs docsFeedURL];
	
	GDataQueryDocs *query = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
	
	[query setShouldShowFolders:YES];
	[query setTitleQuery:folderName];
	[query setIsTitleQueryExact:YES];
	
	NSLog(@"Feed Query : %@",[query description]);
	
	ticket = [service fetchFeedWithQuery:query
								delegate:self
					   didFinishSelector:@selector(resourceIdFetchTicket:finishedWithFeed:error:)];
}

// resourceId fetch callback
- (void)resourceIdFetchTicket:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedDocList *)feed
                     error:(NSError *)error {
	NSString *folderName = @"";
	if (feed != nil) {
		GDataEntryBase *entry = [[feed entries] objectAtIndex:0];
		folderName = [[entry title] stringValue];
		NSLog(@"User Collection - %@ with Resource Id - %@",folderName,[entry resourceID]);
		[appDelegate setUserCollectionResourceId:[entry resourceID]];
		[appDelegate setUserDetailsFlag:YES];
	}
	else {
		NSLog(@"No collection found with name %@ ",folderName);
		[appDelegate setUserDetailsFlag:NO];
	}
}

#pragma mark -
#pragma mark Document Feed

// begin retrieving the list of the user's docs
- (void)fetchDocList {
	
	[self setDocListFeed:nil];
	[self setDocListFetchError:nil];
	[self setDocListFetchTicket:nil];
	
	[self resetDownloadCounter];
	
	GDataServiceGoogleDocs *service = [self docsService];
	GDataServiceTicket *ticket;
	
	// Fetching a feed gives us 25 responses by default.  We need to use
	// the feed's "next" link to get any more responses.  If we want more than 25
	// at a time, instead of calling fetchDocsFeedWithURL, we can create a
	// GDataQueryDocs object, as shown here.
	
//	NSURL *feedURL = [GDataServiceGoogleDocs docsFeedURL];
	
	NSURL *feedURL = [GDataServiceGoogleDocs folderContentsFeedURLForFolderID:appDelegate.userCollectionResourceId];
	
	GDataQueryDocs *query = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
	[query setMaxResults:1000];
	[query setShouldShowFolders:YES];

	
	NSLog(@"Feed Query : %@",[query description]);
	
	ticket = [service fetchFeedWithQuery:query
								delegate:self
					   didFinishSelector:@selector(docListFetchTicket:finishedWithFeed:error:)];
	
	[self setDocListFetchTicket:ticket];
	
	// update our metadata entry for this user
	[self fetchMetadataEntry];
	
}

// docList list fetch callback
- (void)docListFetchTicket:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedDocList *)feed
                     error:(NSError *)error {
					
	[self setDocListFeed:feed];
	[self setDocListFetchError:error];
	[self setDocListFetchTicket:nil];
			
	int fileCount = 0;
	
	// Looping through feed to download files.
	
	for (GDataEntryBase *entry in [feed entries]) {
		NSString *fileTitle = [[entry title] stringValue];
				
		NSString *pathToSave = [appDelegate.userDocumentsFolderPath stringByAppendingPathComponent:fileTitle];
		NSString *storedTag = [appDelegate.filesTagDictionary objectForKey:fileTitle];
		
		if (![storedTag isEqualToString:[entry ETag]]) {			
			fileCount = fileCount + 1;
			[appDelegate.filesTagDictionary setObject:[entry ETag] forKey:fileTitle];
			[self saveDocumentEntry:entry toPath:pathToSave];
		}
		else {
			NSLog(@"File is already up-to-date. |-|%@=%@",[entry ETag],storedTag);
		}
		
	}
	if (fileCount == 0) {
		
		appDelegate.isDownloadComplete = @"YES";
		
		// Getting FileListViewController instance from splitViewController 
		UINavigationController *navCtr = [appDelegate.splitViewController.viewControllers objectAtIndex:1];
		[[navCtr.viewControllers objectAtIndex:0] reloadFilesListInTable:counter];
		
	}
	else {
		[self setDownloadSize:fileCount];
	}
}

#pragma mark -
#pragma mark Search Document Feed

// begin retrieving the list of the user's docs
- (void)fetchDocListWithSearchStr:(NSString *)searchStr ofType:(NSString *)ofType {
	
	
	[self resetDownloadCounter];
	
	[self setDocListFeed:nil];
	[self setDocListFetchError:nil];
	[self setDocListFetchTicket:nil];
	
	GDataServiceGoogleDocs *service = [self docsService];
	GDataServiceTicket *ticket;
		
	NSURL *feedURL = [GDataServiceGoogleDocs docsFeedURL];
	
	
	
	GDataQueryDocs *query = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
	[query setMaxResults:1000];
	[query setShouldShowFolders:NO];
	
	if ([ofType isEqualToString:@"TitleSearch"]) {
		[query setTitleQuery:searchStr];	
	}
	else {
		[query setFullTextQueryString:searchStr];
	}

	
	
	ticket = [service fetchFeedWithQuery:query
								delegate:self
					   didFinishSelector:@selector(docListFetchTicketWithSearchStr:finishedWithFeed:error:)];
	
	[self setDocListFetchTicket:ticket];
	
	// update our metadata entry for this user
	[self fetchMetadataEntry];
	
}

// search docList list fetch callback
- (void)docListFetchTicketWithSearchStr:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedDocList *)feed
                     error:(NSError *)error {
	
	
	
	[self setDocListFeed:feed];
	[self setDocListFetchError:error];
	[self setDocListFetchTicket:nil];
			
	UINavigationController *navCtr = [appDelegate.splitViewController.viewControllers objectAtIndex:1];
	[[navCtr.viewControllers objectAtIndex:0] reloadFilesListInTable:counter];
	
}

#pragma mark -
#pragma mark Download Document Feed 

// begin retrieving the list of the user's docs
- (void)fetchDocListForDownload {
	
	[self setDocListFeed:nil];
	[self setDocListFetchError:nil];
	[self setDocListFetchTicket:nil];
	
	[self resetDownloadCounter];
	
	GDataServiceGoogleDocs *service = [self docsService];
	GDataServiceTicket *ticket;
	
	// Fetching a feed gives us 25 responses by default.  We need to use
	// the feed's "next" link to get any more responses.  If we want more than 25
	// at a time, instead of calling fetchDocsFeedWithURL, we can create a
	// GDataQueryDocs object, as shown here.
	
	NSURL *feedURL = [GDataServiceGoogleDocs docsFeedURL];
	
	
	
	GDataQueryDocs *query = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
	[query setMaxResults:1000];
	[query setShouldShowFolders:NO];

	ticket = [service fetchFeedWithQuery:query
								delegate:self
					   didFinishSelector:@selector(docListFetchTicketForDownload:finishedWithFeed:error:)];
	
	[self setDocListFetchTicket:ticket];
	
	// update our metadata entry for this user
	[self fetchMetadataEntry];
	
}

// download docList list fetch callback
- (void)docListFetchTicketForDownload:(GDataServiceTicket *)ticket
          finishedWithFeed:(GDataFeedDocList *)feed
                     error:(NSError *)error {
	
	[self setDocListFeed:feed];
	[self setDocListFetchError:error];
	[self setDocListFetchTicket:nil];
			
	// Getting appropriate ViewController instance from splitViewController 
	UINavigationController *navCtr = [appDelegate.splitViewController.viewControllers objectAtIndex:1];
	[[navCtr.viewControllers objectAtIndex:0] reloadFilesListInTable:counter];	
		
}


#pragma mark -
#pragma mark Serial Document Fetch

// begin retrieving the list of the user's docs
- (void)fetchDocListSerial {
	
	[self setDocListFeed:nil];
	[self setDocListFetchError:nil];
	[self setDocListFetchTicket:nil];
	
	[self resetDownloadCounter];
	
	GDataServiceGoogleDocs *service = [self docsService];
	GDataServiceTicket *ticket;
	
	// Fetching a feed gives us 25 responses by default.  We need to use
	// the feed's "next" link to get any more responses.  If we want more than 25
	// at a time, instead of calling fetchDocsFeedWithURL, we can create a
	// GDataQueryDocs object, as shown here.
	
	NSURL *feedURL = [GDataServiceGoogleDocs docsFeedURL];
			
	GDataQueryDocs *query = [GDataQueryDocs documentQueryWithFeedURL:feedURL];
	[query setMaxResults:1000];
	[query setShouldShowFolders:NO];
		
	ticket = [service fetchFeedWithQuery:query
								delegate:self
					   didFinishSelector:@selector(docListFetchTicketForSerial:finishedWithFeed:error:)];
	
	[self setDocListFetchTicket:ticket];
	
	// update our metadata entry for this user
	[self fetchMetadataEntry];
	
}

// serial docList list fetch callback
- (void)docListFetchTicketForSerial:(GDataServiceTicket *)ticket
					 finishedWithFeed:(GDataFeedDocList *)feed
								error:(NSError *)error {
	
	NSLog(@"Serial Document list fetch complete - %i",[[feed entries] count]);

	
	[self setDocListFeed:feed];
	[self setDocListFetchError:error];
	[self setDocListFetchTicket:nil];
	
	int fileCount = 0;
		
	// Looping through feed to download files.
	for (GDataEntryBase *entry in [feed entries]) {
	
		NSString *fileTitle = [[entry title] stringValue];
		NSString *pathToSave = [appDelegate.userDocumentsFolderPath stringByAppendingPathComponent:fileTitle];
		NSString *storedTag = [appDelegate.filesTagDictionary objectForKey:fileTitle];		
		
		if (![storedTag isEqualToString:[entry ETag]]) {
			fileCount = fileCount + 1;
			if (fileCount == 1) {		
				[appDelegate.filesTagDictionary setObject:[entry ETag] forKey:fileTitle];
				[self saveDocumentEntry:entry toPath:pathToSave];
			}
			else {
				[serialDownloadArray addObject:entry];
				[appDelegate.filesTagDictionary setObject:[entry ETag] forKey:fileTitle];
			}
		}
		else {
			NSLog(@"File is already up-to-date. |-|%@=%@",[entry ETag],storedTag);
		}		
	}
	
	if (fileCount != 0) {
		fileCount--;
	}
	
	if (fileCount == 0) {
		
		appDelegate.isDownloadComplete = @"YES";
		// Getting FileListViewController instance from splitViewController 
		UINavigationController *navCtr = [appDelegate.splitViewController.viewControllers objectAtIndex:1];
		[[navCtr.viewControllers objectAtIndex:0] reloadFilesListInTable:counter];				
	}
	else {
		[self setDownloadSize:fileCount];
	}
	
}



#pragma mark -
#pragma mark Document Metadata


- (void)fetchMetadataEntry {
	[self setMetadataEntry:nil];
	
	NSURL *entryURL = [GDataServiceGoogleDocs metadataEntryURLForUserID:kGDataServiceDefaultUser];
	GDataServiceGoogleDocs *service = [self docsService];
	[service fetchEntryWithURL:entryURL
					  delegate:self
			 didFinishSelector:@selector(metadataTicket:finishedWithEntry:error:)];
}

- (void)metadataTicket:(GDataServiceTicket *)ticket
     finishedWithEntry:(GDataEntryDocListMetadata *)entry
                 error:(NSError *)error {
	[self setMetadataEntry:entry];
	
	if (error != nil) {
		NSLog(@"Error fetching user metadata: %@", error);
	}
}

#pragma mark -
#pragma mark Save Document

// This method is starting point to download document(s) locally
- (void)saveDocumentEntry:(GDataEntryBase *)docEntry
                   toPath:(NSString *)savePath {
	
	//NSLog(@" Method Entry : saveDocumentEntry savePath:%@",savePath);
	// downloading docs, per
	// http://code.google.com/apis/documents/docs/3.0/developers_guide_protocol.html#DownloadingDocs
	
	// when downloading a revision entry, we've added a property above indicating
	// the class of document for which this is a revision
	Class classProperty = [docEntry propertyForKey:@"document class"];
	if (!classProperty) {
		classProperty = [docEntry class];
	}
		
	BOOL isSpreadsheet = [classProperty isEqual:[GDataEntrySpreadsheetDoc class]];
	if (isSpreadsheet) {
		// to save a spreadsheet, we need to authenticate a spreadsheet service
		// object, and then download the spreadsheet file
		[self saveSpreadsheet:(GDataEntrySpreadsheetDoc *)docEntry
					   toPath:savePath];
	} else {
		// since the user has already fetched the doc list, the service object
		// has the proper authentication token.  We'll use the service object
		// to generate an NSURLRequest with the auth token in the header, and
		// then fetch that asynchronously.
		
		GDataServiceGoogleDocs *docsService = [self docsService];
		
		// default export format 
		NSString *exportFormat = @"htm";
		
		// Deciding export format based on document type
		if([docEntry isKindOfClass:[GDataEntryStandardDoc class]]) {
			NSString *keyForFMT = [NSString stringWithFormat:@"%@.%@",[[docEntry class] description],[[[docEntry title] stringValue] pathExtension] ];
			exportFormat = [self.exportFormatDictionary objectForKey:keyForFMT];
		}
		else if([docEntry isKindOfClass:[GDataEntryFileDoc class]]) {
			NSString *keyForFMT = [NSString stringWithFormat:@"%@.%@",[[docEntry class] description],[[[docEntry title] stringValue] pathExtension] ];
			exportFormat = [self.exportFormatDictionary objectForKey:keyForFMT];
		}
		else {
			exportFormat = [self.exportFormatDictionary objectForKey:[[docEntry class] description]];
		}

		[self saveDocEntry:docEntry
					toPath:savePath
			  exportFormat:exportFormat
			   authService:docsService];
		
	}
}

- (void)saveDocEntry:(GDataEntryBase *)entry
              toPath:(NSString *)savePath
        exportFormat:(NSString *)exportFormat
         authService:(GDataServiceGoogle *)service {
	
	
	
	// the content src attribute is used for downloading
	NSURL *exportURL = [[entry content] sourceURL];
	if (exportURL != nil) {
		
		// we'll use GDataQuery as a convenient way to append the exportFormat
		// parameter of the docs export API to the content src URL
		GDataQuery *query = [GDataQuery queryWithFeedURL:exportURL];
		
		[query addCustomParameterWithName:@"exportFormat"
									value:exportFormat];
				
		
		NSURL *downloadURL = [query URL];
		
		// create a file for saving the document
		NSError *error = nil;
		if ([[NSData data] writeToFile:savePath
							   options:NSAtomicWrite
								 error:&error]) {
			NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:savePath];
			
			// read the document's contents asynchronously from the network
			NSURLRequest *request = [service requestForURL:downloadURL
													  ETag:nil
												httpMethod:@"GET"];
			
			GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
			[fetcher setDownloadFileHandle:fileHandle];
			[fetcher beginFetchWithDelegate:self
						  didFinishSelector:@selector(fetcher:finishedWithData:)
							didFailSelector:@selector(fetcher:failedWithError:)];
		} else {
			NSLog(@"Error creating file at %@: %@", savePath, error);
		}
	}
}


// This is a callback method which is called when doc list fetch is complete.
- (void)fetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data {
	
	
	NSLog(@" Method Entry : finishedWithData feed list size:%i counter=%i downloadSize=%i",[[[self docListFeed] entries] count],counter,downloadSize);
	
	if ([appDelegate.downloadType isEqualToString:@"Parallel"]) {
			
		if (counter == downloadSize)
		{
			
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			appDelegate.isDownloadComplete = @"YES";
			
			// Getting appropriate ViewController instance from splitViewController 
			UINavigationController *navCtr = [appDelegate.splitViewController.viewControllers objectAtIndex:1];
			[[navCtr.viewControllers objectAtIndex:0] reloadFilesListInTable:counter];
		}
		else if (downloadSize == 0)
		{
			NSLog(@"Nothing to download.");
			appDelegate.isDownloadComplete = @"YES";
		}
		else {
			counter = counter + 1;
			UINavigationController *navCtr = [appDelegate.splitViewController.viewControllers objectAtIndex:1];
			[[navCtr.viewControllers objectAtIndex:0] reloadFilesListInTable:counter];			
		}

	}
	else {		
		if (downloadSize != 0)
		{					
						
			GDataEntryBase *entry = [serialDownloadArray objectAtIndex:0];
			NSString *fileTitle = [[entry title] stringValue];
			NSString *pathToSave = [appDelegate.userDocumentsFolderPath stringByAppendingPathComponent:fileTitle];
			NSLog(@"Serial Download For file = %@",fileTitle);
			[self saveDocumentEntry:entry toPath:pathToSave];
			downloadSize--;
			[serialDownloadArray removeObjectAtIndex:0];
		}
		else {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			
			// Getting appropriate ViewController instance from splitViewController 
			UINavigationController *navCtr = [appDelegate.splitViewController.viewControllers objectAtIndex:1];
			[[navCtr.viewControllers objectAtIndex:0] reloadFilesListInTable:counter];			
		}
	}
	// successfully saved the document
}


// This is a callback method in case if any error during fetch operation
- (void)fetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error {
	NSLog(@"Fetcher error: %@", [error description]);
}


#pragma mark -
#pragma mark Spreadsheet Document

// This method is called to save spreadsheet document locally.
- (void)saveSpreadsheet:(GDataEntrySpreadsheetDoc *)docEntry
                 toPath:(NSString *)savePath {
	// to download a spreadsheet document, we need a spreadsheet service object,
	// and we first need to fetch a feed or entry with the service object so that
	// it has a valid auth token
	GDataServiceGoogleSpreadsheet *spreadsheetService;
	spreadsheetService = [[[GDataServiceGoogleSpreadsheet alloc] init] autorelease];
	
	GDataServiceGoogleDocs *docsService = [self docsService];
	[spreadsheetService setUserAgent:[docsService userAgent]];
	[spreadsheetService setUserCredentialsWithUsername:[docsService username]
											  password:[docsService password]];
	GDataServiceTicket *ticket;
	ticket = [spreadsheetService authenticateWithDelegate:self
								  didAuthenticateSelector:@selector(spreadsheetTicket:authenticatedWithError:)];
	
	// we'll hang on to the spreadsheet service object with a ticket property
	// since we need it to create an authorized NSURLRequest
	[ticket setProperty:docEntry forKey:@"docEntry"];
	[ticket setProperty:savePath forKey:@"savePath"];
}

// This method is used to get ticket for spreadsheet operation
- (void)spreadsheetTicket:(GDataServiceTicket *)ticket
   authenticatedWithError:(NSError *)error {
	if (error == nil) {
		GDataEntrySpreadsheetDoc *docEntry = [ticket propertyForKey:@"docEntry"];
		NSString *savePath = [ticket propertyForKey:@"savePath"];
		
		[self saveDocEntry:docEntry
					toPath:savePath
			  exportFormat:@"xls"
			   authService:[ticket service]];
	} else {
		// failed to authenticate; give up
		NSLog(@"Spreadsheet authentication error: %@", error);
		return;
	}
}


#pragma mark -
#pragma mark Getters & Setters

// Getter method for document list.
- (GDataFeedDocList *)docListFeed {
	return mDocListFeed;
}

// Setter method for document list.
- (void)setDocListFeed:(GDataFeedDocList *)feed {
	[mDocListFeed autorelease];
	mDocListFeed = [feed retain];
}

// Getter method for document list error.
- (NSError *)docListFetchError {
	return mDocListFetchError;
}

// Setter method for document list error.
- (void)setDocListFetchError:(NSError *)error {
	[mDocListFetchError release];
	mDocListFetchError = [error retain];
}

// Getter method for document list fetch ticket.
- (GDataServiceTicket *)docListFetchTicket {
	return mDocListFetchTicket;
}

// Setter method for document list fetch ticket
- (void)setDocListFetchTicket:(GDataServiceTicket *)ticket {
	[mDocListFetchTicket release];
	mDocListFetchTicket = [ticket retain];
}

// Getter method for document revision
- (GDataFeedDocRevision *)revisionFeed {
	return mRevisionFeed;
}

// Setter method for document revision
- (void)setRevisionFeed:(GDataFeedDocRevision *)feed {
	[mRevisionFeed autorelease];
	mRevisionFeed = [feed retain];
}

// Getter method for document revision error
- (NSError *)revisionFetchError {
	return mRevisionFetchError;
}

// Setter method for document revision error
- (void)setRevisionFetchError:(NSError *)error {
	[mRevisionFetchError release];
	mRevisionFetchError = [error retain];
}

// Getter method for document revision fetch ticket
- (GDataServiceTicket *)revisionFetchTicket {
	return mRevisionFetchTicket;
}

// Setter method for document revision fetch ticket
- (void)setRevisionFetchTicket:(GDataServiceTicket *)ticket {
	[mRevisionFetchTicket release];
	mRevisionFetchTicket = [ticket retain];
}

// Getter method for document metadata
- (GDataEntryDocListMetadata *)metadataEntry {
	return mMetadataEntry;
}

// Setter method for document metadata
- (void)setMetadataEntry:(GDataEntryDocListMetadata *)entry {
	[mMetadataEntry release];
	mMetadataEntry = [entry retain];
}

// Getter method for upload ticket
- (GDataServiceTicket *)uploadTicket {
	return mUploadTicket;
}

// Setter method for upload ticket
- (void)setUploadTicket:(GDataServiceTicket *)ticket {
	[mUploadTicket release];
	mUploadTicket = [ticket retain];
}

#pragma mark -
#pragma mark Utility Methods

- (void)setDownloadSize:(int)size {
	downloadSize = size;
}

- (int)getDownloadSize {
	return downloadSize;
}

- (void)resetDownloadCounter {
	counter = 1;
}

- (int)getCurrentDownloadCounter {
	return counter;
}

-(void)initExportFormatsDictionary {
	self.exportFormatDictionary = [[NSMutableDictionary alloc] init];
	[self.exportFormatDictionary setObject:@"ppt" forKey:@"GDataEntryFileDoc.ppt"];
	[self.exportFormatDictionary setObject:@"ppt" forKey:@"GDataEntryFileDoc.pptx"];
	[self.exportFormatDictionary setObject:@"ppt" forKey:@"GDataEntryPresentationDoc"];
	[self.exportFormatDictionary setObject:@"xls" forKey:@"GDataEntryFileDoc.xlsx"];
	[self.exportFormatDictionary setObject:@"xls" forKey:@"GDataEntryFileDoc.xls"];	
	[self.exportFormatDictionary setObject:@"pdf" forKey:@"GDataEntryPDFDoc"];
	[self.exportFormatDictionary setObject:@"txt" forKey:@"GDataEntryStandardDoc.txt"];
	[self.exportFormatDictionary setObject:@"rtf" forKey:@"GDataEntryFileDoc.rtf"];
	[self.exportFormatDictionary setObject:@"html" forKey:@"GDataEntryFileDoc.html"];
	[self.exportFormatDictionary setObject:@"html" forKey:@"GDataEntryFileDoc.htm"];
	[self.exportFormatDictionary setObject:@"mov" forKey:@"GDataEntryFileDoc.MOV"];
	[self.exportFormatDictionary setObject:@"mov" forKey:@"GDataEntryFileDoc.mov"];	
	[self.exportFormatDictionary setObject:@"gif" forKey:@"GDataEntryFileDoc.gif"];
	[self.exportFormatDictionary setObject:@"jpg" forKey:@"GDataEntryFileDoc.jpg"];
	[self.exportFormatDictionary setObject:@"3gp" forKey:@"GDataEntryFileDoc.3gp"];
	[self.exportFormatDictionary setObject:@"doc" forKey:@"GDataEntryFileDoc.docx"];
	[self.exportFormatDictionary setObject:@"doc" forKey:@"GDataEntryFileDoc.doc"];
	[self.exportFormatDictionary setObject:@"bmp" forKey:@"GDataEntryFileDoc.bmp"];
	[self.exportFormatDictionary setObject:@"png" forKey:@"GDataEntryFileDoc.png"];		
}

-(void)setMimeTypeDictionary {
	
	self.mimeTypeDictionary = [[NSMutableDictionary alloc] init];
	[self.mimeTypeDictionary setObject:@"application/vnd.ms-powerpoint" forKey:@"ppt"];
	[self.mimeTypeDictionary setObject:@"application/vnd.ms-powerpoint" forKey:@"pptx"];
	[self.mimeTypeDictionary setObject:@"application/vnd.ms-excel" forKey:@"xlsx"];
	[self.mimeTypeDictionary setObject:@"application/vnd.ms-excel" forKey:@"xls"];	
	[self.mimeTypeDictionary setObject:@"application/pdf" forKey:@"pdf"];
	[self.mimeTypeDictionary setObject:@"text/plain" forKey:@"txt"];
	[self.mimeTypeDictionary setObject:@"application/rtf" forKey:@"rtf"];
	[self.mimeTypeDictionary setObject:@"text/html" forKey:@"html"];
	[self.mimeTypeDictionary setObject:@"text/html" forKey:@"htm"];
	[self.mimeTypeDictionary setObject:@"video/quicktime" forKey:@"MOV"];
	[self.mimeTypeDictionary setObject:@"video/quicktime" forKey:@"mov"];	
	[self.mimeTypeDictionary setObject:@"image/gif" forKey:@"gif"];
	[self.mimeTypeDictionary setObject:@"image/jpeg" forKey:@"jpg"];
	[self.mimeTypeDictionary setObject:@"image/jpeg" forKey:@"jpeg"];	
	[self.mimeTypeDictionary setObject:@"video/quicktime" forKey:@"3gp"];
	[self.mimeTypeDictionary setObject:@"application/msword" forKey:@"docx"];
	[self.mimeTypeDictionary setObject:@"application/msword" forKey:@"doc"];
	[self.mimeTypeDictionary setObject:@"image/bmp" forKey:@"bmp"];
	[self.mimeTypeDictionary setObject:@"image/png" forKey:@"png"];	
}

@end
