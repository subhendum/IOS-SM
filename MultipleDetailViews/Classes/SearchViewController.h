//
//  SearchViewController.h
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface SearchViewController : UITableViewController<UISearchBarDelegate> {

	NSMutableArray *searchResultsArray;
	NSMutableArray *downloadedFilesArray;
	UITableView *tableSearchView;
	UINavigationController *searchNavController;
	AppDelegate *appDelegate;
	UIView *transparentView;
	UIActivityIndicatorView *activityIndicator;	
}

@property (nonatomic,retain) NSMutableArray *searchResultsArray;
@property (nonatomic,retain) NSMutableArray *downloadedFilesArray;
@property (nonatomic, retain) IBOutlet UITableView *tableSearchView;
@property (nonatomic, retain) IBOutlet UINavigationController *searchNavController;
@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) UIView *transparentView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

-(void)reloadFilesListInTable:(int)currentCounter;
@end
