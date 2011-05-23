//
//  clsAudioController.m
//  iFACES
//
//  Created by Hardik Zaveri on 15/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsAudioController.h"
#import <QuartzCore/QuartzCore.h>
#import "clsAudioController.h"
#import "iFACESAppDelegate.h"

#define kLevelMeterWidth	238
#define kLevelMeterHeight	45
#define kLevelOverload		0.9
#define kLevelHot			0.7
#define kLevelMinimum		0.01

void interruptionListenerCallback (
								   void	*inUserData,
								   UInt32	interruptionState
) {
	// This callback, being outside the implementation block, needs a reference 
	//	to the AudioViewController object
	clsAudioController *controller = (clsAudioController *) inUserData;
	
	if (interruptionState == kAudioSessionBeginInterruption) {
		
		NSLog (@"Interrupted. Stopping playback or recording.");
		
		if (controller.audioRecorder) {
			// if currently recording, stop
			[controller recordOrStop: (id) controller];
		} else if (controller.audioPlayer) {
			// if currently playing, pause
			[controller pausePlayback];
			controller.interruptedOnPlayback = YES;
		}
		
	} else if ((interruptionState == kAudioSessionEndInterruption) && controller.interruptedOnPlayback) {
		// if the interruption was removed, and the app had been playing, resume playback
		[controller resumePlayback];
		controller.interruptedOnPlayback = NO;
	}
}


@implementation clsAudioController
@synthesize audioPlayer;			// the playback audio queue object
@synthesize audioRecorder;			// the recording audio queue object
@synthesize soundFileURL;			// the sound file to record to and to play back
@synthesize recordingDirectory;		// the location to record into; it's the application's Documents directory
@synthesize playButton;				// the play button, which toggles to display "stop"
@synthesize recordButton;			// the record button, which toggles to display "stop"
@synthesize levelMeter;				// a mono audio level meter to show average level, implemented using Core Animation
@synthesize peakLevelMeter;			// a mono audio level meter to show peak level, implemented using Core Animation
@synthesize peakGray;				// colors to use with the peak audio level display
@synthesize peakOrange;
@synthesize peakRed;
@synthesize peakClear;
@synthesize bargraphTimer;			// a timer for updating the level meter
@synthesize audioLevels;			// an array of two floating point values that represents the current recording or playback audio level
@synthesize peakLevels;				// an array of two floating point values that represents the current recording or playback audio level
//@synthesize statusSign;				// a UILabel object that says "Recording" or "Playback," or empty when stopped
@synthesize interruptedOnPlayback;	// this allows playback to resume when an interruption ends. this app does not resume a recording for the user.
@synthesize fileName;
@synthesize sLatitude;
@synthesize sLongitude;
@synthesize locationManager;
@synthesize spinner;
@synthesize txtTitle;
@synthesize txtTags;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		self.title = @"Voice Note";
		
		
		iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSArray *filePaths =	NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES); 
		self.recordingDirectory = [filePaths objectAtIndex: 0];
		
		if(appDelegate.sMediaFileSelected == nil)
		{	
			[self getFileName];
		
			[self.fileName stringByAppendingString:@".caf"];
						
			CFStringRef fileString = (CFStringRef) [self.recordingDirectory stringByAppendingPathComponent:self.fileName];
		
			// create the file URL that identifies the file that the recording audio queue object records into
			CFURLRef fileURL =	CFURLCreateWithFileSystemPath (NULL,fileString,kCFURLPOSIXPathStyle,false);
			NSLog (@"Recorded file path: %@", fileURL); // shows the location of the recorded file
		
			// save the sound file URL as an object attribute (as an NSURL object)
			if (fileURL) {
				self.soundFileURL	= (NSURL *) fileURL;
				CFRelease (fileURL);
			}
			
			
			
			[self.recordButton setEnabled:YES];
		}
		else
		{
			//self.fileName = [appDelegate.sMediaFileSelected stringByAppendingString:@".caf"];
			CFStringRef fileString = (CFStringRef) [self.recordingDirectory stringByAppendingPathComponent:appDelegate.sMediaFileSelected];
			CFURLRef fileURL =	CFURLCreateWithFileSystemPath (NULL,fileString,kCFURLPOSIXPathStyle,false);
			self.soundFileURL = (NSURL *) fileURL;
			CFRelease(fileURL);
			
		}
		
		// allocate memory to hold audio level values
		audioLevels = calloc (2, sizeof (AudioQueueLevelMeterState));
		peakLevels = calloc (2, sizeof (AudioQueueLevelMeterState));
		
		// initialize the audio session object for this application,
		//		registering the callback that Audio Session Services will invoke 
		//		when there's an interruption
		AudioSessionInitialize (NULL, NULL, interruptionListenerCallback, self);
		[self addBargraphToView: self.view];
	}
	return self;
}


