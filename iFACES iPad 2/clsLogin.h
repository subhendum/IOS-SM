//
//  clsLogin.h
//  iFACES
//
//  Created by Hardik Zaveri on 04/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class iFACESAppDelegate;
@interface clsLogin : UIViewController {
	//IBOutlet UINavigationBar *navigationItem;

	IBOutlet UILabel *lblUserName;
	IBOutlet UILabel *lblPassword;
	IBOutlet UIButton *btnLogin;
	IBOutlet UITextField *txtUserName;
	IBOutlet UITextField *txtPassword;
	IBOutlet UILabel *lblMessage;
	sqlite3 *database;
}

@property (nonatomic, retain) UILabel *lblUserName;
@property (nonatomic, retain) UILabel *lblPassword;
@property (nonatomic, retain) UIButton *btnLogin;
@property (nonatomic, retain) UITextField *txtUserName;
@property (nonatomic, retain) UITextField *txtPassword;
@property (nonatomic, retain) UILabel *lblMessage;


- (IBAction)btnLogin_Click:(id) sender; 

@end
