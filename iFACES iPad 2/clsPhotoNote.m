//
//  clsPhotoNote.m
//  iFACES
//
//  Created by Hardik Zaveri on 13/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsPhotoNote.h"
#import "iFACESAppDelegate.h" 

@implementation clsPhotoNote

@synthesize spinner;
@synthesize txtTitlePhoto; 
@synthesize imgView;
@synthesize btnAddPhoto;
@synthesize sTitle;
@synthesize locationManager;
@synthesize sLatitude;
@synthesize sLongitude;
@synthesize imgData;
@synthesize btnSavePhoto;
@synthesize txtTags;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		self.title = @"Photo Note";
	}
	return self;
}

- (IBAction)btnAddPhoto_Click:(id) sender
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.delegate = self;
	imagePickerController.allowsEditing = YES;
	//imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@"Camera Not Available" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        return;
    }
    
    [appDelegate.navigationController presentModalViewController:imagePickerController animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	// provide my own Save button to dismiss the keyboard
	UIBarButtonItem* saveItemPhoto = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(saveActionPhoto:)];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIViewController *vwController = [[[appDelegate navigationController] viewControllers] objectAtIndex:3];
	if(vwController.tabBarController == nil)
	{
		vwController.navigationItem.rightBarButtonItem = saveItemPhoto;
	}
	else
	{
		vwController.tabBarController.navigationItem.rightBarButtonItem = saveItemPhoto;
	}
	[saveItemPhoto release];
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */


 //If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad 
{
	txtTitlePhoto.font = [UIFont systemFontOfSize:17.5];
	txtTags.font = [UIFont systemFontOfSize:17.5];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_back.png"]];
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    [imageView release];        
	
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.sOperationMode == @"EDIT")
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql;
			sqlite3_stmt *statement;  
			sql = "select media_blob, title, coalesce(media_tags, '') from tblEntity_Media where iMediaID=? and Media_type=1";
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_int(statement, 1, appDelegate.iMediaID);
				if(sqlite3_step(statement) == SQLITE_ROW) 
				{
					self.imgData = [[NSData alloc] init];
					self.imgData = [NSData dataWithBytes:sqlite3_column_blob(statement, 0) length:sqlite3_column_bytes(statement, 0)];
					self.imgView.image = [[UIImage alloc] initWithData:imgData];
					self.txtTitlePhoto.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
					txtTags.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
					//self.imgView.transform = CGAffineTransformRotate(self.imgView.transform, M_PI);
				}
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
			sql = nil;
		} 
		else 
		{
			// Even though the open failed, call close to properly clean up resources.
			sqlite3_close(database);
			NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
			// Additional error handling, as appropriate...
		}
		path = nil;
		paths = nil;
		documentsDirectory = nil;
		
 		btnAddPhoto.hidden = NO;
	}
	else
	{
		iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
		imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		imagePickerController.allowsEditing = YES;
		imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		[appDelegate.navigationController presentModalViewController:imagePickerController animated:YES];
		btnAddPhoto.hidden = YES;
	}
}
 
- (void)saveActionPhoto:(id)sender
{	
	[txtTitlePhoto resignFirstResponder];
	[txtTags resignFirstResponder];
	
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIViewController *vwController = [[[appDelegate navigationController] viewControllers] objectAtIndex:3];
	if(vwController.tabBarController == nil)
	{
		vwController.navigationItem.rightBarButtonItem = nil;
	}
	else
	{
		vwController.tabBarController.navigationItem.rightBarButtonItem = nil;
	}
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[spinner release];
	[txtTitlePhoto release];
	[imgView release];
	[btnAddPhoto release];
	[btnSavePhoto release];
	[imagePickerController release];
	[sTitle release];
	[locationManager release];
	[sLatitude release];
	[sLongitude release];
	[imgData release];
	[txtTags release];
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[spinner release];
	[txtTitlePhoto release];
	[imgView release];
	[btnAddPhoto release];
	[btnSavePhoto release];
	[imagePickerController release];
	[sTitle release];
	[locationManager release];
	[sLatitude release];
	[sLongitude release];
	[imgData release];
	[txtTags release];
	[super dealloc];
}

-(void) locationManager:(CLLocationManager *) manager didUpdateToLocation: (CLLocation *) newLocation fromLocation: (CLLocation *) oldLocation
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.iMediaType == 1)
	{
		NSDate *eventDate = newLocation.timestamp;
		NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
		if(abs(howRecent) < 3.0)
		{
			self.sLatitude = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.latitude]; 
			self.sLongitude = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.longitude];
			[locationManager stopUpdatingLocation];
			[locationManager release];
			[self SaveImage];
		}
	}
	
}


// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.iMediaType == 1)
	{
		[locationManager release];
		sLongitude = @"0.00";
		sLatitude = @"0.00";
		[self SaveImage];
	}
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	
	self.imgData = [[NSData alloc] init];
	self.imgData = UIImageJPEGRepresentation(image, 0.0);
	imgView.image = image;
	[picker release];
	
}

- (IBAction)btnSavePhoto_Click:(id) sender
{
	[spinner startAnimating];
	locationManager = [[[CLLocationManager alloc] init] retain];
	locationManager.delegate = self;
	locationManager.distanceFilter = 0;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startUpdatingLocation];
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	// Dismiss the image selection and close the program
	[[picker parentViewController] dismissModalViewControllerAnimated:YES];
	[picker release];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.navigationController popViewControllerAnimated:YES];
	
}


- (void) SaveImage
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
	const char *sql;
	
	NSString *date;
	NSDate *now = [[NSDate alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss "];
	date = [dateFormatter stringFromDate:now];

	sqlite3_stmt *statement;  
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
	{
		appDelegate.blnRefreshPage = TRUE;
		if(appDelegate.sOperationMode ==@"EDIT")
		{
			sql = "update tblEntity_Media set title = ?, media_blob = ?, updateDate = ?, media_tags = ? where iMediaID = ?";
		    
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_text(statement, 1, [txtTitlePhoto.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_blob(statement, 2, [imgData bytes], [imgData length], SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 3, [date UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 4, [txtTags.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statement, 5, appDelegate.iMediaID);
				sqlite3_step(statement);
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
		}
		else
		{
			sql = "Insert Into tblEntity_Media (iEntityID, media_blob, Media_type, title, addDate, latitude, longitude, media_tags) values (?, ?, ?, ?, ?, ?, ?, ?)";
		    
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_int(statement, 1, appDelegate.iContactEntityID);
				sqlite3_bind_blob(statement, 2, [imgData bytes], [imgData length], SQLITE_TRANSIENT);
				sqlite3_bind_int(statement, 3, 1);
				sqlite3_bind_text(statement, 4, [txtTitlePhoto.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 5, [date UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 6, [sLatitude UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 7, [sLongitude UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 8, [txtTags.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_step(statement);
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);	
			
			sql = "Select Max(iMediaID) from tblEntity_Media";
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				if(sqlite3_step(statement)  == SQLITE_ROW) 
				{
					appDelegate.iMediaID = sqlite3_column_double(statement, 0);
					appDelegate.sOperationMode = @"EDIT";	
					btnAddPhoto.hidden = NO;
				}
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
		}
		date = nil;
		[dateFormatter release];
		[now release];
		sql = nil;
	}
	else 
	{
		// Even though the open failed, call close to properly clean up resources.
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		// Additional error handling, as appropriate...
	}
	path = nil;
	paths = nil;
	documentsDirectory = nil;
	[spinner stopAnimating];
}
@end
