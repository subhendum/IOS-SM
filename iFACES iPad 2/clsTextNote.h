//
//  clsTextNote.h
//  iFACES
//
//  Created by Hardik Zaveri on 18/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import <CoreLocation/CoreLocation.h>

@interface clsTextNote : UIViewController <UITextViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>
{
	
	IBOutlet UITabBarController *tabBarController;
	IBOutlet UITextField *txtTitle;
	IBOutlet UITextView *txtNote;
	IBOutlet UIButton *btnSave;
	IBOutlet UIButton *btnDate;
	IBOutlet UILabel *lblDate;
	UIDatePicker *datePickerView;
	
	sqlite3 *database;
	CLLocationManager *locationManagerTextNote;
	
	NSString *sLatitude;
	NSString *sLongitude;
	
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UITextField *txtTags;
}
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) UITextField *txtTitle;
@property (nonatomic, retain) UITextView *txtNote;
@property (nonatomic, retain) UIButton *btnSave;
@property (nonatomic, retain) UIButton *btnDate;
@property (nonatomic, retain) UILabel *lblDate;

@property (nonatomic, retain) NSString *sLatitude;
@property (nonatomic, retain) NSString *sLongitude;


@property (nonatomic, retain)	CLLocationManager *locationManagerTextNote;

@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UITextField *txtTags;

- (void)textViewDidBeginEditing:(UITextView *)textView;
- (void)textFieldDidBeginEditing:(UITextField *)textField;

- (IBAction)btnDate_Click:(id) sender; 
- (IBAction)btnSave_Click:(id) sender; 
-(void) SaveText;

@end
