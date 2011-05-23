//
//  clsCNNIPageController.m
//  iFACES
//
//  Created by Hardik Zaveri on 31/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsCNNIPageController.h"
#import "iFACESAppDelegate.h"

@implementation clsCNNIPageController
@synthesize textNote;
@synthesize objNotesInfo;
@synthesize photoNote;
@synthesize caseAudioController;

@synthesize scrollView;
@synthesize pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		//self.navigationItem.title = @"Contact Note";
	}
	return self;
}

- (clsPhotoNote *)photoNote
{
	if(photoNote == nil)
	{
		photoNote = [[clsPhotoNote alloc] initWithNibName:@"nPhotoNote" bundle:nil];
	}
    return photoNote;
}


- (clsAudioController *)caseAudioController
{
	if(caseAudioController == nil)
	{
		caseAudioController = [[clsAudioController alloc] initWithNibName:@"nAudioController" bundle:nil];
	}
    return caseAudioController;
}

- (clsTextNote *)textNote
{
	if(textNote == nil)
	{
		textNote = [[clsTextNote alloc] initWithNibName:@"nTextNote" bundle:nil];
	}
    return textNote;
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= 2) return;
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(page == 0)
	{
		CGRect frame = scrollView.frame;
		frame.origin.x = frame.size.width * page;
		frame.origin.y = 0;
		if(appDelegate.iMediaType == 3)
		{
			self.navigationItem.title = @"Text Note";
			clsTextNote *objTextNote = self.textNote;
			objTextNote.view.frame = frame;			
			[scrollView addSubview:objTextNote.view];
			

		}
		else if(appDelegate.iMediaType == 0)
		{
			self.navigationItem.title = @"Voice Note";
			clsAudioController *objAudioController = self.caseAudioController;
			objAudioController.view.frame = frame;
			[scrollView addSubview:objAudioController.view];

		}
		else if(appDelegate.iMediaType == 1)
		{
			self.navigationItem.title = @"Photo Note";
			clsPhotoNote *objPhotoNote = self.photoNote;
			objPhotoNote.view.frame = frame;
			[scrollView addSubview:objPhotoNote.view];
		}

	}
	else if(page == 1)
	{
		if(objNotesInfo == nil)
		{
			objNotesInfo = [[clsNotesInfo alloc] initWithNibName:@"nNotesInfo" bundle:nil];
		
			CGRect frame = scrollView.frame;
			frame.origin.x = frame.size.width * page;
			frame.origin.y = 0;
			objNotesInfo.view.frame = frame;
			[scrollView addSubview:objNotesInfo.view];
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
	
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	
	if(page == 0)
	{
		iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
		if(appDelegate.iMediaType == 3)
			self.navigationItem.title = @"Text Note";
		else if(appDelegate.iMediaType == 0)
			self.navigationItem.title = @"Voice Note";
		else if(appDelegate.iMediaType == 1)
			self.navigationItem.title = @"Photo Note";
		
		//self.navigationItem.title = @"Contact Note";
	}
	else if(page == 1)
	{
		self.navigationItem.title = @"Information";
	}
	
	
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

/*-(IBAction) viewBack: (id) sender
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate navigationController] popViewControllerAnimated:YES];
	UIViewController *vwController = [[[appDelegate navigationController] viewControllers] objectAtIndex:2];
	//vwController.navigationItem.rightBarButtonItem = saveItem;
	[self loadScrollViewWithPage:1];
}*/



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

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */


 /*If you need to do additional setup after loading the view, override viewDidLoad.*/
- (void)viewDidLoad {
  scrollView.pagingEnabled = YES;
  scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 2, 50);
  scrollView.showsHorizontalScrollIndicator = NO;
  scrollView.showsVerticalScrollIndicator = NO;
  scrollView.scrollsToTop = NO;
  scrollView.delegate = self;
  
  pageControl.numberOfPages = 2;
  pageControl.currentPage = 0;
  
  // pages are created on demand
  // load the visible page
  // load the page on either side to avoid flashes when the user starts scrolling
  [self loadScrollViewWithPage:0];
  [self loadScrollViewWithPage:1];
}
 


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[scrollView release];
    [pageControl release];

	[textNote release];
	[objNotesInfo release];
	[photoNote release];
	[caseAudioController release];
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[scrollView release];
    [pageControl release];
	[textNote release];
	[objNotesInfo release];
	[photoNote release];
	[caseAudioController release];

	[super dealloc];
}


@end
