//
//  SettingsViewController.h
//  Brown-Forman-GDocSync
//
//  Created by Suyash Kaulgud on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h";
#import "AppDelegate.h"

@interface SettingsViewController : UIViewController<UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITextFieldDelegate> {
	
	UIPopoverController *popoverController;
    UIToolbar *toolbar;	
	id detailItem;
	
	UITextField *txtUsername;
	UITextField *txtPassword;
	UITextField *txtManagedFolder;
	UIButton *btnSave;
	UIButton *btnDelete;	
	AppDelegate *appDelegate;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) id detailItem;

@property (nonatomic, retain) IBOutlet UITextField *txtUsername;
@property (nonatomic, retain) IBOutlet UITextField *txtPassword;
@property (nonatomic, retain) IBOutlet UITextField *txtManagedFolder;
@property (nonatomic, retain) IBOutlet UIButton *btnSave;
@property (nonatomic, retain) IBOutlet UIButton *btnDelete;
@property (nonatomic, retain) AppDelegate *appDelegate;

-(IBAction)saveButtonPressed:(id)sender;
-(IBAction)hideKeyboard:(id)sender;
-(IBAction)deleteButtonPressed:(id)sender;
-(IBAction)deleteSearchedDocuments:(id)sender;
@end
