//
//  clsTextNote.m
//  iFACES
//
//  Created by Hardik Zaveri on 18/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsTextNote.h"
#import "sqlite3.h"
#import "iFACESAppDelegate.h"


@implementation clsTextNote
@synthesize txtNote;
@synthesize btnSave;
@synthesize btnDate;
@synthesize txtTitle;
@synthesize lblDate;
@synthesize locationManagerTextNote;
@synthesize sLatitude;
@synthesize sLongitude;
@synthesize spinner;
@synthesize tabBarController;
@synthesize txtTags;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) 
	{
		self.navigationItem.title = @"Text Note";
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
 - (void)loadView {
 }
 */


- (void)textViewDidBeginEditing:(UITextView *)textView
{
	// provide my own Save button to dismiss the keyboard
	UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(saveActionText:)];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIViewController *vwController = [[[appDelegate navigationController] viewControllers] objectAtIndex:3];
	vwController.navigationItem.rightBarButtonItem = saveItem;
	[saveItem release];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	// provide my own Save button to dismiss the keyboard
	UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(saveActionText:)];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIViewController *vwController = [[[appDelegate navigationController] viewControllers] objectAtIndex:3];
	vwController.navigationItem.rightBarButtonItem = saveItem;
	[saveItem release];
}

-(void) locationManager:(CLLocationManager *) manager didUpdateToLocation: (CLLocation *) newLocation fromLocation: (CLLocation *) oldLocation
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.iMediaType == 3)
	{
		NSDate *eventDate = newLocation.timestamp;
		NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
		if(abs(howRecent) < 3.0)
		{
			sLatitude = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.latitude]; 
			sLongitude = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.longitude];
			[locationManagerTextNote stopUpdatingLocation];
			[locationManagerTextNote release];
			[self SaveText];
		}
	}
}


// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.iMediaType == 3)
	{
		[locationManagerTextNote release];
		sLongitude = @"0.00";
		sLatitude = @"0.00";
		[self SaveText];
	}

}



-(void) SaveText
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
	{
		iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
		appDelegate.blnRefreshPage = TRUE;
		NSString *date;
		NSDate *now = [[NSDate alloc] init];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		[dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss "];
		date = [dateFormatter stringFromDate:now];
		if(appDelegate.sOperationMode == @"ADD")
		{
			const char *sql = "Insert Into tblNotes (iEntityID, notesDate, title, notes, addDate, latitude, longitude, notes_tags) values (?, ?, ?, ?, ?, ?, ?, ?)";
			sqlite3_stmt *statement;      
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				if(appDelegate.iContactEntityID == 0)
					sqlite3_bind_int(statement, 1, appDelegate.iEntityID);
				else
					sqlite3_bind_int(statement, 1, appDelegate.iContactEntityID);
				//sqlite3_bind_text(statement, 2, [lblDate.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 3, [txtTitle.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 4, [txtNote.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 5, [date UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 6, [sLatitude UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 7, [sLongitude UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 8, [txtTags.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_step(statement);
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
			
			sql = "select Max(iNotesID) from tblNotes";    
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				if(sqlite3_step(statement)  == SQLITE_ROW) 
				{
					appDelegate.iMediaID = sqlite3_column_double(statement, 0);
					appDelegate.sOperationMode = @"EDIT";			
				}
				// "Finalize" the statement - releases the resources associated with the statement.
				sqlite3_finalize(statement);
			}
		}
		else
		{
			const char *sql = "update tblNotes set title=?, notes=?, updateDate=?, latitude=?, longitude=?, notes_tags = ? where iNotesID = ?";
			sqlite3_stmt *statement;      
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				//sqlite3_bind_text(statement, 1, "", -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 1, [txtTitle.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 2, [txtNote.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 3, [date UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 4, [sLatitude UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement,5, [sLongitude UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 6, [txtTags.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_int(statement, 7, appDelegate.iMediaID);
				sqlite3_step(statement);
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
		}
		[spinner stopAnimating];
	}
}

- (IBAction)btnSave_Click:(id) sender
{
	[spinner startAnimating];
	locationManagerTextNote = [[[CLLocationManager alloc] init] retain];
	locationManagerTextNote.delegate = self;
	locationManagerTextNote.distanceFilter = 0;
	locationManagerTextNote.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManagerTextNote startUpdatingLocation];
}


- (void)saveActionText:(id)sender
{	
	datePickerView.hidden = YES;
	[txtTitle resignFirstResponder];
	[txtNote resignFirstResponder];
	[txtTags resignFirstResponder];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIViewController *vwController = [[[appDelegate navigationController] viewControllers] objectAtIndex:3];
	vwController.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)btnDate_Click:(id) sender
{
	UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(saveAction:)];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIViewController *vwController = [[[appDelegate navigationController] viewControllers] objectAtIndex:3];
	vwController.navigationItem.rightBarButtonItem = saveItem;
	[saveItem release];
	
	datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	datePickerView.datePickerMode = UIDatePickerModeDate;
	
	[datePickerView addTarget:self action:@selector(controlEventValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	// add this picker to our view controller, initially hidden
	datePickerView.hidden = NO;
	[self.view addSubview:datePickerView];							
}

- (void)controlEventValueChanged:(id)sender
{
	/*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
	lblDate.text = [dateFormatter stringFromDate:[datePickerView date]];
	[dateFormatter release];*/
}

- (void) viewDidLoad 
{
	/*NSDate *now = [[NSDate alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
	lblDate.text = [dateFormatter stringFromDate:now];
	[dateFormatter release];*/
	
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_back.png"]];
    imgView.frame = self.view.bounds;
    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imgView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView];
    [imgView release];    
	
	txtTitle.font = [UIFont systemFontOfSize:17.5];
	txtTags.font = [UIFont systemFontOfSize:17.5];
	txtNote.font = [UIFont systemFontOfSize:17.5];
	
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.sOperationMode == @"EDIT")
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql = "Select notesDate, title, notes, coalesce(notes_tags,'') from tblNotes where iNotesID = ?";
			sqlite3_stmt *statement;      
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_int(statement, 1, appDelegate.iMediaID);
				if(sqlite3_step(statement)  == SQLITE_ROW) 
				{
					//lblDate.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
					txtTitle.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
					txtNote.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
					txtTags.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
				}
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
		}
	}	
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}


@end
