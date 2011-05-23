//
//  HomeViewController.h
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomeViewController : UIViewController {
	
	IBOutlet UIButton *productButton;

}

@property (nonatomic, retain) IBOutlet UIButton *productButton;
- (IBAction)buttonSelectedOnHomeScreen:(id)sender;

@end
