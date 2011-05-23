//
//  clsCaseMedia.h
//  iFACES
//
//  Created by Hardik Zaveri on 12/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "clsAudioController.h"
#import "sqlite3.h"
#import "clsCNNIPageController.h"

@interface clsCaseMedia : UIViewController
{
	IBOutlet UITableView *tableView;
	NSMutableArray *media;
	sqlite3 *database;
	
	clsCNNIPageController *objCNNIPageController;

}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *media;

@property (nonatomic, retain) clsCNNIPageController *objCNNIPageController;

@end
