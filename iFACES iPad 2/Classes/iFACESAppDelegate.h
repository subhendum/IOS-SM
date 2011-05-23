//
//  iFACESAppDelegate.h
//  iFACES
//
//  Created by Hardik Zaveri on 05/09/08.
//  Copyright Deloitte  2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "clsLogin.h"
#import "clsHome.h"
#import "clsCaseLoad.h"

@class iFACESViewController;

@interface iFACESAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
	IBOutlet UINavigationController *navigationController;
	
	double iFACESSSN;
	double iEntityID;
	double iContactEntityID;
	int iMediaID;
	double iCaseID;
	double iContactID;
 
	NSString *sCaseName;
	NSString *sCaseOpenDate;
	NSString *sContactName;
	NSString *sMediaFileSelected;
	NSString *sOperationMode;
	NSString *sMapQuery;
	double iMediaType;
	
	bool blnRefreshPage;
	bool blnRefreshContactsPage;
	
	clsLogin *objLogin;
	clsHome *objHome;
	clsCaseLoad *objCaseload;
}

@property (assign, nonatomic) NSString *sMapQuery;
@property (assign, nonatomic) bool blnRefreshPage;
@property (assign, nonatomic) bool blnRefreshContactsPage;


@property (assign, nonatomic) double iCaseID;
@property (assign, nonatomic) double iContactID;
@property (assign, nonatomic) double iContactEntityID;
@property (nonatomic, retain) NSString *sCaseName;
@property (nonatomic, retain) NSString *sContactName;
@property (nonatomic, retain) NSString *sMediaFileSelected;
@property (nonatomic, retain) NSString *sOperationMode;

@property (assign, nonatomic) int iMediaID;
@property (assign, nonatomic) double iFACESSSN;
@property (assign, nonatomic) double iEntityID;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) clsLogin *objLogin;
@property (nonatomic, retain) clsHome *objHome;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) clsCaseLoad *objCaseload;
@property (assign, nonatomic) double iMediaType;

@property (nonatomic, retain) NSString *sCaseOpenDate;

- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)LoggedInSuccessful;
@end