- (void)saveAction:(id)sender
{	
	[txtTitle resignFirstResponder];
	[txtTags resignFirstResponder];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIViewController *vwController = [[[appDelegate navigationController] viewControllers] objectAtIndex:3];
	vwController.navigationItem.rightBarButtonItem = nil;
	
	
	NSString *date;
	NSDate *now = [[NSDate alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss "];
	date = [dateFormatter stringFromDate:now];
	
	
	if(appDelegate.sMediaFileSelected != nil)
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			appDelegate.blnRefreshPage = TRUE;
			const char *sql;
			if(appDelegate.iMediaID != 0)
			{
				sql = "update tblEntity_Media set title = ?, updateDate = ?, media_tags = ? where imediaId = ?";
			}
			else
			{
				sql = "update tblEntity_Media set title = ?, updateDate = ?, media_tags = ? where media_filename = ?";
			}
			
			sqlite3_stmt *statement;      
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_text(statement, 1, [txtTitle.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 2, [date UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 3, [txtTags.text UTF8String], -1, SQLITE_TRANSIENT);
				if(appDelegate.iMediaID != 0)
					sqlite3_bind_double(statement, 4, appDelegate.iMediaID);
				else
					sqlite3_bind_text(statement, 4, [appDelegate.sMediaFileSelected UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_step(statement);
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
		} 
		else 
		{
			// Even though the open failed, call close to properly clean up resources.
			sqlite3_close(database);
			NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
			// Additional error handling, as appropriate...
		}
	}
	
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	// provide my own Save button to dismiss the keyboard
	UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			  target:self action:@selector(saveAction:)];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIViewController *vwController = [[[appDelegate navigationController] viewControllers] objectAtIndex:3];
	vwController.navigationItem.rightBarButtonItem = saveItem;
	
	[saveItem release];
}

- (void) addBargraphToView: (UIView *) parentView {
	
	// static image for showing average level
	UIImage *soundbarImage		= [[UIImage imageNamed: @"soundbar_mono.png"] retain];
	
	// background colors for generated image for showing peak level
	self.peakClear				= [UIColor clearColor];
	self.peakGray				= [UIColor lightGrayColor];
	self.peakOrange				= [UIColor orangeColor];
	self.peakRed				= [UIColor redColor]; 
	
	levelMeter					= [CALayer layer];
	levelMeter.anchorPoint		= CGPointMake (0.0, 0.5);						// anchor to halfway up the left edge
	levelMeter.frame			= CGRectMake (280, 160, 0, kLevelMeterHeight);	// set width to 0 to start to completely hide the bar graph segements
	levelMeter.contents			= (UIImage *) soundbarImage.CGImage;
	
	peakLevelMeter				= [CALayer layer];
	peakLevelMeter.frame		= CGRectMake (280, 160, 0, kLevelMeterHeight);
	peakLevelMeter.anchorPoint	= CGPointMake (0.0, 0.5);
	peakLevelMeter.backgroundColor = peakGray.CGColor;
	
	peakLevelMeter.bounds		= CGRectMake (0, 0, 0, kLevelMeterHeight);
	peakLevelMeter.contentsRect	= CGRectMake (0, 0, 1.0, 1.0);
	
	[parentView.layer addSublayer: levelMeter];
	[parentView.layer addSublayer: peakLevelMeter];
}


- (void) viewDidLoad {
	

	txtTitle.font = [UIFont systemFontOfSize:17.5];
	txtTags.font = [UIFont systemFontOfSize:17.5];
    
//    [self.recordButton setBackgroundImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
//    self.recordButton.contentMode = UIViewContentModeScaleAspectFit;
//    [self.playButton setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
//    self.playButton.contentMode = UIViewContentModeScaleAspectFill;
//    self.playButton.backgroundColor = [UIColor clearColor];
//    self.playButton.opaque = NO;
    
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"landingpage.gif"]];
//    self.view.contentMode = UIViewContentModeScaleAspectFit;
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_back.png"]];
    imgView.frame = self.view.bounds;
    imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imgView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView];
    [imgView release];    
    
	//NSFileManager * fileManager = [NSFileManager defaultManager];
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.sMediaFileSelected == nil)
	{
		[self.recordButton setHidden:NO];
		[self.playButton setEnabled:NO];
	}
	else
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql = "SELECT title, media_tags from tblEntity_Media where imediaID=?";
			sqlite3_stmt *statement;      
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_int(statement, 1, appDelegate.iMediaID);
				if (sqlite3_step(statement) == SQLITE_ROW) 
				{
					txtTitle.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
					txtTags.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
				}
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
		} 
		else 
		{
			// Even though the open failed, call close to properly clean up resources.
			sqlite3_close(database);
			NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
			// Additional error handling, as appropriate...
		}
		[self.recordButton setHidden:YES];
		[self.playButton setEnabled:YES];
	}	
	//[statusSign setFont: [UIFont fontWithName: @"Helvetica" size: 24.0]];
}


