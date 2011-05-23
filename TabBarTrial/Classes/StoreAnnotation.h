//
//  StoreAnnotation.h
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface StoreAnnotation : NSObject<MKAnnotation> {
	
	NSString *_name;
	NSString *_address;
	CLLocationCoordinate2D _coordinate;

}

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate;

@end
