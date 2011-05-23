//
//  CoreLocationController.m
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoreLocationController.h"


@implementation CoreLocationController
@synthesize locManager, delegate;

- (id)init {
	self = [super init];
	
	if (self != nil) {
		
		self.locManager = [[[CLLocationManager alloc] init] autorelease];
		self.locManager.delegate = self;
	}
	return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation  *)newLocation fromLocation:(CLLocation *)oldLocation {

	
	if ([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)])
	{
		NSLog(@"Inside didUpdateToLocation");
		[self.delegate locationUpdate:newLocation];
		
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
	if ([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)])
	{
		NSLog(@"Inside didFailWithError");
		[self.delegate locationError:error];
		
	}
}

- (void)dealloc {
	
	[self.locManager release];
	[super dealloc];
}

@end