// this method gets called (by property listener callback functions) when a recording or playback 
// audio queue object starts or stops. 
- (void) updateUserInterfaceOnAudioQueueStateChange: (AudioQueueObject *) inQueue {
	
	NSAutoreleasePool *uiUpdatePool = [[NSAutoreleasePool alloc] init];
	
	NSLog (@"updateUserInterfaceOnAudioQueueStateChange just called.");
	
	// the audio queue (playback or record) just started
	if ([inQueue isRunning]) {
		
		// create a timer for updating the audio level meter
		self.bargraphTimer = [NSTimer scheduledTimerWithTimeInterval:	0.05		// seconds
															  target:		self
															selector:	@selector (updateBargraph:)
															userInfo:	inQueue		// makes the currently-active audio queue (record or playback) available to the updateBargraph method
															 repeats:	YES];
		// playback just started
		if (inQueue == self.audioPlayer) {
			
			NSLog (@"playback just started.");
			[self.recordButton setEnabled: NO];
			[playButton setTitle:@"Stop" forState:UIControlStateNormal];
			//[self.statusSign setText: @"Playback"];
			//[self.statusSign setTextColor: [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 1.0]];
			
			// recording just started
		} else if (inQueue == self.audioRecorder) {
			
			NSLog (@"recording just started.");
			[self.playButton setEnabled: NO];
			NSLog (@"setting Record button title to Stop.");
			[self.recordButton setTitle: @"Stop" forState:UIControlStateNormal];
			//[self.statusSign setText: @"Recording"];
			//[self.statusSign setTextColor: [UIColor colorWithRed: 0.67 green: 0.0 blue: 0.0 alpha: 1.0]];
		}
		// the audio queue (playback or record) just stopped
	} else {
		
		// playback just stopped
		if (inQueue == self.audioPlayer) {
			
			NSLog (@"playback just stopped.");
			[self.recordButton setEnabled: YES];
			[self.playButton setTitle: @"Play" forState:UIControlStateNormal];
			
			[audioPlayer release];
			audioPlayer = nil;
			
			// recording just stopped
		} else if (inQueue == self.audioRecorder) {
			
			NSLog (@"recording just stopped.");
			[self.playButton setEnabled: YES];
			NSLog (@"setting Record button title to Record.");
			[self.recordButton setTitle: @"Record" forState:UIControlStateNormal];
			
			[audioRecorder release];
			audioRecorder = nil;
		}
		
		if (self.bargraphTimer) {
			
			[self.bargraphTimer invalidate];
			[self.bargraphTimer release];
			bargraphTimer = nil;
		}
		
		//[self.statusSign setText: @""];
		[self resetBargraph];
	}
	
	[uiUpdatePool drain];
}


