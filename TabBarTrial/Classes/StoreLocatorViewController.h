//
//  StoreLocatorViewController.h
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CoreLocationController.h"

#define METERS_PER_MILE 1609.344


@interface StoreLocatorViewController : UIViewController<MKMapViewDelegate,CoreLocationControllerDelegate> {
	
	IBOutlet MKMapView *map;
	BOOL doneInitialZoom;
	CoreLocationController *CLController;

}

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) CoreLocationController *CLController;


@end
