//
//  StoreLocatorViewController.m
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StoreLocatorViewController.h"
#import "StoreAnnotation.h"
#import "PremiumStoreAnnotation.h"
#import "TabBarTrialAppDelegate.h"
#import "StoreDetailsViewController.h"

@implementation StoreLocatorViewController
@synthesize map,CLController;

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
	
	CLController = [[CoreLocationController alloc] init];
	CLController.delegate = self;
	[CLController.locManager startUpdatingLocation];
}

- (void)locationUpdate:(CLLocation *)location {
	
	NSLog(@" Location Update : %@",[location description]);
	NSLog([NSString stringWithFormat:@"Latitude : %f",location.coordinate.latitude]);
	NSLog([NSString stringWithFormat:@"Longitude : %f",location.coordinate.longitude]);
}

- (void)locationError:(NSError *)error {
	
	NSLog(@" Location Error : %@",[error description]);
}


- (void)viewWillAppear:(BOOL)animated {
	CLLocationCoordinate2D zoomLocation;
	//zoomLocation.latitude = 40.600214;
//	zoomLocation.longitude = -80.304859;
	
	//zoomLocation.latitude = self.CLController.
	
	MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERS_PER_MILE, METERS_PER_MILE);
	MKCoordinateRegion adjustRegion = [map regionThatFits:viewRegion];
	[map setRegion:adjustRegion animated:YES];
	StoreAnnotation *annotationForSimpleStore = [[StoreAnnotation alloc] initWithName:@"Wine and Spirits" address:@"3113 Green Garden Rd, PA 15001" coordinate:zoomLocation];
	

	
	CLLocationCoordinate2D premiumLocation;
//	premiumLocation.latitude = 40.608653;
//	premiumLocation.longitude = -80.283075;	
	PremiumStoreAnnotation *annotationForPremiumStore = [[PremiumStoreAnnotation alloc] initWithName:@"Aliquippa Shopping Center" address:@"2719 Broadhead Rd, Suite 13, PA 15001" coordinate:premiumLocation];
	
	NSArray *storeAnnotations = [[NSArray alloc] initWithObjects:annotationForSimpleStore,annotationForPremiumStore,nil];
	
	[map addAnnotations:storeAnnotations];
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	
    // handle our two custom annotations
    //
    if ([annotation isKindOfClass:[StoreAnnotation class]]) // for normal stores
    {
        // try to dequeue an existing pin view first
       static NSString* StoreAnnotationIdentifier = @"storeAnnotationIdentifier";
        MKPinAnnotationView* storePinView = (MKPinAnnotationView *)
		[map dequeueReusableAnnotationViewWithIdentifier:StoreAnnotationIdentifier];
        if (!storePinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:StoreAnnotationIdentifier] autorelease];
            customPinView.pinColor = MKPinAnnotationColorGreen;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            customPinView.rightCalloutAccessoryView = rightButton;
			
            return customPinView;
        }
        else
        {
            storePinView.annotation = annotation;
        }
        return storePinView;
    }
	else if ([annotation isKindOfClass:[PremiumStoreAnnotation class]]) // for Premium Stores
    {
        // try to dequeue an existing pin view first
		static NSString* StoreAnnotationIdentifier = @"storeAnnotationIdentifier";
        MKPinAnnotationView* storePinView = (MKPinAnnotationView *)
		[map dequeueReusableAnnotationViewWithIdentifier:StoreAnnotationIdentifier];
        if (!storePinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:StoreAnnotationIdentifier] autorelease];
            customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            customPinView.rightCalloutAccessoryView = rightButton;
			
            return customPinView;
        }
        else
        {
            storePinView.annotation = annotation;
        }
        return storePinView;
    }
    
    return nil;
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)showDetails:(id)sender
{
	
	NSLog(@"Inside Show Details method");
    // the detail view does not want a toolbar so hide it
    
	
	//TabBarTrialAppDelegate *appDelegate = (TabBarTrialAppDelegate *) [[UIApplication sharedApplication] delegate];
	StoreDetailsViewController* storeDetailsController = [[StoreDetailsViewController alloc] init];
	
	[self.navigationController pushViewController:storeDetailsController animated:YES];
    
    //[appDelegate.tabBarController.navigationController pushViewController:storeDetailsController animated:YES];
}



- (void)dealloc {
	[map release];
	[CLController release];
    [super dealloc];
}


@end