// respond to a tap on the Record button. If stopped, start recording. If recording, stop.
// an audio queue object is created for each recording, and destroyed when the recording finishes.
- (IBAction) recordOrStop: (id) sender {
	
	NSLog (@"recordOrStop:");
	
	// if not recording, start recording
	if (self.audioRecorder == nil) 
	{
		[self DeleteFileIfExists];
		iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
		appDelegate.sMediaFileSelected = nil;
		// before instantiating the recording audio queue object, 
		//	set the audio session category
		UInt32 sessionCategory = kAudioSessionCategory_RecordAudio;
		AudioSessionSetProperty (
								 kAudioSessionProperty_AudioCategory,
								 sizeof (sessionCategory),
								 &sessionCategory
								 );
		
		// the first step in recording is to instantiate a recording audio queue object
		AudioRecorder *theRecorder = [[AudioRecorder alloc] initWithURL: self.soundFileURL];
		
		// if the audio queue was successfully created, initiate recording.
		if (theRecorder) {
			
			self.audioRecorder = theRecorder;
			[theRecorder release];								// decrements the retain count for the theRecorder object
			
			[self.audioRecorder setNotificationDelegate: self];	// sets up the recorder object to receive property change notifications 
			//	from the recording audio queue object
			
			// activate the audio session immediately before recording starts
			AudioSessionSetActive (true);
			NSLog (@"sending record message to recorder object.");
			[self.audioRecorder record];						// starts the recording audio queue object
		}
		
		// else if recording, stop recording
	} else if (self.audioRecorder) 
	{
		
		[self.audioRecorder setStopping: YES];				// this flag lets the property listener callback
		//	know that the user has tapped Stop
		NSLog (@"sending stop message to recorder object.");
		[self.audioRecorder stop];							// stops the recording audio queue object. the object 
		//	remains in existence until it actually stops, at
		//	which point the property listener callback calls
		//	this class's updateUserInterfaceOnAudioQueueStateChange:
		//	method, which releases the recording object.
		// now that recording has stopped, deactivate the audio session
		AudioSessionSetActive (false);
		locationManager = [[[CLLocationManager alloc] init] retain];
		locationManager.delegate = self;
		locationManager.distanceFilter = 0;
		locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		[locationManager startUpdatingLocation];
		[spinner startAnimating];
	}
}

// respond to a tap on the Play button. If stopped, start playing. If playing, stop.
- (IBAction) playOrStop: (id) sender {
	
	NSLog (@"playOrStop:");
	
	// if not playing, start playing
	if (self.audioPlayer == nil) {
		
		// before instantiating the playback audio queue object, 
		//	set the audio session category
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty (
								 kAudioSessionProperty_AudioCategory,
								 sizeof (sessionCategory),
								 &sessionCategory
								 );
		
		AudioPlayer *thePlayer = [[AudioPlayer alloc] initWithURL: self.soundFileURL];
		
		if (thePlayer) {
			
			self.audioPlayer = thePlayer;
			[thePlayer release];								// decrements the retain count for the thePlayer object
			
			[self.audioPlayer setNotificationDelegate: self];	// sets up the playback object to receive property change notifications from the playback audio queue object
			
			// activate the audio session immmediately before playback starts
			AudioSessionSetActive (true);
			NSLog (@"sending play message to play object.");
			[self.audioPlayer play];
		}
		
		// else if playing, stop playing
	} else if (self.audioPlayer) {
		
		NSLog (@"User tapped Stop to stop playing.");
		[self.audioPlayer setAudioPlayerShouldStopImmediately: YES];
		NSLog (@"Calling AudioQueueStop from controller object.");
		[self.audioPlayer stop];
		
		// now that playback has stopped, deactivate the audio session
		AudioSessionSetActive (false);
	}  
}

