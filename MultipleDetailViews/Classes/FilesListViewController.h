//
//  FilesListViewController.h
//  Brown-Forman-GDocSync
//
//  Created by Suyash Kaulgud on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@interface FilesListViewController : UITableViewController {
	
	UINavigationController *filesNavigationController;
	NSArray *filesList;
	NSDictionary *fileIcons;
	UITableView *filesListTableView;
	UIActivityIndicatorView *activityIndicator;
	
	UIView *transparentView;
	
	AppDelegate *appDelegate;
	MPMoviePlayerController *moviePlayer;
	
	UIProgressView *progressView;
	NSTimer *timer;
}

@property (nonatomic, retain) IBOutlet UINavigationController *filesNavigationController;
@property (nonatomic, retain) NSArray *filesList;
@property (nonatomic, retain) NSDictionary *fileIcons;
@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) UITableView *filesListTableView;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) UIView *transparentView;

-(void)reloadFilesListInTable:(int)currentCounter;

@end
