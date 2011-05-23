//
//  ImageViewController.h
//  MultipleDetailViews
//
//  Created by Suyash Kaulgud on 5/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageViewController : UITableViewController {
	
	NSMutableArray *files;
	UINavigationController *imageNavController;
	UITableView *imageTableView;

}

@property (nonatomic, retain) NSMutableArray *files;
@property (nonatomic, retain) IBOutlet UINavigationController *imageNavController;
@property (nonatomic, retain) IBOutlet UITableView *imageTableView;

@end
