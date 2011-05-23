//
//  clsCICLPageController.m
//  iFACES
//
//  Created by Hardik Zaveri on 31/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsCICLPageController.h"
#import "iFACESAppDelegate.h"

@implementation clsCICLPageController
@synthesize objCaseInfo;
@synthesize objContacts;
@synthesize pageControl;
@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {

		self.navigationItem.title = @"Case Info";
		// Initialization code
	}
	return self;
}
- (void)viewWillAppear:(BOOL)animated 
{
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	if(appDelegate.blnRefreshContactsPage)
	{
		objContacts = nil;
		[self loadScrollViewWithPage:1];
		appDelegate.blnRefreshContactsPage = FALSE;
	}
	
}
- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= 2) return;
	if(page == 0)
	{
		
		if(objCaseInfo == nil)
		{
			objCaseInfo = [[clsCaseInfo alloc] initWithNibName:@"nCaseInfo" bundle:nil];
			CGRect frame = scrollView.frame;
			frame.origin.x = frame.size.width * page;
			frame.origin.y = 0;
			objCaseInfo.view.frame = frame;
			[scrollView addSubview:objCaseInfo.view];
		}
	}
	else if(page == 1)
	{
		if(objContacts == nil)
		{
			objContacts = [[clsCaseContacts alloc] initWithNibName:@"nCaseContacts" bundle:nil];
			CGRect frame = scrollView.frame;
			frame.origin.x = frame.size.width * page;
			frame.origin.y = 0;
			objContacts.view.frame = frame;
			[scrollView addSubview:objContacts.view];
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
		self.navigationItem.title = @"Case Info";
	}
	else if(page == 1)
	{
		self.navigationItem.title = @"Clients";
		
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
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[scrollView release];
    [pageControl release];
	[super dealloc];
}


@end
