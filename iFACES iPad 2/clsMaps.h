//
//  clsMaps.h
//  iFACES
//
//  Created by Hardik Zaveri on 16/10/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>


@interface clsMaps : UIViewController <UIWebViewDelegate>
{
	IBOutlet UIWebView *vwMap;

}
@property(nonatomic, retain) UIWebView *vwMap;


@end
