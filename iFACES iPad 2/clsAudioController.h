//
//  clsAudioController.h
//  iFACES
//
//  Created by Hardik Zaveri on 15/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AudioQueueObject.h"
#import "AudioRecorder.h"
#import "AudioPlayer.h"
#import "sqlite3.h";

@interface clsAudioController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate> 
{

	IBOutlet UITextField *txtTitle;
	
	AudioRecorder				*audioRecorder;
	AudioPlayer					*audioPlayer;
	NSURL						*soundFileURL;
	NSString					*recordingDirectory;
	
	NSTimer						*bargraphTimer;
	Float32						*audioLevels;
	Float32						*peakLevels;
	IBOutlet CALayer			*levelMeter;
	IBOutlet CALayer			*peakLevelMeter;
	
	UIColor						*peakClear;
	UIColor						*peakGray;
	UIColor						*peakOrange;
	UIColor						*peakRed;
	
	//IBOutlet UITextField		*statusSign;
	
	IBOutlet UIButton	*recordButton;
	IBOutlet UIButton	*playButton;
	IBOutlet UITextField *txtTags;
	IBOutlet UIActivityIndicatorView *spinner;
	
	BOOL						interruptedOnPlayback;
	
	NSString *fileName;
	sqlite3 *database;
	
	NSString *sLatitude;
	NSString *sLongitude;
	CLLocationManager *locationManager;
}
@property (nonatomic, retain)	NSString *fileName;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;

@property (nonatomic, retain)	NSString *sLatitude;
@property (nonatomic, retain)	NSString *sLongitude;
@property (nonatomic, retain)	CLLocationManager *locationManager;


@property (nonatomic, retain)	AudioRecorder				*audioRecorder;
@property (nonatomic, retain)	AudioPlayer					*audioPlayer;
@property (nonatomic, retain)	NSURL						*soundFileURL;
@property (nonatomic, retain)	NSString					*recordingDirectory;

@property (nonatomic, retain)	NSTimer						*bargraphTimer;
@property (readwrite)			Float32						*audioLevels;
@property (readwrite)			Float32						*peakLevels;
@property (nonatomic, retain)	CALayer						*levelMeter;
@property (nonatomic, retain)	CALayer						*peakLevelMeter;
//@property (nonatomic, retain)	IBOutlet UITextField		*statusSign;

@property (nonatomic, retain)	UIColor						*peakClear;
@property (nonatomic, retain)	UIColor						*peakGray;
@property (nonatomic, retain)	UIColor						*peakOrange;
@property (nonatomic, retain)	UIColor						*peakRed;

@property (nonatomic, retain) UIButton	*recordButton;
@property (nonatomic, retain) UIButton	*playButton; 

@property (readwrite)			BOOL						interruptedOnPlayback;

@property (nonatomic, retain) UITextField *txtTitle; 
@property (nonatomic, retain) UITextField *txtTags;



- (void) addBargraphToView: (UIView *) parentView;
- (void) updateUserInterfaceOnAudioQueueStateChange: (AudioQueueObject *) inQueue;
- (void) updateBargraph: (NSTimer *) timer;
- (void) resetBargraph;
- (IBAction) recordOrStop: (id) sender;
- (IBAction) playOrStop: (id) sender;
- (void) pausePlayback;
- (void) resumePlayback;
- (void)getFileName;
- (void)DeleteFileIfExists;
-(void) saveWithLocation;



@end
