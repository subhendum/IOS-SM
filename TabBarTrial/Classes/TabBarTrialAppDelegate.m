//
//  TabBarTrialAppDelegate.m
//  TabBarTrial
//
//  Created by Suyash Kaulgud on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TabBarTrialAppDelegate.h"


@implementation TabBarTrialAppDelegate

@synthesize window, tabBarController, productsTabController, storesLocatorTabController, myAccountTabController, searchTabController, moreTabController, contactUsTabController,backController, scannerController, newsController, productsNavigationController, selectedProdutcType, homeTabController, homeController,storeLocatorController,searchStoreViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	
	tabBarController = [[UITabBarController alloc] init];
	
	tabBarController.delegate = self;
	
//	self.homeTabController = [[HomeTabViewController alloc] init];
//	UIImage *homeImage = [UIImage imageNamed:@"wine-glass.png"];
//	UITabBarItem *homeItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:homeImage tag:0];
//	self.homeTabController.tabBarItem = homeItem;
	
	self.homeController = [[HomeViewController alloc] init];
	UIImage *homeImage = [UIImage imageNamed:@"wine-glass.png"];
	UITabBarItem *homeItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:homeImage tag:0];
	self.homeController.tabBarItem = homeItem;
	
	self.productsTabController = [[ProductsTabViewController alloc] init];
	UIImage *productsImage = [UIImage imageNamed:@"product.png"];
	UITabBarItem *productsItem = [[UITabBarItem alloc] initWithTitle:@"Products" image:productsImage tag:1];
	self.productsTabController.tabBarItem = productsItem;
	productsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.productsTabController];	
	//productsNavigationController.navigationItem. = @"Products";
	
	self.searchTabController = [[SearchTabViewController alloc] init];
	UIImage *searchImage = [UIImage imageNamed:@"search.png"];
	UITabBarItem *searchItem = [[UITabBarItem alloc] initWithTitle:@"Search" image:searchImage tag:2];
	self.searchTabController.tabBarItem = searchItem;	
	
	 self.myAccountTabController = [[MyAccountTabViewController alloc] init];
	UIImage *myAccountImage = [UIImage imageNamed:@"account.png"];
	UITabBarItem *myAccountItem = [[UITabBarItem alloc] initWithTitle:@"My Account" image:myAccountImage tag:3];
	self.myAccountTabController.tabBarItem = myAccountItem;
		
	 self.moreTabController = [[MoreTabViewController alloc] init];
	UIImage *moreImage = [UIImage imageNamed:@"arrowright.png"];
	UITabBarItem *moreItem = [[UITabBarItem alloc] initWithTitle:@"More..." image:moreImage tag:4];
	self.moreTabController.tabBarItem = moreItem;
	 	
	
	NSArray *controllers = [[NSArray alloc] initWithObjects:self.homeController ,self.productsNavigationController,self.searchTabController,self.myAccountTabController,self.moreTabController,nil];
	self.tabBarController.viewControllers = controllers;

	
		
	[window addSubview:tabBarController.view];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	
	NSLog(@"Tab bar selected item -> %@",[viewController.tabBarItem title]);
	//[self sendMessageToTwitter:self];
	
	if ([viewController.tabBarItem.title isEqualToString:@"More..."])
	{
		self.backController = [[BackViewController alloc] init];
		UIImage *backImage = [UIImage imageNamed:@"arrowleft.png"];
		UITabBarItem *backItem = [[UITabBarItem alloc] initWithTitle:@"...Back" image:backImage tag:0];
		self.backController.tabBarItem = backItem;
		
//		self.storesLocatorTabController = [[StoreLocatorTabViewController alloc] init];
//		UIImage *locateStoreImage = [UIImage imageNamed:@"location.png"];
//		UITabBarItem *locateStoreItem = [[UITabBarItem alloc] initWithTitle:@"Locate Store" image:locateStoreImage tag:1];
//		self.storesLocatorTabController.tabBarItem = locateStoreItem;
		
		self.storeLocatorController = [[StoreLocatorViewController alloc] init];
		UIImage *locateStoreImage = [UIImage imageNamed:@"location.png"];
		UITabBarItem *locateStoreItem = [[UITabBarItem alloc] initWithTitle:@"Locate Store" image:locateStoreImage tag:1];
		self.storeLocatorController.tabBarItem = locateStoreItem;
		
//		self.searchStoreViewController = [[SearchStoreViewController alloc] init];
//		UIImage *locateStoreImage = [UIImage imageNamed:@"location.png"];
//		UITabBarItem *locateStoreItem = [[UITabBarItem alloc] initWithTitle:@"Locate Store" image:locateStoreImage tag:1];
//		self.searchStoreViewController.tabBarItem = locateStoreItem;		
		
		
		self.scannerController = [[ScannerTabViewController alloc] init];
		UIImage *scannerImage = [UIImage imageNamed:@"scanner.png"];
		UITabBarItem *scannerItem = [[UITabBarItem alloc] initWithTitle:@"Barcode Scan" image:scannerImage tag:2];
		self.scannerController.tabBarItem = scannerItem;
		
		self.newsController = [[NewsTabViewController alloc] init];
		UIImage *newsImage	= [UIImage imageNamed:@"news.png"];
		UITabBarItem *newsItem = [[UITabBarItem alloc] initWithTitle:@"News" image:newsImage tag:2];
		self.newsController.tabBarItem = newsItem;
					
		self.contactUsTabController = [[ContactUsTabViewController alloc] init];
		UIImage *sixthImage = [UIImage imageNamed:@"mail.png"];
		UITabBarItem *sixthItem = [[UITabBarItem alloc] initWithTitle:@"Contact Us" image:sixthImage tag:4];
		self.contactUsTabController.tabBarItem = sixthItem;
					
		self.tabBarController.viewControllers = [[NSArray alloc] initWithObjects:self.backController,self.storeLocatorController, self.scannerController,self.newsController,self.contactUsTabController,nil];	
		
		
	}
	else if ([viewController.tabBarItem.title isEqualToString:@"...Back"])
	{
		self.tabBarController.viewControllers = [[NSArray alloc] initWithObjects:self.homeController ,self.productsNavigationController,self.searchTabController,self.myAccountTabController,self.moreTabController,nil];
		
	}
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

// This method is used to post a message to the twitter account. theMessage contains data to be posted.
//- (void)sendMessageToTwitter:(id *) handler {
//	
//	NSString *theMessage = @"test message";
//	
//	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://mformusic:madmax55@twitter.com/statuses/update.xml"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//	[request setHTTPMethod:@"POST"];
//	[request setHTTPBody:[[NSString stringWithFormat:@"status=%@",theMessage] dataUsingEncoding:NSASCIIStringEncoding]];
//	NSURLResponse *response;
//	NSError *error;
//	NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//	NSLog(@"%@", [[[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding] autorelease]);
//}


- (void)dealloc {
	[homeController release];
	[productsTabController release];
	[searchTabController release];
	[myAccountTabController release];
	[scannerController release];
	[newsController release];
	[storesLocatorTabController release];
    [window release];
    [super dealloc];
}


@end
