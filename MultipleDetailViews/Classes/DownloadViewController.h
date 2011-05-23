//
//  DownloadViewController.h
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 5/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface DownloadViewController : UITableViewController {

	NSMutableArray *availableFilesArray;
	UINavigationController *downloadNavController;
	AppDelegate *appDelegate;
	NSMutableArray *downloadFiles;
	UIView *transparentView;
	UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) NSMutableArray *availableFilesArray;
@property (nonatomic, retain) NSMutableArray *downloadFiles;
@property (nonatomic, retain) IBOutlet UINavigationController *downloadNavController;
@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) UIView *transparentView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

-(void)reloadFilesListInTable;

@end
