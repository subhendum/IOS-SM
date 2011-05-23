//
//  HomeViewController.m
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "ProductCategoriesViewController.h"
#import "TabBarTrialAppDelegate.h"

@implementation HomeViewController
@synthesize productButton;

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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

- (IBAction)buttonSelectedOnHomeScreen:(id)sender {
	
	NSLog(@"Selected Button : %@",productButton.titleLabel.text);
	TabBarTrialAppDelegate *appDelegate = (TabBarTrialAppDelegate *) [[UIApplication sharedApplication] delegate];
	appDelegate.selectedProdutcType = productButton.titleLabel.text;
	
//	ProductCategoriesViewController *categoriesViewController = [[ProductCategoriesViewController alloc] initWithStyle:UITableViewStylePlain];
//	[self.navigationController pushViewController:categoriesViewController animated:YES];
	
	[appDelegate.window addSubview:appDelegate.tabBarController.view];
    
    [appDelegate.window makeKeyAndVisible];
}

- (void)dealloc {
	[productButton release];
    [super dealloc];
}


@end
