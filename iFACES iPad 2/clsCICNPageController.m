//
//  clsCICNPageController.m
//  iFACES
//
//  Created by Hardik Zaveri on 31/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsCICNPageController.h"
#import "iFACESAppDelegate.h"

@implementation clsCICNPageController
@synthesize pageControl;
@synthesize scrollView;

@synthesize objContactInfo;
@synthesize objCaseMedia;
@synthesize textNote;
@synthesize caseAudioController;
@synthesize photoNote;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		self.navigationItem.title = @"Client Info";
	}
	return self;
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= 2) return;
	if(page == 0)
	{
		
		if(objContactInfo == nil)
		{
			objContactInfo = [[clsContactInfo alloc] initWithNibName:@"nContactInfo" bundle:nil];
            
			CGRect frame = scrollView.frame;
			frame.origin.x = frame.size.width * page;
			frame.origin.y = 0;
            objContactInfo.view.frame = frame;
			[scrollView addSubview:objContactInfo.view];
		}
	}
	else if(page == 1)
	{
		if(objCaseMedia == nil)
		{
			objCaseMedia = [[clsCaseMedia alloc] initWithNibName:@"nCaseMedia" bundle:nil];
			CGRect frame = scrollView.frame;
			frame.origin.x = frame.size.width * page;
			frame.origin.y = 0;
			objCaseMedia.view.frame = frame;
			[scrollView addSubview:objCaseMedia.view];
		}
	}
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
	
	if(page == 0)
	{
		self.navigationItem.title = @"Client Info";
		self.navigationItem.rightBarButtonItem = nil;
	}
	else if(page == 1)
	{
		self.navigationItem.title = @"Client Notes";
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonSystemItemAdd 
																								   target:self action:@selector(new:)] autorelease];
	}
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
	
}

- (void)viewWillAppear:(BOOL)animated 
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.blnRefreshPage)
	{
		objCaseMedia = nil;
		[self loadScrollViewWithPage:1];
		appDelegate.blnRefreshPage = FALSE;
	}
	
 
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

/*
 If you need to do additional setup after loading the view, override viewDidLoad.*/
 - (void)viewDidLoad {
 scrollView.pagingEnabled = YES;
 scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 2, 0);
 scrollView.showsHorizontalScrollIndicator = NO;
 scrollView.showsVerticalScrollIndicator = NO;
 scrollView.scrollsToTop = NO;
 scrollView.delegate = self;
 
 pageControl.numberOfPages = 2;
 pageControl.currentPage = 0;
 
  [self loadScrollViewWithPage:0];
  [self loadScrollViewWithPage:1];
 // pages are created on demand
 // load the visible page
 // load the page on either side to avoid flashes when the user starts scrolling
 
 }

- (clsAudioController *)caseAudioController
{
	caseAudioController = [[clsAudioController alloc] initWithNibName:@"nAudioController" bundle:nil];
    return caseAudioController;
}

- (clsTextNote *)textNote
{
	textNote = [[clsTextNote alloc] initWithNibName:@"nTextNote" bundle:nil];
    return textNote;
}

- (clsPhotoNote *)photoNote
{
	photoNote = [[clsPhotoNote alloc] initWithNibName:@"nPhotoNote" bundle:nil];
    return photoNote;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)new:(id)sender 
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Text Note", @"Photo Note", @"Voice Note", nil];
	[actionSheet showInView:[appDelegate.navigationController view]]; 
	[actionSheet release];
}

- (void) actionSheet: (UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger) buttonIndex
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(buttonIndex == 1)
	{
		appDelegate.sMediaFileSelected = nil;
		appDelegate.iMediaID = 0;
		appDelegate.iMediaType = 1;
		appDelegate.sOperationMode = @"ADD";
		clsPhotoNote *objPhotoNote = self.photoNote;
		objPhotoNote.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonSystemItemDone
																						 target:self action:@selector(viewBack:)] autorelease];
		
		[appDelegate.navigationController pushViewController:objPhotoNote animated:YES];
	}
	else if(buttonIndex == 2)
	{
		appDelegate.iMediaID = 0;
		appDelegate.sMediaFileSelected = nil;
		appDelegate.iMediaType = 0;
		clsAudioController *objAudioController = self.caseAudioController;
		objAudioController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonSystemItemDone
																							   target:self action:@selector(viewBack:)] autorelease];
		
		[appDelegate.navigationController pushViewController:objAudioController animated:YES];
	}
	else if(buttonIndex == 0)
	{
		appDelegate.iMediaID = 0;
		appDelegate.sOperationMode = @"ADD";
		appDelegate.iMediaType = 3;
		clsTextNote *objTextNote = self.textNote;
		objTextNote.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonSystemItemDone
																						target:self action:@selector(viewBack:)] autorelease];
		
		[appDelegate.navigationController pushViewController:objTextNote animated:YES];
	}
	
}

-(IBAction) viewBack: (id) sender
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate navigationController] popViewControllerAnimated:YES];
	[self loadScrollViewWithPage:1];
}



- (void)didReceiveMemoryWarning {
	[textNote release];
	[caseAudioController release];
	[photoNote release];
	[scrollView release];
    [pageControl release];
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
	
}


- (void)dealloc {
	
	[textNote release];
	[caseAudioController release];
	[photoNote release];
	[scrollView release];
    [pageControl release];
	
	[super dealloc];
}


@end