// pausing is only ever invoked by the interruption listener callback function, which
//	is why this isn't an IBAction method(that is, 
//	there's no explicit UI for invoking this method)
- (void) pausePlayback {
	
	if (self.audioPlayer) {
		
		NSLog (@"Pausing playback on interruption.");
		[self.audioPlayer pause];
	}
}

// resuming playback is only every invoked if the user rejects an incoming call
//	or other interruption, which is why this isn't an IBAction method (that is, 
//	there's no explicit UI for invoking this method)
- (void) resumePlayback {
	
	NSLog (@"Resuming playback on end of interruption.");
	
	// before resuming playback, set the audio session
	// category and activate it
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty (
							 kAudioSessionProperty_AudioCategory,
							 sizeof (sessionCategory),
							 &sessionCategory
							 );
	AudioSessionSetActive (true);
	
	[self.audioPlayer resume];
}

// Core Animation-based audio level meter updating method
- (void) updateBargraph: (NSTimer *) timer {
	
	AudioQueueObject *activeQueue = (AudioQueueObject *) [timer userInfo];
	
	if (activeQueue) {
		
		[activeQueue getAudioLevels: self.audioLevels peakLevels: self.peakLevels];
		//		NSLog (@"Average: %f, Peak: %f", audioLevels[0], peakLevels[0]);
		
		[CATransaction begin];
		
		[CATransaction setValue: [NSNumber numberWithBool:YES] forKey: kCATransactionDisableActions];
		
		levelMeter.bounds =			CGRectMake (
												0,
												0,
												(audioLevels[0] > 1.0 ? 1.0 : audioLevels[0]) * kLevelMeterWidth,
												kLevelMeterHeight
												);
		
		levelMeter.contentsRect	=	CGRectMake (
												0,
												0,
												audioLevels[0],
												1.0
												);
		
		peakLevelMeter.frame =		CGRectMake (
												280.0 + (peakLevels[0] > 1.0 ? 1.0 : peakLevels[0] )* kLevelMeterWidth,
												160,
												3,
												kLevelMeterHeight
												);
		peakLevelMeter.bounds =		CGRectMake (
												0,
												0,
												3,
												kLevelMeterHeight
												);
		
		if (peakLevels[0] > kLevelOverload) {
			peakLevelMeter.backgroundColor = self.peakRed.CGColor;
		} else if (peakLevels[0] > kLevelHot) {
			peakLevelMeter.backgroundColor = self.peakOrange.CGColor;
		} else if (peakLevels[0] > kLevelMinimum) {
			peakLevelMeter.backgroundColor = self.peakGray.CGColor;
		} else {
			peakLevelMeter.backgroundColor = self.peakClear.CGColor;
		}
		
		[CATransaction commit];
	}
}


- (void) resetBargraph {
	
	levelMeter.bounds		= CGRectMake (0, 0, 0, kLevelMeterHeight);
	peakLevelMeter.frame	= CGRectMake (41, 160, 3, kLevelMeterHeight);
	peakLevelMeter.bounds	= CGRectMake (0, 0, 0, kLevelMeterHeight);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void) didReceiveMemoryWarning {
	
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	
	// the most likely reason for a memory warning is that the file being recorded is getting
	// too big -- so stop recording. This can be tested in the iPhone Simulator.
	if (self.audioRecorder) {
		[self recordOrStop: self];
	}
}

