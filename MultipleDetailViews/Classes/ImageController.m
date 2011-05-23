    //
//  ImageController.m
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageController.h"


@implementation ImageController
@synthesize imageView, file;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	// Getting the Documents folder path
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *rootPathWithFolder = [rootPath stringByAppendingPathComponent:@"DocsImages"];
	NSString *path = [rootPathWithFolder stringByAppendingPathComponent:file];
	//if (self.imageView = nil) {
	self.imageView = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:path]];
	self.imageView.contentMode = UIViewContentModeScaleToFill;
	//}
	[self.view addSubview:imageView];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[imageView release];
	[file release];
    [super dealloc];
}


@end
