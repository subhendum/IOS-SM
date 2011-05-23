//
//  GDFileViewController.m
//  GoogleDocSync
//
//  Created by Suyash Kaulgud on 4/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GDFileViewController.h"
#import "AppDelegate.h"

@interface GDFileViewController ()
-(void)emailButtonPressed:(id)sender;
- (void)actionEmailComposer:(NSString *)messageType;
@end



@implementation GDFileViewController

UIActionSheet *actionSheet;
AppDelegate *appDelegate;

@synthesize fileDetailsView;
@synthesize selectedFile; 
@synthesize source;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.fileDetailsView = [[UIWebView alloc] init];
		self.fileDetailsView.scalesPageToFit = YES;
		self.fileDetailsView.delegate = self;
    }
    return self;
}

// email button process.
-(void)emailButtonPressed:(id)sender {

	actionSheet = [[UIActionSheet alloc] initWithTitle:@"Email Options" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"As a Link",@"As an Attachment",nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showFromBarButtonItem:[[self navigationItem] rightBarButtonItem] animated:YES];
	[actionSheet release];
	
//	UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(950, 0, 75, 40)];
//	closeButton.backgroundColor = [UIColor grayColor];
//	closeButton.alpha = 0.6;
//	[closeButton setTitle:@"Close" forState:UIControlStateNormal];
//	closeButton.tag = 1;
//	[closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventAllEvents];
//	[self.view addSubview:closeButton];	
//	[self.parentViewController presentModalViewController:self animated:YES];
}

-(void)closeButtonPressed:(id)sender {
	UIButton *btn = (UIButton *)[self.view viewWithTag:1];
	[btn removeFromSuperview];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0)
	{
		[ self actionEmailComposer:@"Link"];		
	}
	else if (buttonIndex == 1)
	{
		[ self actionEmailComposer:@"Attachment"];
	}

	[actionSheet resignFirstResponder];
	[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

- (void)actionEmailComposer:(NSString *)messageType {	
	if ([MFMailComposeViewController canSendMail]) 
	{		
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
		mailViewController.mailComposeDelegate = self;
		NSString *filepath = [appDelegate.userDocumentsFolderPath stringByAppendingPathComponent:self.selectedFile];
		
		// Setting file name in the email subject
		[mailViewController setSubject:[NSString stringWithFormat:@"File - %@ has been shared with you.",self.selectedFile]];
		
		if ([messageType isEqualToString:@"Link"]) {

			NSString *messageBody = [NSString stringWithFormat:@"Link : %@",[appDelegate.filesLinkDictionary objectForKey:self.selectedFile]];
			[mailViewController setMessageBody:messageBody isHTML:YES];
		}
		else {

			// Adding file attachment
			NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filepath];					
			NSString *mimeType = [appDelegate.GDocImpl.mimeTypeDictionary objectForKey:[self.selectedFile pathExtension] ];			
			[mailViewController addAttachmentData:fileData mimeType:mimeType fileName:selectedFile];			
		}
		
		[self presentModalViewController:mailViewController animated:YES];
		[mailViewController release];
		
	}
	else 
	{
		NSLog(@"Device can not send email");
		
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Email Account" message:@"Please set up a mail account using Mail application."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];	
		[alert release];		
	}
	
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult *)result error:(NSError*)error 
{
	[self dismissModalViewControllerAnimated:YES];	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithTitle:@"Email" style:UIBarButtonItemStyleBordered target:self action:@selector(emailButtonPressed:)];
	[[self navigationItem] setRightBarButtonItem:btnEmail];
	[btnEmail release];
	
	self.title = selectedFile;
	
	NSString *rootPathWithFolder = nil;
	
	if ([source isEqualToString:@"Search"]) {
		rootPathWithFolder = appDelegate.userSearchResultsFolderPath;
	}
	else {
		rootPathWithFolder = appDelegate.userDocumentsFolderPath;
	}

	
	NSString *pathToFile = [rootPathWithFolder stringByAppendingPathComponent:selectedFile];
	
	// Checking if file exists in Documents folder
	if ([[NSFileManager defaultManager] fileExistsAtPath:pathToFile]) {
		NSLog(@" FILE EXISTS :: %@",pathToFile);
		
	}

	
	NSURL *url = [NSURL fileURLWithPath:pathToFile];
	
	if (!([selectedFile rangeOfString:@".MOV"].location == NSNotFound)) {
	
		MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
	
		// Register to receive a notification when the movie has finished playing. 
		[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(moviePlayBackDidFinish:) 
												 name:MPMoviePlayerPlaybackDidFinishNotification 
											   object:[playerViewController moviePlayer]];
		
		[self.view addSubview:playerViewController.view];
	
		MPMoviePlayerController *player = [playerViewController moviePlayer];
		[player play];
	}
	else {
		
		NSURL *url = [NSURL fileURLWithPath:pathToFile];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		[self.fileDetailsView loadRequest:request];
		self.view = fileDetailsView;
	}
	NSLog(@"viewDidLoad completed");
}


//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*) aNotification {
    MPMoviePlayerController *player = [aNotification object];
    [[NSNotificationCenter defaultCenter] 
	 removeObserver:self
	 name:MPMoviePlayerPlaybackDidFinishNotification
	 object:player];
    [player stop];
    [player autorelease];    
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
	NSLog(@"webViewDidStartLoad started");
	UINavigationController *navController = (UINavigationController *)[self parentViewController];
	[navController setNavigationBarHidden:YES animated:YES];	
	
	// Showing animated gif for page loading
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(round((self.view.frame.size.width-100)/2), round((self.view.frame.size.height-100)/2), 100, 100)];
	imageView.animationImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"load1.png"],
																[UIImage imageNamed:@"load2.png"],
																[UIImage imageNamed:@"load3.png"],
																[UIImage imageNamed:@"load4.png"],
																[UIImage imageNamed:@"load5.png"],
																[UIImage imageNamed:@"load6.png"],
																[UIImage imageNamed:@"load7.png"],
																[UIImage imageNamed:@"load8.png"],
																[UIImage imageNamed:@"load9.png"],
																[UIImage imageNamed:@"load10.png"],
																[UIImage imageNamed:@"load11.png"],
																[UIImage imageNamed:@"load12.png"],
																nil
																];
	imageView.animationDuration = 1.0f;
	imageView.animationRepeatCount = 0;
	imageView.alpha = 0.6;
	imageView.backgroundColor = [UIColor clearColor];
	imageView.tag = 1;
	[self.view addSubview:imageView];
	[imageView startAnimating];
	
	NSLog(@"webViewDidStartLoad finished %@",[navController description]);	
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"webViewDidFinishLoad started ");
	UINavigationController *navigationCtr = (UINavigationController *)[self parentViewController];	
	[navigationCtr setNavigationBarHidden:NO animated:YES];
	
	// removing image
	UIImageView *image = (UIImageView *)[self.view viewWithTag:1];
	[image stopAnimating];
	[image removeFromSuperview];		
	
	NSLog(@"webViewDidFinishLoad finished %@",[navigationCtr description]);	
}

- (void)dealloc {
	[selectedFile release];
	[fileDetailsView release];
    [super dealloc];
}

@end
