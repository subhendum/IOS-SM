//
//  clsMaps.m
//  iFACES
//
//  Created by Hardik Zaveri on 16/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import "clsMaps.h"
#import "iFACESAppDelegate.h"

@implementation clsMaps
@synthesize vwMap;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Initialization code
		self.title = @"Map";
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
- (void)loadView {
}
 */

// If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad 
{
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	if(vwMap == nil)
		vwMap = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
	vwMap.delegate = self;
	iFACESAppDelegate *appDelegate = (iFACESAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *tmp = @"http://maps.google.com/maps?&z=16&iwloc=A";
	tmp = [tmp stringByAppendingString: appDelegate.sMapQuery];
	[vwMap loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tmp]]];
	
 	tmp = nil;  
	
	//[self.view addSubview:vwMap];
}
 
-(void) webViewDidFinishLoad: (UIWebView *) webView
{
	[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('panel').style.display='none';"];
	[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('gbar').style.display='none';"];
	[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('guser').style.display='none';"];
	[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('header').style.display='none';"];
	[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('links').style.display='none';"];
	[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('panel0').style.display='none';"];
	[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('panel1').style.display='none';"];
	[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('panel2').style.display='none';"];
	[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('panel3').style.display='none';"];
	[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('map').style.width='100%';"];
	//[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('map').style.height='100%';"];
	[vwMap stringByEvaluatingJavaScriptFromString:@"document.getElementById('map').style.left='0px';"];
	[self.view addSubview:vwMap];
	vwMap = nil;
	//[vwMap scalesPageToFit:FALSE];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	vwMap = nil;
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	vwMap = nil;
	[vwMap release];
	[super dealloc];
}


@end
