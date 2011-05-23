//
//  MapViewController.h
//  iFACES
//
//  Created by Deloitte-1 on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MapViewController : UIViewController<UIWebViewDelegate> {
    
    NSString *url;
    UIWebView *mapView;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) UIWebView *mapView;

@end
