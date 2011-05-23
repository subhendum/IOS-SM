//
//  NewsTabViewController.m
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsTabViewController.h"


@implementation NewsTabViewController
@synthesize CLController,lblLatitude,lblLongitude;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    

	CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;
	[CLController.locManager startUpdatingLocation];
	[super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	
	}

- (void)locationUpdate:(CLLocation *)location {
	
	NSLog(@" Location Update : %@",[location description]);
	NSLog([NSString stringWithFormat:@"Latitude : %f",location.coordinate.latitude]);
	NSLog([NSString stringWithFormat:@"Longitude : %f",location.coordinate.longitude]);
	
	lblLatitude.text = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
	lblLongitude.text = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
}

- (void)locationError:(NSError *)error {
	
	NSLog(@" Location Error : %@",[error description]);
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}




#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[CLController release];
    [super dealloc];
}


@end

