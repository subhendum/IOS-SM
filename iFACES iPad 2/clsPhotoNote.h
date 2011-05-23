//
//  clsPhotoNote.h
//  iFACES
//
//  Created by Hardik Zaveri on 13/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import <CoreLocation/CoreLocation.h>

@interface clsPhotoNote : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate>
{
	
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UITextField *txtTitlePhoto;
	IBOutlet UIImageView *imgView;
	IBOutlet UIButton *btnAddPhoto;
	IBOutlet UIButton *btnSavePhoto;
	
	sqlite3 *database;
	
	UIImagePickerController* imagePickerController;
	
	NSString *sTitle;
	CLLocationManager *locationManager;
	
	NSString *sLatitude;
	NSString *sLongitude;
	
	NSData *imgData;
	
	IBOutlet UITextField *txtTags;

}
@property (nonatomic, retain) UIButton *btnSavePhoto;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UITextField *txtTitlePhoto; 
@property (nonatomic, retain) UIImageView *imgView;
@property (nonatomic, retain) UIButton *btnAddPhoto;
@property (nonatomic, retain) NSString *sTitle;
@property (nonatomic, retain)	CLLocationManager *locationManager;

@property (nonatomic, retain) NSString *sLatitude;
@property (nonatomic, retain) NSString *sLongitude;
@property (nonatomic, retain) UITextField *txtTags;

@property (nonatomic, retain) NSData *imgData;

- (IBAction)btnSavePhoto_Click:(id) sender; 
- (IBAction)btnAddPhoto_Click:(id) sender; 
- (void) SaveImage;
@end
