//
//  PremiumStoreAnnotation.m
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PremiumStoreAnnotation.h"


@implementation PremiumStoreAnnotation
@synthesize name = _name;
@synthesize address = _address; 
@synthesize coordinate = _coordinate;

- (id)initWithName:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate {
	
	if ((self = [super init])) {
		
		_name = [name copy];
		_address = [address copy];
		_coordinate = coordinate;
	}
	return self;
}

- (NSString *)title {
	
	return _name;
}

- (NSString *)subtitle {
	
	return _address;
}

- (void)dealloc {
	
	[_name release];
	[_address release];
	[super dealloc];
}

@end
