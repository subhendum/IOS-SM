//
//  TabBarTrialAppDelegate.h
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"StoreLocatorTabViewController.h"
#import "MyAccountTabViewController.h"
#import	"SearchTabViewController.h"
#import	"MoreTabViewController.h"
#import	"CartTabViewController.h"
#import	"ContactUsTabViewController.h"
#import "BackViewController.h"
#import	"ScannerTabViewController.h"
#import	"NewsTabViewController.h"
#import "ProductsTabViewController.h"
#import "HomeTabViewController.h"
#import	"HomeViewController.h"
#import "StoreLocatorViewController.h"
#import "SearchStoreViewController.h"

@interface TabBarTrialAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
	UITabBarController *tabBarController;
	ProductsTabViewController *productsTabController;
	StoreLocatorTabViewController *storesLocatorTabController;
	MyAccountTabViewController *myAccountTabController;
	SearchTabViewController *searchTabController;
	MoreTabViewController *moreTabController;
	ContactUsTabViewController *contactUsTabController;
	BackViewController *backController;
	ScannerTabViewController *scannerController;
	NewsTabViewController	*newsController;
	HomeTabViewController *homeTabController;
	HomeViewController *homeController;
	StoreLocatorViewController *storeLocatorController;
	SearchStoreViewController *searchStoreViewController;
	UINavigationController *productsNavigationController;
	NSString *selectedProdutcType;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) ProductsTabViewController *productsTabController;
@property (nonatomic, retain) StoreLocatorTabViewController *storesLocatorTabController;
@property (nonatomic, retain) MyAccountTabViewController *myAccountTabController;
@property (nonatomic, retain) SearchTabViewController *searchTabController;
@property (nonatomic, retain) MoreTabViewController *moreTabController;
@property (nonatomic, retain) HomeTabViewController *homeTabController;
@property (nonatomic, retain) ContactUsTabViewController *contactUsTabController;
@property (nonatomic, retain) BackViewController *backController;
@property (nonatomic, retain) ScannerTabViewController *scannerController;
@property (nonatomic, retain) NewsTabViewController *newsController;
@property (nonatomic, retain) UINavigationController *productsNavigationController;
@property (nonatomic, retain) NSString *selectedProdutcType;
@property (nonatomic, retain) HomeViewController *homeController;	
@property (nonatomic, retain) StoreLocatorViewController *storeLocatorController;
@property (nonatomic, retain) SearchStoreViewController *searchStoreViewController;

@end

