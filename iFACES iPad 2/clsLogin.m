//
//  clsLogin.m
//  iFACES
//
//  Created by Hardik Zaveri on 04/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsLogin.h"
#import "iFACESAppDelegate.h"



@implementation clsLogin

@synthesize lblUserName;
@synthesize lblPassword;
@synthesize btnLogin;
@synthesize txtPassword;
@synthesize txtUserName;
@synthesize lblMessage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
	}
    
	return self;
}


- (IBAction)btnLogin_Click:(id) sender
{
	[lblMessage setText : @""];
	[txtPassword resignFirstResponder];
	lblMessage.hidden = true;
	[txtUserName setText:@"RBURGER"];
	[txtPassword setText:@"faces"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"iFaces.db"];
			
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        NSString *sqlTemp = @"SELECT faces_ssn FROM tblUsers where username=? and password=?";
        sqlite3_stmt *statement = nil;

        if (sqlite3_prepare_v2(database, [sqlTemp cStringUsingEncoding:NSUTF8StringEncoding], -1, &statement, NULL) != SQLITE_OK) 
		{
			[lblMessage setText: @"Error: Please Contact Administrator."];		
           lblMessage.hidden = false;
		}
		sqlite3_bind_text(statement, 1, [txtUserName.text UTF8String], -1, SQLITE_TRANSIENT);		
		sqlite3_bind_text(statement, 2, [txtPassword.text UTF8String], -1, SQLITE_TRANSIENT);	
		if(sqlite3_step(statement) == SQLITE_ROW) 
		{
			iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
			appDelegate.iFACESSSN = sqlite3_column_double(statement, 0);
			[appDelegate LoggedInSuccessful];
		} 
		else 
		{
			UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@"Login Unsuccessful" message:@"Login Attempt Unsuccessful. Please Try Again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
			//[lblMessage setText:@"Login Attempt Unsuccessful. Please Try Again."];
		}
		sqlite3_finalize(statement);
		[sqlTemp release];
	}
	paths = nil;
	path = nil;
	documentsDirectory = nil;
	[path release];
	[paths release];
	[documentsDirectory release];
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */


// If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad {
    lblMessage.hidden = true;
    UIImage *backImage = [UIImage imageNamed:@"sidebar_hands_big.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:backImage];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:backImage];
}
 


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	//return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}


- (void)didReceiveMemoryWarning {
	[lblUserName release];
	[lblPassword release];
	//[navigationItem dealloc];
	[btnLogin release];
	[txtPassword release];
	[txtUserName release];
	[lblMessage release];
	[self release];
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	
	//[lblUserName release];
	//[lblPassword release];
	//[navigationItem dealloc];
	//[btnLogin release];
	//[txtPassword release];
	//[txtUserName release];
	//[lblMessage release];
	//[self release];
	[super dealloc];
}


@end
