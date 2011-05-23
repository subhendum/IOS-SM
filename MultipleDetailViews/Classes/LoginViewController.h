//
//  LoginViewController.h
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController {
	
	IBOutlet UITextField *txtUsername;
	IBOutlet UITextField *txtPassword;
	IBOutlet UIButton *btnLogin;

}

@property (nonatomic, retain) IBOutlet UITextField *txtUsername;
@property (nonatomic, retain) IBOutlet UITextField *txtPassword;
@property (nonatomic, retain) IBOutlet UIButton *btnLogin;

-(IBAction)loginButtonPressed:(id)sender;
-(IBAction)hideKeyboard:(id)sender;

@end