- (void)getFileName 
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
	{
		const char *sql = "SELECT count(*) as cMediaCount from tblEntity_Media where iEntityID = ? and media_type=0";
		sqlite3_stmt *statement;      
		if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
		{
			if(appDelegate.iContactEntityID == 0)
				sqlite3_bind_int(statement, 1, appDelegate.iEntityID);
			else
				sqlite3_bind_int(statement, 1, appDelegate.iContactEntityID);
			if (sqlite3_step(statement) == SQLITE_ROW) 
			{
				if(appDelegate.iContactEntityID == 0)
					self.fileName = [[NSString stringWithFormat:@"%.0f_", appDelegate.iCaseID] stringByAppendingString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
				else
					self.fileName = [[NSString stringWithFormat:@"%.0f_", appDelegate.iContactID] stringByAppendingString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
			}
		}
		// "Finalize" the statement - releases the resources associated with the statement.
		sqlite3_finalize(statement);
	} 
	else 
	{
		// Even though the open failed, call close to properly clean up resources.
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
		// Additional error handling, as appropriate...
	}
	
}

-(void) locationManager:(CLLocationManager *) manager didUpdateToLocation: (CLLocation *) newLocation fromLocation: (CLLocation *) oldLocation
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.iMediaType == 0)
	{
		NSDate *eventDate = newLocation.timestamp;
		NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
		if(abs(howRecent) < 3.0)
		{
			sLatitude = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.latitude]; 
			sLongitude = [NSString stringWithFormat:@"%.6f", newLocation.coordinate.longitude];
			[locationManager stopUpdatingLocation];
			[locationManager release];
			[self saveWithLocation];
		}
	}

}


// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.iMediaType == 0)
	{
		[locationManager release];
		sLongitude = @"0.00";
		sLatitude = @"0.00";
		[self saveWithLocation];
	}
}


- (void)DeleteFileIfExists 
{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql;
			sqlite3_stmt *statement;
			
			sql = "delete from tblEntity_Media where media_filename = ? and Media_type = 0";
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				sqlite3_bind_text(statement, 1, [self.fileName UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_step(statement);
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
		}
		else 
		{
			// Even though the open failed, call close to properly clean up resources.
			sqlite3_close(database);
			NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
			// Additional error handling, as appropriate...
		}
}


-(void) saveWithLocation
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	appDelegate.blnRefreshPage = TRUE;
	
	if(appDelegate.sMediaFileSelected == nil)
	{
		NSString *date;
		NSDate *now = [[NSDate alloc] init];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss "];
		date = [dateFormatter stringFromDate:now];

		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql;
			sqlite3_stmt *statement;
			
			sql = "Insert Into tblEntity_Media (iEntityID, Media_type, media_filename, title, addDate, latitude, longitude, media_tags) values (?, 0, ?, ?, ?, ?, ?, ?)";
			if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				if(appDelegate.iContactEntityID == 0)
					sqlite3_bind_int(statement, 1, appDelegate.iEntityID);
				else
					sqlite3_bind_int(statement, 1, appDelegate.iContactEntityID);
				sqlite3_bind_text(statement, 2, [self.fileName UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 3, [txtTitle.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 4, [date UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 5, [sLatitude UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 6, [sLongitude UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_bind_text(statement, 7, [txtTags.text UTF8String], -1, SQLITE_TRANSIENT);
				sqlite3_step(statement);
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			sqlite3_finalize(statement);
			appDelegate.sMediaFileSelected = self.fileName;
		} 
		else 
		{
			// Even though the open failed, call close to properly clean up resources.
			sqlite3_close(database);
			NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
			// Additional error handling, as appropriate...
		}
	}
	[spinner stopAnimating];
		
}

- (void) dealloc {
	
	[recordButton release];
	[playButton	release];
	[audioRecorder release];
	[super dealloc];
}



@end
