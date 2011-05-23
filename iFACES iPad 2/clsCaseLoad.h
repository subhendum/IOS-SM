//
//  clsWorkLoad.h
//  iFACES
//
//  Created by Hardik Zaveri on 09/09/08.
//  Copyright 2008 Deloitte . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "clsCICLPageController.h"

@interface clsCaseLoad : UIViewController
{
	IBOutlet UITableView *tableView;
	NSMutableArray *cases;
	
	sqlite3 *database;
	
	clsCICLPageController *objCICLPageController;
}
@property (nonatomic, retain) clsCICLPageController *objCICLPageController;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *cases;


@end
