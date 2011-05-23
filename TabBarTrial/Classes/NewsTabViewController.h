//
//  NewsTabViewController.h
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocationController.h"

@interface NewsTabViewController : UIViewController<CoreLocationControllerDelegate> {

	CoreLocationController *CLController;
	IBOutlet UILabel *lblLatitude;
	IBOutlet UILabel *lblLongitude;
	
}

@property (nonatomic, retain) CoreLocationController *CLController;

@property(nonatomic, retain) IBOutlet UILabel *lblLatitude;
@property(nonatomic, retain) IBOutlet UILabel *lblLongitude;

@end
