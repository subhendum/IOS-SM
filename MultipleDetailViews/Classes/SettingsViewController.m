    //
//  SettingsViewController.m
//  Brown-Forman-GDocSync
//
//  Created by Suyash Kaulgud on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation SettingsViewController


@synthesize txtUsername;
@synthesize txtPassword;
@synthesize txtManagedFolder;
@synthesize btnSave;
@synthesize toolbar; 
@synthesize detailItem;
@synthesize popoverController;
@synthesize btnDelete;
@synthesize appDelegate;


#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
        
        // Update the view.
        [self configureView];
    }
	
    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView {
    // Update the user interface for the detail item.
	[self.view addSubview:self.toolbar];
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Menu";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}

#pragma mark -
#pragma mark Managing Buttons

-(IBAction)saveButtonPressed:(id)sender {
	
	[txtPassword resignFirstResponder];
	[txtUsername resignFirstResponder];
	[txtManagedFolder resignFirstResponder];
	
	
	// Storing user object instance in Application Delegate
	User *userObj = [[User alloc] initWithUserDetails:txtUsername.text
											 password:txtPassword.text
										managedFolder:txtManagedFolder.text];
		
	NSLog(@"folder name BEFORE - %@",self.appDelegate.user.managedFolder);
	
	[self.appDelegate setUser:userObj];
	
	[self.appDelegate.GDocImpl setUser:userObj];
	
	[self.appDelegate setUserDetailsFlag:YES];
	[self.appDelegate setGDocImpl:[[GDataInterface alloc] initWithUser:userObj]];
	[self.appDelegate.GDocImpl fetchResourceIdForFolder:txtManagedFolder.text];
							   
}

// This method deletes all files from UserGoogleDocs folder
-(IBAction)deleteButtonPressed:(id)sender {
	
	[txtPassword resignFirstResponder];
	[txtUsername resignFirstResponder];
	[txtManagedFolder resignFirstResponder];
	
	NSString *etagsFilePath = [self.appDelegate.appConfigFolderPath stringByAppendingPathComponent:@"FilesETags.plist"];
	NSString *docLinksFilePath = [self.appDelegate.appConfigFolderPath stringByAppendingPathComponent:@"FilesLinks.plist"];
	
	NSLog(@"etagsFilePath = %@",etagsFilePath);
	NSLog(@"docLinksFilePath = %@",docLinksFilePath);
	
	NSError *error = nil;
	
	if ([[NSFileManager defaultManager] removeItemAtPath:self.appDelegate.userDocumentsFolderPath error:&error]) {
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:etagsFilePath]) {
			[[NSFileManager defaultManager] removeItemAtPath:etagsFilePath error:&error];
			[appDelegate.filesTagDictionary removeAllObjects];
			if(error)
			{
				NSLog(@"E Tags : %@",[error description]);				
			}
		}

		error = nil;
		
		if([[NSFileManager defaultManager] fileExistsAtPath:docLinksFilePath]) {
			[[NSFileManager defaultManager] removeItemAtPath:docLinksFilePath error:&error];
			[appDelegate.filesLinkDictionary removeAllObjects];
			if(error) {
				NSLog(@"doc Links : %@",[error description]);			
			}
			
		}

		
		[self.appDelegate checkDocumentsFolder];
	}
	else {
		NSLog(@"Error deleting UserGoogleDocs folder - %@",[error description]);
	}
	
	
}

#pragma mark -
#pragma mark Buttons Actions

// This method deletes all files from UserGoogleDocs folder
-(IBAction)deleteSearchedDocuments:(id)sender {
	[txtPassword resignFirstResponder];
	[txtUsername resignFirstResponder];
	[txtManagedFolder resignFirstResponder];
		
	NSError *error = nil;
	
	if ([[NSFileManager defaultManager] removeItemAtPath:self.appDelegate.userSearchResultsFolderPath error:&error]) {
		[self.appDelegate checkDocumentsFolder];
	}
	else {
		NSLog(@"Error deleting UserGoogleDocs folder - %@",[error description]);
	}
}

#pragma mark -
#pragma mark Managing Text Fields

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	// on hitting return key, call login button action.
	if (textField == txtPassword || textField == txtManagedFolder) {
		[self saveButtonPressed:self];
	}
	return YES;
}

-(IBAction)hideKeyboard:(id)sender {
	
	[sender resignFirstResponder];
}

#pragma mark -
#pragma mark Managing View

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.appDelegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// Keyboard style for text fields.
	txtUsername.keyboardType = UIKeyboardTypeDefault;
	txtPassword.keyboardType = UIKeyboardTypeDefault;
	txtManagedFolder.keyboardType = UIKeyboardTypeDefault;
	
	// password mask
	txtPassword.secureTextEntry = YES;
	
	// self delegate for text fields.
	txtPassword.delegate = self;
	txtUsername.delegate = self;
	txtManagedFolder.delegate = self;
	
	if (self.appDelegate.user != nil) {
		NSLog(@"User details loaded into view fields");
		txtUsername.text = self.appDelegate.user.username;
		txtPassword.text = self.appDelegate.user.password;
		txtManagedFolder.text = self.appDelegate.user.managedFolder;		
	}
	else {
		NSLog(@" User details not present. Showing blank fields");
	}
	
	self.view.backgroundColor = [UIColor clearColor];
	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green.jpg"]];	
	backgroundImage.contentMode = UIViewContentModeScaleToFill;
	[self.view addSubview:backgroundImage];
	[self.view sendSubviewToBack:backgroundImage];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
	[txtUsername release];
	[txtPassword release];
	[txtManagedFolder release];
	[btnSave release];
	[toolbar release];
	[detailItem release];
	[popoverController release];
    [super dealloc];
}


@end
