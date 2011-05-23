//
//  CoreLocationController.h
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol CoreLocationControllerDelegate
@required

- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;

@end


@interface CoreLocationController : NSObject<CLLocationManagerDelegate> {

	CLLocationManager *locManager;
	id delegate;
}

@property (nonatomic, retain) CLLocationManager *locManager;
@property (nonatomic, retain) id delegate;

@end
